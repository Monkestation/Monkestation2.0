/**
 * AI controller
 */
/datum/ai_controller/basic_controller/killer_rabbit
	blackboard = list(
		BB_AGGRO_RANGE = 10,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/killer_rabbit,
	)

	ai_movement = /datum/ai_movement/navmap_astar
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/rabbit,
	)

/datum/targeting_strategy/basic/killer_rabbit/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	return ..(living_mob, the_target, 10)
