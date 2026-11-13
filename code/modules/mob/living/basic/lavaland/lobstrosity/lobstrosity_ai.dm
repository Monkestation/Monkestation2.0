/datum/ai_controller/basic_controller/lobstrosity
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_LOBSTROSITY_EXPLOIT_TRAITS = list(TRAIT_INCAPACITATED, TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT),
		BB_LOBSTROSITY_FINGER_LUST = 0,
		BB_BASIC_MOB_FLEE_DISTANCE = 6,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)
	ai_traits = PAUSE_DURING_DO_AFTER

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/lobstrosity/lobstrosity.bt.json"
