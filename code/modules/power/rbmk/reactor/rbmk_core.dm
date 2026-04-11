/*************************************************************
 * RBMK Reactor Core — Canonical V4 Backbone
 * -----------------------------------------------------------
 * Responsibilities of this file:
 * - Reactor object definition / vars
 * - Initialization / cleanup
 * - SCRAM / restart state helpers
 * - Rod insertion / removal
 * - Console synchronization
 * - Explosion survival during meltdown
 * - Sound loop ownership
 *
 * This file does NOT own:
 * - main process logic
 * - visual update logic
 * - coolant exchange helpers
 * - decay helpers
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
	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

	/************************************************
	 * Telemetry History (API CONTRACT)
	 ************************************************/
	var/list/coolant_pressure_history = list()
	var/list/coolant_temperature_history = list()
	var/list/coolant_total_moles_history = list()
	var/list/coolant_gas_hist = list()
	var/list/reactor_temperature_history = list()

	/************************************************
	 * Coolant Control State
	 ************************************************/
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
	var/pressure = 0

	var/running = FALSE
	var/scrammed = FALSE

	/************************************************
	 * Control / Integrity
	 ************************************************/
	/// Commanded rod depth from console/operator input
	var/control_rod_depth = 0
	/// Actual physical rod depth used by reactor physics
	var/actual_control_rod_depth = 0
	/// Normal per-tick rod travel speed
	var/control_rod_step = 4
	/// Faster insertion speed during SCRAM
	var/scram_control_rod_step = 20

	var/reactor_integrity = RBMK_MAX_INTEGRITY
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY

	/************************************************
	 * Coolant Storage
	 ************************************************/
	var/datum/gas_mixture/coolant_internal = null

	/************************************************
	 * Tick Telemetry
	 ************************************************/
	var/last_tick_flux = 0
	var/last_tick_temp_gain = 0
	var/last_tick_rod_count = 0

	/************************************************
	 * Visual Tracking
	 * Owned by visuals module, stored here
	 ************************************************/
	var/current_damage_stage = 0
	var/image/current_damage_overlay_image = null

	/************************************************
	 * Sound Tracking
	 ************************************************/
	var/datum/looping_sound/rbmk_reactor/soundloop = null
	var/last_sound_state = ""

	/************************************************
	 * Meltdown Tracking
	 * Owned by meltdown module, stored here
	 ************************************************/
	var/meltdown_announced = FALSE
	var/meltdown_in_progress = FALSE
	var/decay_meltdown_threshold = RBMK_MAX_TEMP * 0.92
	var/decay_check_interval = 2 SECONDS
	var/last_decay_check = 0


/*************************************************************
 * Basic Reactor Helpers
 *************************************************************/

/// TRUE if any fuel rods are physically installed
/obj/machinery/rbmk/reactor/proc/has_fuel_rods()
	return (length(normal_slots) + length(special_slots)) > 0

/// TRUE if any installed rods are active
/obj/machinery/rbmk/reactor/proc/has_active_fuel_rods()
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(fuel_rod && fuel_rod.active)
			return TRUE
	return FALSE

/// Resets runtime state when the reactor has no active reaction
/obj/machinery/rbmk/reactor/proc/reset_reaction_state()
	running = FALSE
	flux = 0
	radiation = 0
	thermal_output = 0
	void_coefficient = 0
	last_tick_flux = 0
	last_tick_temp_gain = 0
	last_tick_rod_count = 0

/// Returns TRUE if this rod belongs in the special bank
/obj/machinery/rbmk/reactor/proc/is_special_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	if(!fuel_rod)
		return FALSE

	return fuel_rod.rod_type in list("plasma", "telecrystal", "supermatter")

/// Returns the slot list a rod should use
/obj/machinery/rbmk/reactor/proc/get_target_slot_list(obj/item/rbmk/fuel_rod/fuel_rod)
	if(is_special_rod(fuel_rod))
		return special_slots

	return normal_slots


/*************************************************************
 * Explosion Handling
 *************************************************************/

/// During meltdown, the reactor survives its own blast and remains as a slagged core.
/obj/machinery/rbmk/reactor/ex_act(severity, target)
	if(meltdown_in_progress)
		return FALSE

	return ..()


/*************************************************************
 * Initialization / Cleanup
 *************************************************************/

