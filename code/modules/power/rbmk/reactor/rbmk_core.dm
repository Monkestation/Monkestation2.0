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

	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

	var/list/coolant_pressure_history = list()
	var/list/coolant_temperature_history = list()
	var/list/coolant_total_moles_history = list()
	var/list/coolant_gas_hist = list()
	var/list/reactor_temperature_history = list()

	var/inlet_open = FALSE
	var/outlet_open = FALSE
	var/inlet_rate = RBMK_INLET_RATE_MIN
	var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE

	var/list/normal_slots = list()
	var/list/special_slots = list()
	var/max_normal_slots = 12
	var/max_special_slots = 4

	var/temperature = RBMK_AMBIENT_TEMP
	var/radiation = 0
	var/thermal_output = 0
	var/flux = 0
	var/void_coefficient = 0
	var/pressure = 0

	var/running = FALSE
	var/scrammed = FALSE

	/// Target rod depth set by the console
	var/control_rod_depth = 0
	/// Actual rod depth used by reactor physics
	var/actual_control_rod_depth = 0
	var/control_rod_step = 4
	var/scram_control_rod_step = 20

	var/reactor_integrity = RBMK_MAX_INTEGRITY
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY

	var/datum/gas_mixture/coolant_internal = null

	var/last_tick_flux = 0
	var/last_tick_temp_gain = 0
	var/last_tick_rod_count = 0

	var/current_damage_stage = 0
	var/image/current_damage_overlay_image = null

	var/datum/looping_sound/rbmk_reactor_low/low_soundloop = null
	var/datum/looping_sound/rbmk_reactor_high/high_soundloop = null

	var/startup_sequence_played = FALSE
	var/previous_control_rod_depth = RBMK_CONTROL_ROD_MAX
	var/rod_motion_in_progress = FALSE

	var/meltdown_announced = FALSE
	var/meltdown_in_progress = FALSE
	var/decay_meltdown_threshold = RBMK_TEMP_DAMAGE_RAMP
	var/decay_check_interval = 2 SECONDS
	var/last_decay_check = 0

	/// Whether normal reactor processing is paused by an active supermatter rod cascade.
	var/supermatter_cascade_active = FALSE

	/// Supermatter rod currently controlling the reactor cascade.
	var/obj/item/rbmk/fuel_rod/supermatter/supermatter_rod = null


/obj/machinery/rbmk/reactor/proc/has_fuel_rods()
	return (length(normal_slots) + length(special_slots)) > 0


/obj/machinery/rbmk/reactor/proc/has_active_fuel_rods()
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(fuel_rod?.active)
			return TRUE
	return FALSE


/obj/machinery/rbmk/reactor/proc/reset_reaction_state()
	running = FALSE
	flux = 0
	radiation = 0
	thermal_output = 0
	void_coefficient = 0
	last_tick_flux = 0
	last_tick_temp_gain = 0
	last_tick_rod_count = 0


/obj/machinery/rbmk/reactor/proc/is_special_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	return fuel_rod?.rod_type in list("plasma", "telecrystal", "supermatter")


/obj/machinery/rbmk/reactor/proc/get_target_slot_list(obj/item/rbmk/fuel_rod/fuel_rod)
	if(is_special_rod(fuel_rod))
		return special_slots

	return normal_slots


/obj/machinery/rbmk/reactor/proc/check_supermatter_rod_activation()
	if(supermatter_cascade_active || meltdown_in_progress)
		return FALSE

	if(!running)
		return FALSE

	if(temperature < 5000)
		return FALSE

	for(var/obj/item/rbmk/fuel_rod/supermatter/sm_rod in special_slots)
		if(!sm_rod)
			continue

		if(sm_rod.cascade_controller)
			continue

		supermatter_cascade_active = TRUE
		supermatter_rod = sm_rod
		sm_rod.start_cascade(src)
		return TRUE

	return FALSE


/obj/machinery/rbmk/reactor/ex_act(severity, target)
	if(meltdown_in_progress)
		return FALSE

	return ..()


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

	supermatter_cascade_active = FALSE
	supermatter_rod = null

	startup_sequence_played = FALSE
	previous_control_rod_depth = RBMK_CONTROL_ROD_MAX
	rod_motion_in_progress = FALSE

	var/turf/reactor_turf = get_turf(src)
	var/datum/gas_mixture/environment_mix = reactor_turf?.return_air()
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
	return INITIALIZE_HINT_NORMAL


