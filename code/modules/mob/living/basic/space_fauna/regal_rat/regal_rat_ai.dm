/datum/ai_controller/basic_controller/regal_rat
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/regal_rat/regal_rat.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
