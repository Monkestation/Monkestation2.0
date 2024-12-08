/// A mob spawned by the wraith
/mob/living/basic/wraith_spawn
	maxHealth = 100
	health = 100

	faction = list(FACTION_SPOOKY, FACTION_MIMIC)

	ai_controller = /datum/ai_controller/basic_controller/wraith_spawn

/**
 * This AI controller does jack shit
 */
/datum/ai_controller/basic_controller/wraith_spawn
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/no_target
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
