/*************************************************************
 * RBMK Reactor Core (Rod-Driven Rewrite)
 * - Rods drive reactivity and heat output
 * - Coolant dynamically absorbs heat and builds pressure
 * - Instability and integrity handled via modular procs
 *************************************************************/

/// Primary reactor definition
/obj/machinery/rbmk/reactor
	name = "RBMK Reactor Core"
	desc = "A massive nuclear reactor core. Insert rods at your own risk."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_off"

	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32

	layer = OBJ_LAYER + 0.01
	plane = GAME_PLANE

	// --- Atmos / port vars ---
	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

	// --- Fuel rods ---
	var/list/normal_slots = list()
	var/list/special_slots = list()
	var/max_normal_slots = 12
	var/max_special_slots = 4

	// --- Core state ---
	var/temperature = 0
	var/radiation = 0
	var/thermal_output = 0
	var/max_temp = RBMK_MAX_TEMP
	var/running = FALSE
	var/scrammed = FALSE
	var/decay_heat = 0

	// --- Control & reactivity ---
	var/control_rod_depth = 0
	var/flux = 0
	var/instability = 0
	var/moderator_level = 0
	var/list/moderator_history = list()

	// --- Integrity ---
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY
	var/reactor_integrity = RBMK_MAX_INTEGRITY
	var/repairable = FALSE

	// --- Coolant & pressure ---
	var/datum/gas_mixture/coolant_internal
	var/coolant_volume_max = RBMK_COOLANT_VOLUME_MAX
	var/pressure = 0
	var/inlet_open = FALSE
	var/outlet_open = FALSE
	var/inlet_rate = RBMK_INLET_RATE_MIN
	var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE

	// --- History / telemetry ---
	var/list/coolant_pressure_history = list()
	var/list/coolant_temperature_history = list()
	var/list/coolant_total_moles_history = list()
	var/list/coolant_gas_hist = list()
	var/list/reactor_temperature_history = list()

	// --- Tick telemetry ---
	var/last_tick_flux = 0
	var/last_tick_temp_gain = 0
	var/last_tick_rod_count = 0


/*************************************************************
 * Lifecycle
 *************************************************************/

/// Initialize
/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()
	pixel_x = -32
	pixel_y = -32

	var/turf/current_turf = get_turf(src)
	var/datum/gas_mixture/environment = current_turf ? current_turf.return_air() : null
	temperature = environment ? environment.temperature : (T0C + 20)
	if(temperature < RBMK_AMBIENT_TEMP)
		temperature = RBMK_AMBIENT_TEMP

	normal_slots = list()
	special_slots = list()

	rbmk_init_coolant(src)
	START_PROCESSING(SSmachines, src)
	rbmk_relink_ports(src)

/// Cleanup
/obj/machinery/rbmk/reactor/Destroy()
	STOP_PROCESSING(SSmachines, src)
	rbmk_cleanup_atmos(src)
	return ..()


/*************************************************************
 * Reactor Processing
 *************************************************************/

/// Main reactor tick
/obj/machinery/rbmk/reactor/process()
	// --- Halt if destroyed ---
	if(reactor_integrity <= 0)
		return

	// --- Auto shutoff if rods fully inserted ---
	if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		if(running)
			running = FALSE
			scrammed = TRUE
			to_chat(src, span_notice("Control rods fully inserted — reactor shutting down."))
			update_reactor_icon()
			update_linked_consoles()
		return

	// --- Skip non-running state (handled by decay logic elsewhere) ---
	if(!running)
		return

	// --- Base reactivity calc ---
	var/total_reactivity = 0
	var/reactive_rod_count = 0

	for(var/obj/item/rbmk/fuel_rod/fuelRod in (normal_slots + special_slots))
		if(!fuelRod || !fuelRod.active)
			continue
		reactive_rod_count++
		total_reactivity += (fuelRod.fuel_power * fuelRod.flux_multiplier * fuelRod.thermal_multiplier)

	if(reactive_rod_count == 0)
		running = FALSE
		scrammed = TRUE
		return

	last_tick_rod_count = reactive_rod_count

	// --- Control rod damping ---
	var/control_factor = 1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX)
	control_factor = clamp(control_factor, 0, 1)

	total_reactivity *= control_factor

	// --- Reactivity → heat & flux ---
	var/temperature_gain = total_reactivity * RBMK_TEMP_GAIN_PER_TICK
	var/flux_gain = total_reactivity * RBMK_FLUX_GAIN

	temperature += temperature_gain
	flux += flux_gain

	last_tick_flux = flux_gain
	last_tick_temp_gain = temperature_gain

	// --- Coolant absorption ---
	if(coolant_internal)
		var/absorption_rate = inlet_open ? inlet_rate / 100 : 0
		var/heat_absorbed = min(temperature * RBMK_HEAT_SCALING * absorption_rate, temperature)
		temperature -= heat_absorbed
		pressure += heat_absorbed * 0.5
		if(outlet_open)
			pressure = max(pressure - (outlet_target_pressure / 150), 0)

	// --- Radiation ---
	radiation = (temperature * RBMK_RADIATION_TEMP_MULT) + (flux * RBMK_RADIATION_FLUX_MULT)

	// --- Instability + Integrity ---
	update_instability()
	update_reactor_integrity()

	// --- Passive decay ---
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)

	// --- Telemetry ---
	coolant_pressure_history += pressure
	reactor_temperature_history += temperature
	if(length(coolant_pressure_history) > 30)
		coolant_pressure_history.Cut(1, length(coolant_pressure_history) - 30)

	update_linked_consoles()


/*************************************************************
 * Rod Insertion / Removal
 *************************************************************/

/// Insert rods
/obj/machinery/rbmk/reactor/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/rbmk/fuel_rod))
		var/obj/item/rbmk/fuel_rod/fuelRod = item
		var/list/target_list
		var/slot_type

		if(fuelRod.rod_type in list("plasma", "telecrystal", "supermatter"))
			target_list = special_slots
			slot_type = "special"
			if(length(special_slots) >= max_special_slots)
				to_chat(user, span_warning("All special rod slots are occupied!"))
				return TRUE
		else
			target_list = normal_slots
			slot_type = "normal"
			if(length(normal_slots) >= max_normal_slots)
				to_chat(user, span_warning("All normal rod slots are occupied!"))
				return TRUE

		if(!user.transferItemToLoc(fuelRod, src))
			return TRUE

		target_list += fuelRod
		to_chat(user, span_notice("You insert [fuelRod.name] into a [slot_type] slot of the reactor."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)

		running = TRUE
		scrammed = FALSE
		update_icon()
		update_linked_consoles()
		return TRUE
	return ..()

/// Remove rods
/obj/machinery/rbmk/reactor/attack_hand(mob/user)
	var/obj/item/rbmk/fuel_rod/fuelRod
	if(length(special_slots))
		fuelRod = special_slots[length(special_slots)]
		special_slots -= fuelRod
	else if(length(normal_slots))
		fuelRod = normal_slots[length(normal_slots)]
		normal_slots -= fuelRod
	else
		to_chat(user, span_notice("No rods installed."))
		return

	fuelRod.forceMove(get_turf(src))
	to_chat(user, span_notice("You remove [fuelRod.name] from the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!length(normal_slots) && !length(special_slots))
		running = FALSE
		scrammed = TRUE

	update_icon()
	update_linked_consoles()


/*************************************************************
 * Console Sync
 *************************************************************/

/// Update linked consoles
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for(var/obj/machinery/computer/rbmk_console/console in range(7, src))
		if(console.linked_reactor == src)
			console.update_icon()
			SStgui.update_uis(console)
