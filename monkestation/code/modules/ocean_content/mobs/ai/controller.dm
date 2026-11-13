/datum/ai_controller/basic_controller/fish
	blackboard = list(
		BB_GROUP_DATUM = null
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/datums/ai/basic_mobs/fish_group.bt.json"

/// Joins or makes a group, and starts the group's next move when it's time
/datum/bt_node/ai_behavior/group_planning
	time_between_perform = 1 SECONDS
	/// Type of group we look for or make
	var/group_type = /datum/group_planning

/datum/bt_node/ai_behavior/group_planning/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/group_planning/group = controller.blackboard[BB_GROUP_DATUM]
	if(QDELETED(group))
		group = find_group(controller)
		controller.set_blackboard_key(BB_GROUP_DATUM, group)
		group.group_mobs |= controller.pawn
	group.update(controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/group_planning/proc/find_group(datum/ai_controller/controller)
	for(var/mob/living/basic/found_basic in view(7, controller.pawn))
		var/datum/group_planning/found_group = found_basic.ai_controller?.blackboard[BB_GROUP_DATUM]
		if(!QDELETED(found_group) && found_group.type == group_type)
			return found_group
	return new group_type

/datum/bt_node/ai_behavior/group_planning/fish
	group_type = /datum/group_planning/fish

/// Tells the group this mob is done with the current move, whether it got there or not
/datum/bt_node/ai_behavior/group_move_done

/datum/bt_node/ai_behavior/group_move_done/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_GROUP_MOVE_TARGET)
	var/datum/group_planning/group = controller.blackboard[BB_GROUP_DATUM]
	group?.finish_action(controller)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
