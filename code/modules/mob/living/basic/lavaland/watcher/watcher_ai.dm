/datum/ai_controller/basic_controller/watcher
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/watcher/watcher.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
