/obj/machinery/rbmk/reactor
	name = "RBMK Reactor Core"
	desc = "A massive nuclear reactor core. Insert rods at your own risk."
	icon = 'icons/obj/machines/rbmk_reactor.dmi'
	icon_state = "reactor_off"

	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32

	layer = 2.6
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
	var/inlet_rate = RBMK_INLET_RATE_DEFAULT
	var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_DEFAULT
	var/last_inlet_moles_moved = 0
	var/last_outlet_moles_moved = 0
	var/last_inlet_flow_rate = 0
	var/last_outlet_flow_rate = 0
	var/last_inlet_pressure = 0
	var/last_outlet_pressure = 0

	var/list/normal_slots = list()
	var/list/special_slots = list()
	var/max_normal_slots = 12
	var/max_special_slots = 4

	var/temperature = RBMK_AMBIENT_TEMP
	var/radiation = 0
	var/thermal_output = 0
	var/flux = 0
	var/void_coefficient = 0
	var/void_coefficient_temperature = 0
	var/void_coefficient_pressure = 0
	var/void_coefficient_coolant = 0
	var/last_void_flux_multiplier = 1
	var/pressure = 0

	var/running = FALSE
	var/scrammed = FALSE

	var/control_rod_depth = 0
	var/actual_control_rod_depth = 0
	var/control_rod_step = 4
	var/scram_control_rod_step = 20

	var/reactor_integrity = RBMK_MAX_INTEGRITY
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY
	var/last_integrity_damage = 0
	var/integrity_warning_started = FALSE
	var/list/active_welder_repairers = list()

	var/datum/gas_mixture/coolant_internal = null

	var/last_tick_flux = 0
	var/last_tick_base_flux = 0
	var/last_tick_void_flux_bonus = 0
	var/last_tick_temp_gain = 0
	var/last_coolant_exchange_ratio = 0
	var/last_coolant_core_temp_change = 0
	var/last_coolant_temperature_change = 0
	var/last_tick_rod_count = 0
	var/rod_temperature_limit_bonus = 0
	var/rod_coolant_exchange_bonus = 0
	var/rod_flux_multiplier_bonus = 0

	var/current_damage_stage = 0
	var/image/current_damage_overlay_image = null

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/warning_channel = RADIO_CHANNEL_ENGINEERING

	var/datum/looping_sound/rbmk_reactor/reactor_soundloop = null

	var/startup_sequence_played = FALSE
	var/previous_control_rod_depth = RBMK_CONTROL_ROD_MAX
	var/rod_motion_in_progress = FALSE

	var/meltdown_announced = FALSE
	var/meltdown_in_progress = FALSE
	var/meltdown_exploded = FALSE
	var/meltdown_supermatter_failure = FALSE
	var/decay_meltdown_threshold = RBMK_TEMP_DAMAGE_RAMP
	var/decay_check_interval = 2 SECONDS
	var/last_decay_check = 0

	var/last_flux_anomaly_spawn = 0
	var/flux_anomaly_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_LOW

	var/rbmk_fallout_active = FALSE
	var/rbmk_fallout_radius = 0
	var/rbmk_fallout_next_spread = 0

	var/supermatter_cascade_active = FALSE
	var/obj/item/rbmk/fuel_rod/supermatter/supermatter_rod = null


/obj/machinery/rbmk/reactor/proc/has_fuel_rods()
	return (length(normal_slots) + length(special_slots)) > 0


/obj/machinery/rbmk/reactor/proc/has_active_fuel_rods()
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(fuel_rod?.active && fuel_rod.contributes_to_reaction)
			return TRUE
	return FALSE


/obj/machinery/rbmk/reactor/proc/reset_reaction_state()
	running = FALSE
	flux = 0
	radiation = 0
	thermal_output = 0
	void_coefficient = 0
	void_coefficient_temperature = 0
	void_coefficient_pressure = 0
	void_coefficient_coolant = 0
	last_void_flux_multiplier = 1
	last_tick_flux = 0
	last_tick_base_flux = 0
	last_tick_void_flux_bonus = 0
	last_tick_temp_gain = 0
	last_coolant_exchange_ratio = 0
	last_coolant_core_temp_change = 0
	last_coolant_temperature_change = 0
	last_tick_rod_count = 0
	reset_reactor_modifier_state()


