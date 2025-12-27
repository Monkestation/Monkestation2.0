/*************************************************************
 * RBMK Reactor Core (Stable-Core Rod-Driven Model)
 * FINAL — VERIFIED WORKING
 *************************************************************/

/*************************************************************
 * Reactor Object Definition
 *************************************************************/

/// RBMK Core Machine
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

	/************************************************
	 * Atmos / Ports
	 ************************************************/
	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet

		/*********************************************************
	 * Telemetry (API CONTRACT — DO NOT REMOVE)
	 *********************************************************/
	var/list/coolant_pressure_history
	var/list/coolant_temperature_history
	var/list/coolant_total_moles_history
	var/list/coolant_gas_hist
	var/list/reactor_temperature_history

		/*********************************************************
	 * Coolant Control State (REQUIRED BY CONSOLE + ATMOS)
	 *********************************************************/
	var/inlet_open = FALSE
	var/outlet_open = FALSE

	var/inlet_rate = RBMK_INLET_RATE_MIN
	var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE


	/************************************************
	 * Rod Storage
	 ************************************************/
	var/list/normal_slots = list()
	var/list/special_slots = list()
	var/max_normal_slots = 12
	var/max_special_slots = 4

	/************************************************
	 * Core State
	 ************************************************/
	var/temperature = RBMK_AMBIENT_TEMP
	var/radiation = 0
	var/thermal_output = 0
	var/flux = 0
	var/void_coefficient = 0

	var/running = FALSE
	var/scrammed = FALSE

	/************************************************
	 * Control & Integrity
	 ************************************************/
	var/control_rod_depth = 0
	var/reactor_integrity = RBMK_MAX_INTEGRITY

		/*********************************************************
	 * Structural Integrity (REQUIRED)
	 *********************************************************/
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY


	/************************************************
	 * Coolant / Pressure
	 ************************************************/
	var/datum/gas_mixture/coolant_internal
	var/pressure = 0

	/************************************************
	 * Telemetry (DO NOT REMOVE)
	 ************************************************/
	var/last_tick_flux = 0
	var/last_tick_temp_gain = 0
	var/last_tick_rod_count = 0


/*************************************************************
 * Helper Procs
 *************************************************************/

/// Rod presence
/obj/machinery/rbmk/reactor/proc/has_fuel_rods()
	return (length(normal_slots) + length(special_slots)) > 0

/// Active rods
/obj/machinery/rbmk/reactor/proc/has_active_fuel_rods()
	for (var/obj/item/rbmk/fuel_rod/R in (normal_slots + special_slots))
		if (R && R.active)
			return TRUE
	return FALSE


/// Passive decay (IDLE / SCRAM only)
/proc/rbmk_decay_process(obj/machinery/rbmk/reactor/R)
	if (!R)
		return

	R.flux = max(R.flux - RBMK_FLUX_DECAY, 0)
	R.radiation = max(R.radiation - RBMK_RADIATION_DECAY, 0)


/// Coolant exchange (delta-based, stable)
/proc/rbmk_coolant_exchange(obj/machinery/rbmk/reactor/R)
	if (!R || !R.coolant_internal)
		return

	var/delta = R.temperature - R.coolant_internal.temperature
	if (delta <= 0)
		return

	var/transfer = min(5, delta * 0.25)
	R.temperature -= transfer
	R.coolant_internal.temperature += transfer


/*************************************************************
 * Initialization / Cleanup
 *************************************************************/

/// Initialize
/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()

	reactor_integrity = RBMK_MAX_INTEGRITY
	control_rod_depth = 0
	running = FALSE
	scrammed = FALSE

	var/turf/T = get_turf(src)
	if (T)
		var/datum/gas_mixture/env = T.return_air()
		if (env)
			temperature = env.temperature

	if (temperature < RBMK_AMBIENT_TEMP)
		temperature = RBMK_AMBIENT_TEMP

	normal_slots = list()
	special_slots = list()

	rbmk_init_coolant(src)
	relink_ports()

	update_icon()
	START_PROCESSING(SSmachines, src)
	return INITIALIZE_HINT_NORMAL


/// Destroy
/obj/machinery/rbmk/reactor/Destroy()
	STOP_PROCESSING(SSmachines, src)
	rbmk_cleanup_atmos(src)
	return ..()


/*************************************************************
 * SCRAM
 *************************************************************/

