/// Try to line up with a cardinal direction of your target
/datum/ai_planning_subtree/move_to_cardinal
	/// Behaviour to execute to line ourselves up
	var/move_behaviour = /datum/ai_behavior/move_to_cardinal
	/// Blackboard key in which to store selected target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/move_to_cardinal/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(target_key))
		return
	controller.queue_behavior(move_behaviour, target_key)

/// Try to line up with a cardinal direction of your target
/datum/ai_behavior/move_to_cardinal
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How close to our target is too close?
	var/minimum_distance = 1
	/// How far away is too far?
	var/maximum_distance = 9

/datum/ai_behavior/move_to_cardinal/setup(datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	target_nearest_cardinal(controller, target)
	return TRUE

/// Set our movement target to the closest cardinal space to our target
/datum/ai_behavior/move_to_cardinal/proc/target_nearest_cardinal(datum/ai_controller/controller, atom/target)



/datum/ai_behavior/move_to_cardinal/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target))
		finish_action(controller = controller, succeeded = FALSE, target_key = target_key)
		return
	if (!(get_dir(controller.pawn, target) in GLOB.cardinals))
		target_nearest_cardinal(controller, target)
		return
	var/distance_to_target = get_dist(controller.pawn, target)
	if (distance_to_target < minimum_distance)
		target_nearest_cardinal(controller, target)
		return
	if (distance_to_target > maximum_distance)
		return
	finish_action(controller = controller, succeeded = TRUE, target_key = target_key)
	return

/datum/ai_behavior/move_to_cardinal/finish_action(datum/ai_controller/controller, succeeded, target_key)
	if (!succeeded)
		controller.clear_blackboard_key(target_key)
	return ..()