/obj/machinery/rbmk/reactor/proc/reset_reactor_modifier_state()
	rod_temperature_limit_bonus = 0
	rod_coolant_exchange_bonus = 0
	rod_flux_multiplier_bonus = 0


/obj/machinery/rbmk/reactor/proc/update_reactor_modifier_state(list/all_fuel_rods)
	reset_reactor_modifier_state()

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in all_fuel_rods)
		if(!fuel_rod?.active)
			continue

		var/list/modifier_output = fuel_rod.get_modifier_output()
		if(!islist(modifier_output))
			continue

		rod_temperature_limit_bonus += modifier_output["temperature_limit_bonus"] || 0
		rod_coolant_exchange_bonus += modifier_output["coolant_exchange_bonus"] || 0
		rod_flux_multiplier_bonus += modifier_output["flux_multiplier_bonus"] || 0

	rod_temperature_limit_bonus = clamp(rod_temperature_limit_bonus, 0, RBMK_MODIFIER_PLASMA_TEMP_LIMIT_BONUS_MAX)
	rod_coolant_exchange_bonus = clamp(rod_coolant_exchange_bonus, 0, RBMK_MODIFIER_BLUESPACE_COOLANT_BONUS_MAX)
	rod_flux_multiplier_bonus = clamp(rod_flux_multiplier_bonus, 0, RBMK_MODIFIER_DIAMOND_FLUX_MULT_BONUS_MAX)


/obj/machinery/rbmk/reactor/proc/get_effective_temp_stress_threshold()
	return RBMK_TEMP_STRESS_THRESHOLD + rod_temperature_limit_bonus


/obj/machinery/rbmk/reactor/proc/get_effective_temp_damage_threshold()
	return RBMK_TEMP_DAMAGE_RAMP + rod_temperature_limit_bonus


/obj/machinery/rbmk/reactor/proc/get_effective_decay_meltdown_threshold()
	return decay_meltdown_threshold + rod_temperature_limit_bonus


/obj/machinery/rbmk/reactor/proc/start_reactor_sound()
	if(reactor_soundloop)
		return reactor_soundloop

	reactor_soundloop = new /datum/looping_sound/rbmk_reactor(src, TRUE)
	return reactor_soundloop


/obj/machinery/rbmk/reactor/proc/stop_reactor_sound()
	if(reactor_soundloop)
		reactor_soundloop.stop()

	QDEL_NULL(reactor_soundloop)


/obj/machinery/rbmk/reactor/proc/set_reactor_sound_state(new_state)
	if(!reactor_soundloop)
		start_reactor_sound()

	if(!reactor_soundloop)
		return

	reactor_soundloop.set_sound_state(new_state)


/obj/machinery/rbmk/reactor/proc/is_special_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	return fuel_rod?.rod_type in list("plasma", "bluespace", "diamond", "supermatter")


/obj/machinery/rbmk/reactor/proc/get_target_slot_list(obj/item/rbmk/fuel_rod/fuel_rod)
	if(is_special_rod(fuel_rod))
		return special_slots

	return normal_slots


/obj/machinery/rbmk/reactor/proc/get_slot_list_by_kind(slot_kind)
	if(slot_kind == "special")
		return special_slots

	if(slot_kind == "normal")
		return normal_slots

	return null


/obj/machinery/rbmk/reactor/proc/get_installed_supermatter_rod()
	for(var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod in special_slots)
		return installed_supermatter_rod

	return null


/obj/machinery/rbmk/reactor/proc/check_supermatter_rod_activation()
	if(supermatter_cascade_active || meltdown_in_progress)
		return FALSE

	if(!running)
		return FALSE

	if(temperature < 5000)
		return FALSE

	for(var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod in special_slots)
		if(!installed_supermatter_rod)
			continue

		if(installed_supermatter_rod.cascade_controller)
			continue

		supermatter_cascade_active = TRUE
		supermatter_rod = installed_supermatter_rod
		installed_supermatter_rod.start_cascade(src)
		return TRUE

	return FALSE