/// Initialize reactor
/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()

	reactor_integrity = RBMK_MAX_INTEGRITY
	max_reactor_integrity = RBMK_MAX_INTEGRITY
	control_rod_depth = 0
	actual_control_rod_depth = 0

	reset_reaction_state()
	scrammed = FALSE
	meltdown_announced = FALSE
	meltdown_in_progress = FALSE
	last_decay_check = 0
	last_sound_state = ""
	soundloop = new(list(src), FALSE)

	var/turf/reactor_turf = get_turf(src)
	if(reactor_turf)
		var/datum/gas_mixture/environment_mix = reactor_turf.return_air()
		if(environment_mix)
			temperature = environment_mix.temperature

	if(temperature < RBMK_AMBIENT_TEMP)
		temperature = RBMK_AMBIENT_TEMP

	normal_slots = list()
	special_slots = list()

	coolant_pressure_history = list()
	coolant_temperature_history = list()
	coolant_total_moles_history = list()
	coolant_gas_hist = list()
	reactor_temperature_history = list()

	rbmk_init_coolant(src)
	relink_ports()

	update_reactor_icon()
	START_PROCESSING(SSmachines, src)
	return INITIALIZE_HINT_NORMAL

/// Destroy reactor
/obj/machinery/rbmk/reactor/Destroy()
	STOP_PROCESSING(SSmachines, src)
	QDEL_NULL(soundloop)
	rbmk_cleanup_atmos(src)
	return ..()


/*************************************************************
 * SCRAM
 *************************************************************/

/// Emergency shutdown — commands full insertion and kills reaction
/obj/machinery/rbmk/reactor/proc/force_scram()
	if(meltdown_in_progress)
		return

	scrammed = TRUE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()

	visible_message(span_danger("[src] emits a harsh shutdown alarm!"))
	playsound(src, 'sound/machines/engine_alert1.ogg', 75, FALSE)

	update_reactor_icon()
	update_linked_consoles()


/*************************************************************
 * Rod Handling
 *************************************************************/

/// Insert rod into the proper bank
/obj/machinery/rbmk/reactor/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/rbmk/fuel_rod))
		return ..()

	var/obj/item/rbmk/fuel_rod/fuel_rod = item
	var/list/target_slots = get_target_slot_list(fuel_rod)

	if(target_slots == special_slots)
		if(length(special_slots) >= max_special_slots)
			to_chat(user, span_warning("All special rod slots are occupied!"))
			return TRUE
	else
		if(length(normal_slots) >= max_normal_slots)
			to_chat(user, span_warning("All normal rod slots are occupied!"))
			return TRUE

	if(!user.transferItemToLoc(fuel_rod, src))
		return TRUE

	target_slots += fuel_rod

	// Inserting rods means the reactor is no longer "off".
	// It stays non-running until process logic sees valid active rods.
	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		control_rod_depth = RBMK_CONTROL_ROD_MAX

	update_reactor_icon()
	update_linked_consoles()

	to_chat(user, span_notice("You insert [fuel_rod.name] into the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return TRUE

/// Default hand interaction: remove the last installed rod
/obj/machinery/rbmk/reactor/attack_hand(mob/user)
	if(!user)
		return

	remove_last_rod(user)

/// Removes the most recently installed rod, prioritizing special bank first
/obj/machinery/rbmk/reactor/proc/remove_last_rod(mob/user)
	var/obj/item/rbmk/fuel_rod/fuel_rod = null

	if(length(special_slots))
		fuel_rod = special_slots[length(special_slots)]
		special_slots -= fuel_rod
	else if(length(normal_slots))
		fuel_rod = normal_slots[length(normal_slots)]
		normal_slots -= fuel_rod
	else
		if(user)
			to_chat(user, span_notice("No rods installed."))
		return FALSE

	fuel_rod.forceMove(get_turf(src))

	if(user)
		to_chat(user, span_notice("You remove [fuel_rod.name] from the reactor."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!has_fuel_rods())
		reset_reaction_state()

	update_reactor_icon()
	update_linked_consoles()
	return TRUE

/// Removes a rod by bank + 1-based index, for console/TGUI use
/obj/machinery/rbmk/reactor/proc/remove_rod_by_slot(slot_kind, slot_index, mob/user = null)
	var/list/target_slots = null

	if(slot_kind == "special")
		target_slots = special_slots
	else
		target_slots = normal_slots

	if(!isnum(slot_index))
		return FALSE

	slot_index = round(slot_index)

	if(slot_index < 1 || slot_index > length(target_slots))
		return FALSE

	var/obj/item/rbmk/fuel_rod/fuel_rod = target_slots[slot_index]
	if(!fuel_rod)
		return FALSE

	target_slots -= fuel_rod
	fuel_rod.forceMove(get_turf(src))

	if(user)
		to_chat(user, span_notice("You remove [fuel_rod.name] from the reactor."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!has_fuel_rods())
		reset_reaction_state()

	update_reactor_icon()
	update_linked_consoles()
	return TRUE


/*************************************************************
 * Console Sync
 *************************************************************/

/// Update all linked RBMK consoles in range
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for(var/obj/machinery/computer/rbmk_console/console in range(7, src))
		if(console.linked_reactor == src)
			console.update_icon()
			SStgui.update_uis(console)
