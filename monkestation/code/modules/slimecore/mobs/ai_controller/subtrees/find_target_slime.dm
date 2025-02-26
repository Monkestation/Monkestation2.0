/datum/ai_planning_subtree/slime_find_non_latched_target

/datum/ai_planning_subtree/slime_find_non_latched_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/slime_non_latched_target, BB_BASIC_MOB_CURRENT_TARGET, BB_SLIME_NON_LATCHED_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

// We need to have this as a subtype, so it has its own proximity monitor. If we don't allow it to
// have its own proximity monitor, then other uses of `find_potential_targets` with different
// targeting strategies will cause the same proximity monitor to be repeatedly overridden.
/datum/ai_behavior/find_potential_targets/slime_non_latched_target

/datum/ai_planning_subtree/slime_find_non_latched_target_and_smaller

/datum/ai_planning_subtree/slime_find_non_latched_target_and_smaller/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/slime_non_latched_target_and_smaller, BB_BASIC_MOB_CURRENT_TARGET, BB_SLIME_NON_LATCHED_AND_SMALLER_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

// Ditto.
/datum/ai_behavior/find_potential_targets/slime_non_latched_target_and_smaller