/obj/machinery/rbmk/reactor/ex_act(severity, target)
	return FALSE


/obj/machinery/rbmk/reactor/deconstruct(disassembled = TRUE)
	return


/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()

	reactor_integrity = RBMK_MAX_INTEGRITY
	max_reactor_integrity = RBMK_MAX_INTEGRITY
	last_integrity_damage = 0
	integrity_warning_started = FALSE
	active_welder_repairers = list()
	control_rod_depth = 0
	actual_control_rod_depth = 0
	last_inlet_moles_moved = 0
	last_outlet_moles_moved = 0
	last_inlet_flow_rate = 0
	last_outlet_flow_rate = 0
	last_inlet_pressure = 0
	last_outlet_pressure = 0

	reset_reaction_state()
	scrammed = FALSE
	meltdown_announced = FALSE
	meltdown_in_progress = FALSE
	meltdown_exploded = FALSE
	meltdown_supermatter_failure = FALSE
	last_decay_check = 0

	rbmk_fallout_active = FALSE
	rbmk_fallout_radius = 0
	rbmk_fallout_next_spread = 0
	GLOB.rbmk_fallout_reactors -= src

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

	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

	rbmk_init_coolant()
	relink_ports()

	update_reactor_icon()
	return INITIALIZE_HINT_NORMAL


/obj/machinery/rbmk/reactor/Destroy()
	if(supermatter_rod?.cascade_controller)
		supermatter_rod.stop_cascade(FALSE)

	supermatter_rod = null
	supermatter_cascade_active = FALSE
	active_welder_repairers = null
	GLOB.rbmk_fallout_reactors -= src

	QDEL_NULL(radio)
	stop_reactor_sound()

	rbmk_cleanup_atmos()
	return ..()


/obj/machinery/rbmk/reactor/proc/force_scram()
	if(meltdown_in_progress)
		return

	scrammed = TRUE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()
	stop_reactor_sound()
	startup_sequence_played = FALSE
	rod_motion_in_progress = FALSE

	visible_message(span_danger("[src] emits a harsh shutdown alarm!"))
	playsound(src, 'sound/rbmk/alarm.ogg', 75, FALSE)

	update_reactor_icon()
	update_linked_consoles()


/obj/machinery/rbmk/reactor/welder_act(mob/living/user, obj/item/tool)
	if(!user || !tool)
		return ITEM_INTERACT_FAILURE

	if(!active_welder_repairers)
		active_welder_repairers = list()

	if(user in active_welder_repairers)
		balloon_alert(user, "already repairing")
		return ITEM_INTERACT_SUCCESS

	if(!tool.tool_start_check(user, amount = RBMK_WELDER_REPAIR_FUEL_COST))
		return ITEM_INTERACT_SUCCESS

	if(!can_welder_repair(user, TRUE))
		return ITEM_INTERACT_SUCCESS

	active_welder_repairers += user

	user.visible_message(
		span_notice("[user] starts repairing [src]'s damaged casing."),
		span_notice("You begin repairing [src]'s damaged casing..."),
		span_hear("You hear welding.")
	)

	INVOKE_ASYNC(src, PROC_REF(welder_repair_loop), user, tool)

	return ITEM_INTERACT_SUCCESS


/obj/machinery/rbmk/reactor/proc/can_welder_repair(mob/living/user, show_alerts = FALSE)
	if(meltdown_in_progress || supermatter_cascade_active)
		if(show_alerts)
			balloon_alert(user, "too unstable!")
		return FALSE

	if(reactor_integrity <= 0)
		if(show_alerts)
			balloon_alert(user, "beyond repair!")
		return FALSE

	if(temperature > RBMK_REPAIRABLE_TEMP_LIMIT)
		if(show_alerts)
			balloon_alert(user, "too hot!")
			to_chat(user, span_warning("[src] is too hot to safely repair. It must be below [RBMK_REPAIRABLE_TEMP_LIMIT] K."))
		return FALSE

	if(reactor_integrity >= max_reactor_integrity)
		if(show_alerts)
			balloon_alert(user, "fully repaired")
		return FALSE

	return TRUE


