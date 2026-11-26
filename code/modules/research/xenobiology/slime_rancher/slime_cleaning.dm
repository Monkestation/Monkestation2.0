/// nutrition a dissolved mess gives, same as a wanted item
#define SLIME_CLEAN_NUTRITION 5
/// same as the clean finder's vision_range in slime.bt.json
#define SLIME_CLEAN_SCAN_RANGE 7

/mob/living/basic/slime
	/// Until this runs out, sees_mess_to_clean() reuses its last answer instead of scanning again
	COOLDOWN_DECLARE(mess_scan_reuse)
	/// Whether the last mess scan found any mess we'd go for
	var/mess_nearby = FALSE

/// Whether this is a mess a cleaner slime will eat.
/mob/living/basic/slime/proc/can_dissolve(atom/movable/mess)
	var/static/list/dissolvable_cache
	if(isnull(dissolvable_cache))
		dissolvable_cache = typecacheof(list(
			/obj/effect/decal/cleanable/ants,
			/obj/effect/decal/cleanable/ash,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/confetti,
			/obj/effect/decal/cleanable/dirt,
			/obj/effect/decal/cleanable/food,
			/obj/effect/decal/cleanable/fuel_pool,
			/obj/effect/decal/cleanable/generic,
			/obj/effect/decal/cleanable/glass,
			/obj/effect/decal/cleanable/glitter,
			/obj/effect/decal/cleanable/greenglow,
			/obj/effect/decal/cleanable/insectguts,
			/obj/effect/decal/cleanable/molten_object,
			/obj/effect/decal/cleanable/piss_stain,
			/obj/effect/decal/cleanable/shreds,
			/obj/effect/decal/cleanable/vomit,
			/obj/effect/decal/cleanable/wrapping,
			/obj/effect/decal/remains,
			/mob/living/basic/mouse,
			/mob/living/basic/cockroach,
			/obj/item/shard,
			/obj/item/food/breadslice/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/egg/rotten,
		))
		// stupid snowflake code to don't touch the slime mutation food subtypes
		for(var/slime_food_subtype in typesof(/mob/living/basic/cockroach/rockroach, /mob/living/basic/cockroach/iceroach, /mob/living/basic/cockroach/gemroach))
			dissolvable_cache[slime_food_subtype] = FALSE

	if(!isturf(mess.loc))
		return FALSE
	return is_type_in_typecache(mess, dissolvable_cache) || HAS_TRAIT(mess, TRAIT_TRASH_ITEM)

/// Sets cleaner_slime and resets the AI's cleaning state.
/mob/living/basic/slime/proc/set_cleaner_slime(enabled)
	cleaner_slime = !!enabled
	if(isnull(ai_controller))
		return
	ai_controller.cancel_current_plan()
	ai_controller.clear_blackboard_key(BB_SLIME_CLEAN_TARGET)
	ai_controller.clear_blackboard_key(BB_SLIME_ROAM_TARGET)
	ai_controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
	update_ai_movement_type()

/mob/living/basic/slime/get_access()
	. = ..()
	if(cleaner_slime)
		. |= ACCESS_MAINT_TUNNELS

/mob/living/basic/slime/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, cleaner_slime)) // special setter bc it messes with AI stuff
			set_cleaner_slime(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()

/// Eats a mess for nutrition. Returns TRUE if it did.
/mob/living/basic/slime/proc/try_dissolve(atom/movable/mess)
	if(!cleaner_slime || !can_dissolve(mess))
		return FALSE
	visible_message(span_notice("[src] dissolves \the [mess]."))
	balloon_alert_to_viewers("cleaned")
	qdel(mess)
	adjust_nutrition(SLIME_CLEAN_NUTRITION)
	return TRUE

/datum/target_source/slime_messes

/datum/target_source/slime_messes/collect_candidates(mob/living/basic/slime/pawn, datum/ai_controller/controller, range)
	. = list()
	var/list/messy_turfs = list()
	var/other_cleaner_around = FALSE
	for(var/atom/movable/candidate in oview(range, pawn))
		if(pawn.can_dissolve(candidate))
			. += candidate
			messy_turfs[candidate.loc] = TRUE
		else if(isslime(candidate))
			var/mob/living/basic/slime/other_slime = candidate
			other_cleaner_around ||= other_slime.cleaner_slime

	if(!controller.blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
		return
	// off to find someone, so we walk past messes unless it's a proper disaster nobody else is around to handle
	if(length(messy_turfs) < 15 || other_cleaner_around)
		return list()
	controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)

/// Whether there's a mess in view we'd go clean up, leaving out ones we gave up on or that are outside our pen.
/mob/living/basic/slime/proc/sees_mess_to_clean()
	if(!COOLDOWN_FINISHED(src, mess_scan_reuse))
		return mess_nearby
	COOLDOWN_START(src, mess_scan_reuse, 1 SECONDS)
	mess_nearby = FALSE
	var/datum/target_source/source = GET_TARGET_SOURCE(/datum/target_source/slime_messes)
	var/list/ignored = ai_controller?.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/atom/movable/mess as anything in source.collect_candidates(src, ai_controller, SLIME_CLEAN_SCAN_RANGE))
		if(LAZYACCESS(ignored, mess) || (pen && !pen.turfs[get_turf(mess)]))
			continue
		mess_nearby = TRUE
		break
	return mess_nearby

/datum/targeting_strategy/slime_mess

/datum/targeting_strategy/slime_mess/is_valid_target(mob/living/basic/slime/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return ismovable(target) && living_mob.can_dissolve(target)

/datum/bt_node/decorator/slime_is_cleaner

/datum/bt_node/decorator/slime_is_cleaner/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return istype(slime_pawn) && slime_pawn.cleaner_slime && !slime_pawn.is_latched() &&!IS_UNCONSCIOUS_OR_CRIT(slime_pawn)

/datum/bt_node/ai_behavior/dissolve_mess

/datum/bt_node/ai_behavior/dissolve_mess/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/movable/mess = controller.blackboard[BB_SLIME_CLEAN_TARGET]
	controller.clear_blackboard_key(BB_SLIME_CLEAN_TARGET)
	if(!istype(slime_pawn) || QDELETED(mess) || !slime_pawn.Adjacent(mess) || !slime_pawn.try_dissolve(mess))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

#undef SLIME_CLEAN_SCAN_RANGE
#undef SLIME_CLEAN_NUTRITION