/obj/machinery/rbmk/reactor/Destroy()
	if(supermatter_rod?.cascade_controller)
		supermatter_rod.stop_cascade(FALSE)

	supermatter_rod = null
	supermatter_cascade_active = FALSE

	if(low_soundloop)
		low_soundloop.stop()
	QDEL_NULL(low_soundloop)

	if(high_soundloop)
		high_soundloop.stop()
	QDEL_NULL(high_soundloop)

	rbmk_cleanup_atmos(src)
	return ..()


/obj/machinery/rbmk/reactor/proc/force_scram()
	if(meltdown_in_progress)
		return

	scrammed = TRUE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()
	startup_sequence_played = FALSE
	rod_motion_in_progress = FALSE

	visible_message(span_danger("[src] emits a harsh shutdown alarm!"))
	playsound(src, 'sound/machines/engine_alert1.ogg', 75, FALSE)

	update_reactor_icon()
	update_linked_consoles()


/obj/machinery/rbmk/reactor/item_interaction(mob/living/user, obj/item/used_item, list/modifiers)
	. = ..()
	if(.)
		return .

	if(!istype(used_item, /obj/item/rbmk/fuel_rod))
		return .

	return try_insert_fuel_rod(used_item, user)


/obj/machinery/rbmk/reactor/proc/try_insert_fuel_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user)
	if(!fuel_rod || !user)
		return ITEM_INTERACT_FAILURE

	var/list/target_slots = get_target_slot_list(fuel_rod)

	if(target_slots == special_slots)
		if(length(special_slots) >= max_special_slots)
			to_chat(user, span_warning("All special rod slots are occupied!"))
			return ITEM_INTERACT_SUCCESS
	else
		if(length(normal_slots) >= max_normal_slots)
			to_chat(user, span_warning("All normal rod slots are occupied!"))
			return ITEM_INTERACT_SUCCESS

	if(!user.transferItemToLoc(fuel_rod, src))
		return ITEM_INTERACT_SUCCESS

	target_slots += fuel_rod

	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		control_rod_depth = RBMK_CONTROL_ROD_MAX

	update_reactor_icon()
	update_linked_consoles()

	to_chat(user, span_notice("You insert [fuel_rod.name] into the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS


/obj/machinery/rbmk/reactor/attack_hand(mob/user)
	if(!user)
		return

	remove_last_rod(user)


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

	if(fuel_rod == supermatter_rod)
		var/obj/item/rbmk/fuel_rod/supermatter/sm_rod = fuel_rod
		sm_rod.stop_cascade(TRUE)

	fuel_rod.forceMove(drop_location())

	if(user)
		to_chat(user, span_notice("You remove [fuel_rod.name] from the reactor."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!has_fuel_rods())
		reset_reaction_state()
		startup_sequence_played = FALSE
		rod_motion_in_progress = FALSE

	update_reactor_icon()
	update_linked_consoles()
	return TRUE


/obj/machinery/rbmk/reactor/proc/remove_rod_by_slot(slot_kind, slot_index, mob/user = null)
	var/list/target_slots = (slot_kind == "special") ? special_slots : normal_slots

	if(!isnum(slot_index))
		return FALSE

	slot_index = round(slot_index)

	if(!ISINRANGE(slot_index, 1, length(target_slots)))
		return FALSE

	var/obj/item/rbmk/fuel_rod/fuel_rod = target_slots[slot_index]
	if(!fuel_rod)
		return FALSE

	if(fuel_rod == supermatter_rod)
		var/obj/item/rbmk/fuel_rod/supermatter/sm_rod = fuel_rod
		sm_rod.stop_cascade(TRUE)

	target_slots -= fuel_rod
	fuel_rod.forceMove(drop_location())

	if(user)
		to_chat(user, span_notice("You remove [fuel_rod.name] from the reactor."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!has_fuel_rods())
		reset_reaction_state()
		startup_sequence_played = FALSE
		rod_motion_in_progress = FALSE

	update_reactor_icon()
	update_linked_consoles()
	return TRUE


/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for(var/obj/machinery/computer/rbmk_console/console in range(7, src))
		if(console.linked_reactor == src)
			console.update_appearance()
			SStgui.update_uis(console)