/obj/machinery/rbmk/reactor/proc/finish_welder_repair(mob/living/user)
	if(!active_welder_repairers || !user)
		return

	active_welder_repairers -= user


/obj/machinery/rbmk/reactor/proc/welder_repair_loop(mob/living/user, obj/item/tool)
	if(QDELETED(src))
		return

	if(QDELETED(user) || QDELETED(tool))
		finish_welder_repair(user)
		return

	if(!active_welder_repairers || !(user in active_welder_repairers))
		return

	if(!can_welder_repair(user, TRUE))
		finish_welder_repair(user)
		return

	if(!tool.use_tool(src, user, RBMK_WELDER_REPAIR_TIME, volume = 40, amount = RBMK_WELDER_REPAIR_FUEL_COST))
		finish_welder_repair(user)
		return

	if(!can_welder_repair(user, TRUE))
		finish_welder_repair(user)
		return

	var/old_integrity = reactor_integrity
	reactor_integrity = min(reactor_integrity + RBMK_WELDER_REPAIR_AMOUNT, max_reactor_integrity)

	var/repaired_amount = reactor_integrity - old_integrity
	if(repaired_amount <= 0)
		finish_welder_repair(user)
		balloon_alert(user, "fully repaired")
		return

	balloon_alert(user, "repaired")
	to_chat(user, span_notice("You repair [src]'s casing integrity by [round(repaired_amount, 0.1)]%."))

	update_reactor_icon()
	update_linked_consoles()

	if(reactor_integrity >= max_reactor_integrity)
		integrity_warning_started = FALSE
		finish_welder_repair(user)

		user.visible_message(
			span_notice("[user] finishes repairing [src]'s casing."),
			span_notice("You finish repairing [src]'s casing.")
		)
		return

	INVOKE_ASYNC(src, PROC_REF(welder_repair_loop), user, tool)


/obj/machinery/rbmk/reactor/item_interaction(mob/living/user, obj/item/used_item, list/modifiers)
	if(istype(used_item, /obj/item/rbmk/rod_tool))
		var/obj/item/rbmk/rod_tool/rod_tool = used_item
		return try_remove_rod_with_tool(user, rod_tool)

	if(istype(used_item, /obj/item/rbmk/fuel_rod))
		return try_insert_fuel_rod(used_item, user)

	return ..()


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

	if(has_fuel_rods())
		balloon_alert(user, "extractor required")
		to_chat(user, span_warning("You need an RBMK rod extractor to manually extract fuel rods."))
		return

	to_chat(user, span_notice("No rods installed."))


/obj/machinery/rbmk/reactor/proc/get_rod_tool_target()
	var/list/target_data = get_rod_tool_target_data()
	if(!target_data)
		return null

	return target_data["rod"]


/obj/machinery/rbmk/reactor/proc/get_rod_tool_target_data()
	var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod = get_installed_supermatter_rod()
	if(installed_supermatter_rod)
		var/supermatter_slot_index = special_slots.Find(installed_supermatter_rod)
		if(supermatter_slot_index)
			return list(
				"rod" = installed_supermatter_rod,
				"slot_kind" = "special",
				"slot_index" = supermatter_slot_index,
			)

	if(length(special_slots))
		return list(
			"rod" = special_slots[length(special_slots)],
			"slot_kind" = "special",
			"slot_index" = length(special_slots),
		)

	if(length(normal_slots))
		return list(
			"rod" = normal_slots[length(normal_slots)],
			"slot_kind" = "normal",
			"slot_index" = length(normal_slots),
		)

	return null


/obj/machinery/rbmk/reactor/proc/rod_tool_target_still_installed(slot_kind, slot_index, obj/item/rbmk/fuel_rod/expected_rod)
	if(QDELETED(expected_rod))
		return FALSE

	var/list/target_slots = get_slot_list_by_kind(slot_kind)
	if(!target_slots)
		return FALSE

	if(!isnum(slot_index))
		return FALSE

	slot_index = round(slot_index)

	if(!ISINRANGE(slot_index, 1, length(target_slots)))
		return FALSE

	if(target_slots[slot_index] != expected_rod)
		return FALSE

	return expected_rod.loc == src


