/// Returns whether a rod belongs in the special slot bank.
/obj/machinery/rbmk/reactor/proc/is_special_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	return fuel_rod?.uses_special_slot

/// Returns the slot bank that owns the supplied rod type.
/obj/machinery/rbmk/reactor/proc/get_target_slot_list(obj/item/rbmk/fuel_rod/fuel_rod)
	if(is_special_rod(fuel_rod))
		return special_slots
	return normal_slots

/// Resolves a named slot-bank identifier into its owned list.
/obj/machinery/rbmk/reactor/proc/get_slot_list_by_kind(slot_kind)
	if(slot_kind == RBMK_ROD_SLOT_SPECIAL)
		return special_slots
	if(slot_kind == RBMK_ROD_SLOT_NORMAL)
		return normal_slots
	return null

/// Returns the installed supermatter rod, if the special bank contains one.
/obj/machinery/rbmk/reactor/proc/get_installed_supermatter_rod()
	for(var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod in special_slots)
		return installed_supermatter_rod
	return null

/// Starts a supermatter rod cascade once reactor activation conditions are met.
/obj/machinery/rbmk/reactor/proc/check_supermatter_rod_activation()
	if(supermatter_rod || meltdown_in_progress)
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
		if(installed_supermatter_rod.start_cascade(src))
			return TRUE
	return FALSE

/obj/machinery/rbmk/reactor/item_interaction(mob/living/user, obj/item/used_item, list/modifiers)
	if(istype(used_item, /obj/item/rbmk/rod_tool))
		var/obj/item/rbmk/rod_tool/rod_tool = used_item
		return try_remove_rod_with_tool(user, rod_tool)
	if(istype(used_item, /obj/item/rbmk/fuel_rod))
		return try_insert_fuel_rod(used_item, user)
	if(IS_EDIBLE(used_item))
		return try_add_griddled_item(used_item, user, modifiers)
	return ..()

