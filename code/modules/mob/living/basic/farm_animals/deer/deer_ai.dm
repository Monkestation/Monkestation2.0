/datum/ai_controller/basic_controller/deer
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/deer/deer.bt.json"
	blackboard = list(
		BB_STATIONARY_MOVE_TO_TARGET = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Weeeeeeee?", "Weeee", "WEOOOOOOOOOO"),
			BB_EMOTE_HEAR = list("brays."),
			BB_EMOTE_SEE = list("shakes her head."),
			BB_SPEAK_CHANCE = 1,
		),
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