/obj/machinery/rbmk/reactor/proc/get_rod_tool_removal_time(obj/item/rbmk/fuel_rod/fuel_rod)
	if(fuel_rod == supermatter_rod && supermatter_cascade_active)
		return RBMK_ROD_TOOL_REMOVE_TIME_CASCADE

	if(is_special_rod(fuel_rod))
		return RBMK_ROD_TOOL_REMOVE_TIME_SPECIAL

	return RBMK_ROD_TOOL_REMOVE_TIME_NORMAL


/obj/machinery/rbmk/reactor/proc/get_rod_extraction_heat_ratio()
	if(temperature <= RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP)
		return 0

	return CLAMP01((temperature - RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP) / 6000)


/obj/machinery/rbmk/reactor/proc/apply_rod_tool_knockback(mob/living/user, cascade_extraction = FALSE)
	if(!cascade_extraction && temperature <= RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP)
		return

	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	var/heat_ratio = get_rod_extraction_heat_ratio()

	var/blast_range
	var/throw_speed
	var/heavy_impact_range
	var/light_impact_range
	var/flash_range
	var/disorient_time
	var/stamina_damage

	if(cascade_extraction)
		blast_range = clamp(round(RBMK_ROD_TOOL_CASCADE_KNOCKBACK_RANGE + 2 + (heat_ratio * 4)), RBMK_ROD_TOOL_CASCADE_KNOCKBACK_RANGE, 12)
		throw_speed = clamp(round(4 + (heat_ratio * 4)), 4, 8)
		heavy_impact_range = clamp(round(1 + heat_ratio), 1, 2)
		light_impact_range = clamp(round(3 + (heat_ratio * 3)), 3, 6)
		flash_range = clamp(round(5 + (heat_ratio * 5)), 5, 10)
		disorient_time = (6 SECONDS) + round(heat_ratio * 8 SECONDS)
		stamina_damage = -round(25 + (heat_ratio * 35))
	else
		blast_range = clamp(round(RBMK_ROD_TOOL_HOT_KNOCKBACK_RANGE + (heat_ratio * 4)), RBMK_ROD_TOOL_HOT_KNOCKBACK_RANGE, 8)
		throw_speed = clamp(round(2 + (heat_ratio * 3)), 2, 5)
		heavy_impact_range = heat_ratio >= 0.85 ? 1 : 0
		light_impact_range = clamp(round(1 + (heat_ratio * 3)), 1, 4)
		flash_range = clamp(round(2 + (heat_ratio * 4)), 2, 6)
		disorient_time = (2 SECONDS) + round(heat_ratio * 4 SECONDS)
		stamina_damage = -round(8 + (heat_ratio * 22))

	if(cascade_extraction)
		visible_message(span_danger("[src] erupts in a violent supermatter pressure discharge as the rod is extracted!"))
	else
		visible_message(span_danger("[src] violently vents superheated pressure as the rod is extracted!"))

	playsound(src, 'sound/effects/explosion1.ogg', cascade_extraction ? 100 : 80, TRUE)

	explosion(
		source_turf,
		devastation_range = 0,
		heavy_impact_range = heavy_impact_range,
		light_impact_range = light_impact_range,
		flash_range = flash_range
	)

	for(var/mob/living/living_mob in view(blast_range, source_turf))
		if(QDELETED(living_mob))
			continue

		var/distance_from_reactor = max(get_dist(source_turf, living_mob), 1)
		var/effective_throw_range = max(blast_range - distance_from_reactor + 1, 1)

		if(living_mob == user)
			effective_throw_range += cascade_extraction ? 3 : 1

		blast_throw_living(living_mob, effective_throw_range, throw_speed, stamina_damage, disorient_time)

	for(var/atom/movable/movable_atom in view(blast_range, source_turf))
		if(QDELETED(movable_atom))
			continue

		if(movable_atom == src)
			continue

		if(ismob(movable_atom))
			continue

		if(movable_atom.anchored)
			continue

		var/distance_from_reactor = max(get_dist(source_turf, movable_atom), 1)
		var/effective_throw_range = max(blast_range - distance_from_reactor + 1, 1)

		blast_throw_atom(movable_atom, effective_throw_range, throw_speed)