/// Transfers a held rod into its owned bank after capacity and inventory validation.
/obj/machinery/rbmk/reactor/proc/try_insert_fuel_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user)
	if(!fuel_rod || !user)
		return ITEM_INTERACT_FAILURE
	var/had_active_fuel = has_active_fuel_rods()
	var/list/target_slots = get_target_slot_list(fuel_rod)
	if(target_slots == special_slots)
		if(length(special_slots) >= max_special_slots)
			to_chat(user, span_warning("All special rod slots are occupied!"))
			return ITEM_INTERACT_FAILURE
	else
		if(length(normal_slots) >= max_normal_slots)
			to_chat(user, span_warning("All normal rod slots are occupied!"))
			return ITEM_INTERACT_FAILURE
	if(!user.transferItemToLoc(fuel_rod, src))
		return ITEM_INTERACT_FAILURE
	target_slots += fuel_rod
	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		control_rod_depth = RBMK_CONTROL_ROD_MAX
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	to_chat(user, span_notice("You insert [fuel_rod.name] into the reactor."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	if(!had_active_fuel && !fuel_rod.is_depleted() && fuel_rod.contributes_to_reaction && actual_control_rod_depth < RBMK_CONTROL_ROD_MAX)
		var/rounded_rod_depth = round(actual_control_rod_depth, 1)
		var/obj/machinery/computer/rbmk_console/alert_console = get_primary_console()
		alert_console?.emit_local_alert("Criticality warning: active fuel loaded with control rods only [rounded_rod_depth]% inserted!", 'sound/rbmk/alarm.ogg', 85)
		rbmk_engineering_alert("CRITICALITY WARNING: Active fuel loaded into [src] in [get_area(src)] with control rods only [rounded_rod_depth]% inserted.")
		log_game("[key_name(user)] loaded [fuel_rod] into [src] with control rods at [rounded_rod_depth]% insertion.")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/rbmk/reactor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(has_fuel_rods())
		balloon_alert(user, "extractor required")
		to_chat(user, span_warning("You need an RBMK rod extractor to manually extract fuel rods."))
		return TRUE
	to_chat(user, span_notice("No rods installed."))
	return TRUE

/// Returns the next rod and slot metadata targeted by the manual extractor.
/obj/machinery/rbmk/reactor/proc/get_rod_tool_target_data()
	var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod = get_installed_supermatter_rod()
	if(installed_supermatter_rod)
		var/supermatter_slot_index = special_slots.Find(installed_supermatter_rod)
		if(supermatter_slot_index)
			return list(
				"rod" = installed_supermatter_rod,
				"slot_kind" = RBMK_ROD_SLOT_SPECIAL,
				"slot_index" = supermatter_slot_index,
			)
	if(length(special_slots))
		return list(
			"rod" = special_slots[length(special_slots)],
			"slot_kind" = RBMK_ROD_SLOT_SPECIAL,
			"slot_index" = length(special_slots),
		)
	if(length(normal_slots))
		return list(
			"rod" = normal_slots[length(normal_slots)],
			"slot_kind" = RBMK_ROD_SLOT_NORMAL,
			"slot_index" = length(normal_slots),
		)
	return null

/// Revalidates that an interruptible extraction still targets the same installed rod.
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

/// Returns the manual extraction duration for an ordinary, special, or cascading rod.
/obj/machinery/rbmk/reactor/proc/get_rod_tool_removal_time(obj/item/rbmk/fuel_rod/fuel_rod)
	if(fuel_rod == supermatter_rod)
		return RBMK_ROD_TOOL_REMOVE_TIME_CASCADE
	if(is_special_rod(fuel_rod))
		return RBMK_ROD_TOOL_REMOVE_TIME_SPECIAL
	return RBMK_ROD_TOOL_REMOVE_TIME_NORMAL

/// Returns a normalized measure of the reactor heat used by extraction knockback.
/obj/machinery/rbmk/reactor/proc/get_rod_extraction_heat_ratio()
	if(temperature <= RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP)
		return 0
	return CLAMP01((temperature - RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP) / 6000)

/// Applies heat-scaled blast effects around a completed emergency extraction.
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
		flash_range = flash_range,
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

/// Throws and disorients a living mob caught in an extraction blast.
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

/// Throws a movable non-living atom caught in an extraction blast.
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

/// Atomically removes the expected rod from a validated slot and hands it off for placement.
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

/// Places a removed rod into the user's hands or at a safe drop location.
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
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	return TRUE

/// Performs interruptible manual extraction with post-delay target revalidation.
/obj/machinery/rbmk/reactor/proc/try_remove_rod_with_tool(mob/living/user, obj/item/rbmk/rod_tool/tool)
	if(!user || !tool)
		return ITEM_INTERACT_FAILURE
	var/list/target_data = get_rod_tool_target_data()
	if(!target_data)
		balloon_alert(user, "no rod")
		return ITEM_INTERACT_FAILURE
	var/obj/item/rbmk/fuel_rod/fuel_rod = target_data["rod"]
	if(!fuel_rod)
		balloon_alert(user, "no rod")
		return ITEM_INTERACT_FAILURE
	var/slot_kind = target_data["slot_kind"]
	var/slot_index = target_data["slot_index"]
	var/cascade_extraction = (fuel_rod == supermatter_rod)
	var/removal_time = get_rod_tool_removal_time(fuel_rod)
	user.visible_message(
		span_notice("[user] starts extracting [fuel_rod] from [src]."),
		span_notice("You clamp the RBMK rod extractor onto [fuel_rod] and begin pulling it from [src]..."),
		span_hear("You hear heavy mechanical clamping."),
	)
	if(cascade_extraction)
		to_chat(user, span_danger("The supermatter rod fights the extractor. Keep pulling!"))
	else if(temperature >= RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP)
		to_chat(user, span_warning("The reactor is dangerously hot. Manual rod extraction may violently vent heat."))
	var/datum/callback/target_check = CALLBACK(src, PROC_REF(rod_tool_target_still_installed), slot_kind, slot_index, fuel_rod)
	if(!tool.use_tool(src, user, removal_time, volume = 40, extra_checks = target_check))
		return ITEM_INTERACT_FAILURE
	if(QDELETED(src) || QDELETED(user) || QDELETED(tool) || QDELETED(fuel_rod))
		return ITEM_INTERACT_FAILURE
	if(!finish_remove_rod_from_slot(slot_kind, slot_index, fuel_rod, user))
		balloon_alert(user, "failed")
		return ITEM_INTERACT_FAILURE
	apply_rod_tool_knockback(user, cascade_extraction)
	return ITEM_INTERACT_SUCCESS

/// Returns whether remote console extraction is safe in the reactor's current state.
/obj/machinery/rbmk/reactor/proc/can_remote_extract_rods(mob/user = null)
	if(meltdown_in_progress || supermatter_rod)
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

/// Removes a rod from a named slot bank through the console extraction path.
/obj/machinery/rbmk/reactor/proc/remove_rod_by_slot(slot_kind, slot_index, mob/user = null)
	if(!can_remote_extract_rods(user))
		return FALSE
	if(slot_kind != RBMK_ROD_SLOT_NORMAL && slot_kind != RBMK_ROD_SLOT_SPECIAL)
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