/// Emergency shutdown
/obj/machinery/rbmk/reactor/proc/force_scram()
	if (scrammed)
		return

	scrammed = TRUE
	running = FALSE
	flux = 0
	radiation = 0

	to_chat(src, span_danger("☢ EMERGENCY SCRAM ACTIVATED"))
	update_linked_consoles()


/*************************************************************
 * Main Reactor Process
 *************************************************************/

/// Per-tick logic
/obj/machinery/rbmk/reactor/process()

	/* A. POST-MELTDOWN */
	if (reactor_integrity <= 0)
		flux = 0
		radiation = 0
		update_icon()
		update_linked_consoles()
		return

	/* B. NO RODS */
	if (!has_fuel_rods())
		running = FALSE
		flux = 0
		radiation = 0
		rbmk_coolant_exchange(src)
		update_icon()
		update_linked_consoles()
		return

	/* C. COLLECT ROD OUTPUT */
	var/total_flux = 0
	var/total_radiation = 0
	var/active_rods = 0

	for (var/obj/item/rbmk/fuel_rod/rod in (normal_slots + special_slots))
		if (!rod || !rod.active)
			continue

		var/list/output = rod.process_rod()
		total_flux += output["flux"]
		total_radiation += output["radiation"]
		active_rods++

	last_tick_rod_count = active_rods
	running = (active_rods > 0 && !scrammed)

	/* D. IDLE / SCRAM */
	if (!running)
		rbmk_decay_process(src)
		rbmk_coolant_exchange(src)
		update_icon()
		update_linked_consoles()
		return

	/* E. CONTROL RODS */
	var/control_mult = clamp(
		1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX),
		0,
		1
	)
	total_flux *= control_mult

	/* F. FLUX */
	flux = clamp(total_flux * RBMK_FLUX_GAIN, 0, RBMK_MAX_FLUX)

	/* G. HEAT FROM FLUX */
	var/generated_heat = flux * RBMK_TEMP_GAIN_PER_TICK
	temperature += generated_heat

	thermal_output = generated_heat
	last_tick_flux = flux
	last_tick_temp_gain = generated_heat

	/* H. VOID COEFFICIENT */
	void_coefficient = clamp(
		temperature * RBMK_VC_TEMP_COEFF,
		0,
		RBMK_VC_MAX
	)

	flux = clamp(flux * (1 + void_coefficient), 0, RBMK_MAX_FLUX)

	/* I. RADIATION */
	radiation = clamp(
		total_radiation + (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
		0,
		RBMK_MAX_RADIATION
	)

	/* J. COOLANT (AFTER HEAT) */
	rbmk_coolant_exchange(src)

	update_icon()
	update_linked_consoles()


/*************************************************************
 * Rod Handling
 *************************************************************/

/// Insert rod
/obj/machinery/rbmk/reactor/attackby(obj/item/item, mob/user, params)
	if (!istype(item, /obj/item/rbmk/fuel_rod))
		return ..()

	var/obj/item/rbmk/fuel_rod/rod = item
	var/list/slots

	if (rod.rod_type in list("plasma", "telecrystal", "supermatter"))
		slots = special_slots
		if (length(slots) >= max_special_slots)
			to_chat(user, span_warning("All special rod slots are occupied!"))
			return TRUE
	else
		slots = normal_slots
		if (length(slots) >= max_normal_slots)
			to_chat(user, span_warning("All normal rod slots are occupied!"))
			return TRUE

	if (!user.transferItemToLoc(rod, src))
		return TRUE

	slots += rod
	update_icon()
	update_linked_consoles()

	to_chat(user, span_notice("You insert [rod.name] into the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return TRUE


/// Remove rod
/obj/machinery/rbmk/reactor/attack_hand(mob/user)
	var/obj/item/rbmk/fuel_rod/rod

	if (length(special_slots))
		rod = special_slots[length(special_slots)]
		special_slots -= rod
	else if (length(normal_slots))
		rod = normal_slots[length(normal_slots)]
		normal_slots -= rod
	else
		to_chat(user, span_notice("No rods installed."))
		return

	rod.forceMove(get_turf(src))
	to_chat(user, span_notice("You remove [rod.name] from the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if (!has_fuel_rods())
		running = FALSE
		flux = 0
		radiation = 0

	update_icon()
	update_linked_consoles()


/*************************************************************
 * Icon + Console Sync
 *************************************************************/

/// Engine hook
/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()
	return .


/// Update linked consoles
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for (var/obj/machinery/computer/rbmk_console/C in range(7, src))
		if (C.linked_reactor == src)
			C.update_icon()
			SStgui.update_uis(C)