/obj/machinery/rbmk/reactor/proc/blast_throw_living(mob/living/living_mob, throw_range, throw_speed, stamina_damage, disorient_time)
	if(!living_mob || QDELETED(living_mob))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/mob_turf = get_turf(living_mob)
	if(!source_turf || !mob_turf)
		return

	var/throw_dir = get_dir(source_turf, mob_turf)
	if(!throw_dir)
		throw_dir = pick(NORTH, SOUTH, EAST, WEST)

	var/turf/target_turf = get_edge_target_turf(living_mob, throw_dir)
	if(!target_turf)
		return

	shake_camera(living_mob, 0.2 SECONDS, 5)
	living_mob.Disorient(disorient_time)
	living_mob.stamina.adjust(stamina_damage)

	living_mob.throw_at(target_turf, throw_range, throw_speed, src)


/obj/machinery/rbmk/reactor/proc/blast_throw_atom(atom/movable/thrown_atom, throw_range, throw_speed)
	if(!thrown_atom || QDELETED(thrown_atom))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/atom_turf = get_turf(thrown_atom)
	if(!source_turf || !atom_turf)
		return

	var/throw_dir = get_dir(source_turf, atom_turf)
	if(!throw_dir)
		throw_dir = pick(NORTH, SOUTH, EAST, WEST)

	var/turf/target_turf = get_edge_target_turf(thrown_atom, throw_dir)
	if(!target_turf)
		return

	thrown_atom.throw_at(target_turf, throw_range, throw_speed, src)


/obj/machinery/rbmk/reactor/proc/finish_remove_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user = null)
	if(!fuel_rod)
		return FALSE

	var/special_slot_index = special_slots.Find(fuel_rod)
	if(special_slot_index)
		return finish_remove_rod_from_slot("special", special_slot_index, fuel_rod, user)

	var/normal_slot_index = normal_slots.Find(fuel_rod)
	if(normal_slot_index)
		return finish_remove_rod_from_slot("normal", normal_slot_index, fuel_rod, user)

	return FALSE


/obj/machinery/rbmk/reactor/proc/finish_remove_rod_from_slot(slot_kind, slot_index, obj/item/rbmk/fuel_rod/expected_rod = null, mob/user = null)
	var/list/target_slots = get_slot_list_by_kind(slot_kind)
	if(!target_slots)
		return FALSE

	if(!isnum(slot_index))
		return FALSE

	slot_index = round(slot_index)

	if(!ISINRANGE(slot_index, 1, length(target_slots)))
		return FALSE

	var/obj/item/rbmk/fuel_rod/fuel_rod = target_slots[slot_index]
	if(!fuel_rod || QDELETED(fuel_rod))
		return FALSE

	if(expected_rod && fuel_rod != expected_rod)
		return FALSE

	if(fuel_rod.loc != src)
		return FALSE

	target_slots.Cut(slot_index, slot_index + 1)
	return finish_removed_rod(fuel_rod, user)


