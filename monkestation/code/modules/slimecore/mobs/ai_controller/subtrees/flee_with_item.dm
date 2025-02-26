/// Find the nearest thing which we assume is hostile and set it as the flee target
/datum/ai_planning_subtree/slime_find_scared_item

/datum/ai_planning_subtree/slime_find_scared_item/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_SLIME_SCARED_ITEM_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

