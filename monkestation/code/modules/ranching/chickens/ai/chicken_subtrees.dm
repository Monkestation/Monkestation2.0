/// Picks who our targeted ability gets used on, see /mob/living/basic/chicken/proc/pick_ability_target()
/datum/bt_node/ai_behavior/chicken_pick_ability_target
	time_between_perform = 2 SECONDS
	var/target_key = BB_CHICKEN_ABILITY_TARGET

/datum/bt_node/ai_behavior/chicken_pick_ability_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/chicken/chicken_pawn = controller.pawn
	if(controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/atom/target = chicken_pawn.pick_ability_target(controller)
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Passes while we've got eggs left to lay
/datum/bt_node/decorator/chicken_has_eggs

/datum/bt_node/decorator/chicken_has_eggs/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/chicken/chicken_pawn = controller.pawn
	return chicken_pawn.eggs_left > 0

/datum/target_source/oview_single_type/chicken_feed/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = list()
	for(var/obj/effect/chicken_feed/candidate in oview(range, pawn))
		. += candidate

/datum/target_source/oview_single_type/nestbox/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	. = list()
	for(var/obj/structure/nestbox/candidate in oview(range, pawn))
		. += candidate