/obj/machinery/rbmk/reactor/proc/finish_removed_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user = null)
	if(fuel_rod == supermatter_rod)
		var/obj/item/rbmk/fuel_rod/supermatter/removed_supermatter_rod = fuel_rod
		removed_supermatter_rod.stop_cascade(TRUE)

	fuel_rod.forceMove(drop_location())

	if(user)
		to_chat(user, span_notice("You remove [fuel_rod.name] from the reactor."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)

	if(!has_fuel_rods())
		reset_reaction_state()
		stop_reactor_sound()
		startup_sequence_played = FALSE
		rod_motion_in_progress = FALSE

	update_reactor_icon()
	update_linked_consoles()
	return TRUE


/obj/machinery/rbmk/reactor/proc/try_remove_rod_with_tool(mob/living/user, obj/item/rbmk/rod_tool/tool)
	if(!user || !tool)
		return ITEM_INTERACT_FAILURE

	var/list/target_data = get_rod_tool_target_data()
	if(!target_data)
		balloon_alert(user, "no rod")
		return ITEM_INTERACT_SUCCESS

	var/obj/item/rbmk/fuel_rod/fuel_rod = target_data["rod"]
	if(!fuel_rod)
		balloon_alert(user, "no rod")
		return ITEM_INTERACT_SUCCESS

	var/slot_kind = target_data["slot_kind"]
	var/slot_index = target_data["slot_index"]
	var/cascade_extraction = (fuel_rod == supermatter_rod && supermatter_cascade_active)
	var/removal_time = get_rod_tool_removal_time(fuel_rod)

	user.visible_message(
		span_notice("[user] starts extracting [fuel_rod] from [src]."),
		span_notice("You clamp the RBMK rod extractor onto [fuel_rod] and begin pulling it from [src]..."),
		span_hear("You hear heavy mechanical clamping.")
	)

	if(cascade_extraction)
		to_chat(user, span_danger("The supermatter rod fights the extractor. Keep pulling!"))
	else if(temperature >= RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP)
		to_chat(user, span_warning("The reactor is dangerously hot. Manual rod extraction may violently vent heat."))

	var/datum/callback/target_check = CALLBACK(src, PROC_REF(rod_tool_target_still_installed), slot_kind, slot_index, fuel_rod)
	if(!tool.use_tool(src, user, removal_time, volume = 40, extra_checks = target_check))
		return ITEM_INTERACT_SUCCESS

	if(QDELETED(fuel_rod))
		return ITEM_INTERACT_SUCCESS

	if(!finish_remove_rod_from_slot(slot_kind, slot_index, fuel_rod, user))
		balloon_alert(user, "failed")
		return ITEM_INTERACT_SUCCESS

	apply_rod_tool_knockback(user, cascade_extraction)

	return ITEM_INTERACT_SUCCESS


/obj/machinery/rbmk/reactor/proc/remove_last_rod(mob/user)
	if(user)
		balloon_alert(user, "extractor required")
		to_chat(user, span_warning("You need an RBMK rod extractor to manually extract fuel rods."))

	return FALSE


/obj/machinery/rbmk/reactor/proc/can_remote_extract_rods(mob/user = null)
	if(meltdown_in_progress || supermatter_cascade_active)
		if(user)
			balloon_alert(user, "locked out")
			to_chat(user, span_warning("Remote rod extraction is locked out by unsafe reactor conditions. Use a rod extractor."))
		playsound(src, 'sound/machines/click.ogg', 35, TRUE)
		return FALSE

	if(temperature >= RBMK_ROD_CONSOLE_SAFE_TEMP_LIMIT)
		if(user)
			balloon_alert(user, "too hot")
			to_chat(user, span_warning("Remote rod extraction is unsafe at or above [RBMK_ROD_CONSOLE_SAFE_TEMP_LIMIT] K. Use a rod extractor."))
		playsound(src, 'sound/machines/click.ogg', 35, TRUE)
		return FALSE

	return TRUE


/obj/machinery/rbmk/reactor/proc/remove_rod_by_slot(slot_kind, slot_index, mob/user = null)
	if(!can_remote_extract_rods(user))
		return FALSE

	if(slot_kind != "normal" && slot_kind != "special")
		return FALSE

	var/list/target_slots = get_slot_list_by_kind(slot_kind)
	if(!target_slots)
		return FALSE

	if(!isnum(slot_index))
		return FALSE

	slot_index = round(slot_index)

	if(!ISINRANGE(slot_index, 1, length(target_slots)))
		return FALSE

	var/obj/item/rbmk/fuel_rod/fuel_rod = target_slots[slot_index]
	if(!fuel_rod)
		return FALSE

	var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod = get_installed_supermatter_rod()
	if(installed_supermatter_rod && fuel_rod != installed_supermatter_rod)
		if(user)
			balloon_alert(user, "supermatter first")
			to_chat(user, span_warning("The supermatter rod is resonating too violently. It must be removed before any other rods can be handled."))
		return FALSE

	return finish_remove_rod_from_slot(slot_kind, slot_index, fuel_rod, user)


/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for(var/obj/machinery/computer/rbmk_console/console in range(7, src))
		if(console.linked_reactor == src)
			console.update_appearance()
			SStgui.update_uis(console)
