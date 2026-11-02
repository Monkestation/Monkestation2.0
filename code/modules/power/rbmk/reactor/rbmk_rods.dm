/** Returns whether a rod belongs in the special slot bank. */
/obj/machinery/rbmk/reactor/proc/is_special_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	return fuel_rod?.uses_special_slot

/** Returns the slot bank used by the supplied rod. */
/obj/machinery/rbmk/reactor/proc/get_target_slot_list(obj/item/rbmk/fuel_rod/fuel_rod)
	if(is_special_rod(fuel_rod))
		return special_slots
	return normal_slots

/** Resolves a slot-bank identifier into its owned list. */
/obj/machinery/rbmk/reactor/proc/get_slot_list_by_kind(slot_kind)
	if(slot_kind == RBMK_ROD_SLOT_SPECIAL)
		return special_slots
	if(slot_kind == RBMK_ROD_SLOT_NORMAL)
		return normal_slots
	return null

/** Returns the installed supermatter rod, if present. */
/obj/machinery/rbmk/reactor/proc/get_installed_supermatter_rod()
	for(var/obj/item/rbmk/fuel_rod/supermatter/installed_supermatter_rod in special_slots)
		return installed_supermatter_rod
	return null

/** Starts a supermatter cascade once its activation conditions are met. */
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

/** Validates and transfers a held rod into its reactor slot bank. */
/obj/machinery/rbmk/reactor/proc/try_insert_fuel_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user)
	if(!fuel_rod || !user)
		return ITEM_INTERACT_FAILURE
	var/had_active_fuel = has_active_fuel_rods()
	var/list/target_slots = get_target_slot_list(fuel_rod)
	if(target_slots == special_slots)
		if(length(special_slots) >= max_special_slots)
			to_chat(user, span_warning("All moderator rod slots are occupied!"))
			return ITEM_INTERACT_FAILURE
	else
		if(length(normal_slots) >= max_normal_slots)
			to_chat(user, span_warning("All fuel rod slots are occupied!"))
			return ITEM_INTERACT_FAILURE
	if(!user.transferItemToLoc(fuel_rod, src))
		return ITEM_INTERACT_FAILURE
	target_slots += fuel_rod
	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		control_rod_depth = RBMK_CONTROL_ROD_MAX
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	to_chat(user, span_notice("You insert [fuel_rod.name] into the reactor."))
	playsound(src, 'sound/effects/compressed_air/tank_insert_clunky.ogg', 65, TRUE)
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

/** Returns the rod and slot currently targeted by the manual extractor. */
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

/** Revalidates an extraction target after an interruptible action. */
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

/** Returns the manual extraction time for the supplied rod. */
/obj/machinery/rbmk/reactor/proc/get_rod_tool_removal_time(obj/item/rbmk/fuel_rod/fuel_rod)
	if(fuel_rod == supermatter_rod)
		return RBMK_ROD_TOOL_REMOVE_TIME_CASCADE
	if(is_special_rod(fuel_rod))
		return RBMK_ROD_TOOL_REMOVE_TIME_SPECIAL
	return RBMK_ROD_TOOL_REMOVE_TIME_NORMAL

/** Returns the current vessel-to-room pressure differential for rod extraction. */
/obj/machinery/rbmk/reactor/proc/get_rod_extraction_pressure_delta()
	var/turf/source_turf = get_turf(src)
	var/datum/gas_mixture/environment = source_turf?.return_air()
	return (coolant_internal?.return_pressure() || 0) - (environment?.return_pressure() || 0)

/** Throws the operator away from the vessel using the pipe pressure-release model. */
/obj/machinery/rbmk/reactor/proc/apply_rod_tool_knockback(mob/living/user, cascade_extraction = FALSE)
	if(!user || QDELETED(user) || !coolant_internal)
		return
	var/turf/source_turf = get_turf(src)
	var/pressure_delta = get_rod_extraction_pressure_delta()
	if(!source_turf || pressure_delta < 250)
		return
	// Match pressurized pipe unwrenching: pressure-resistant footing holds
	// until the differential would otherwise fling the operator forty tiles.
	if(HAS_TRAIT(user, TRAIT_PRESSURE_FLING_RESISTANT) && pressure_delta / 250 < 40)
		return
	user.visible_message(
		span_danger("[user] is sent flying by a pressure discharge from [src]!"),
		span_userdanger("The escaping pressure sends you flying!"),
	)
	playsound(src, 'sound/machines/steam_hiss.ogg', 65, TRUE)
	var/throw_direction = get_dir(source_turf, user) || pick(GLOB.cardinals)
	var/throw_range = clamp(pressure_delta / 250, 1, cascade_extraction ? 12 : 8)
	var/throw_speed = clamp(pressure_delta / 1250, 1, cascade_extraction ? 8 : 5)
	user.throw_at(get_edge_target_turf(user, throw_direction), throw_range, throw_speed, src)

/** Removes a validated rod from its slot and passes it to final placement. */
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

/** Places a removed rod in the user's hands or at a safe drop location. */
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

/** Performs manual rod extraction with post-delay revalidation. */
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
	else if(get_rod_extraction_pressure_delta() >= 250)
		to_chat(user, span_warning("The reactor is pressurized. Manual rod extraction may send you flying!"))
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

/** Returns whether console rod extraction is safe in the current state. */
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

/** Removes a rod from a named slot bank through the console. */
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
