/datum/ai_controller/basic_controller/seedling
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/jungle/seedling/seedling.bt.json"

/datum/ai_controller/basic_controller/seedling/meanie
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	behavior_tree_json = "code/modules/mob/living/basic/jungle/seedling/seedling_meanie.bt.json"

///pet commands
/datum/pet_command/point_targeting/use_ability/solarbeam
	command_name = "Launch solarbeam"
	command_desc = "Command your pet to launch a solarbeam at your target!"
	radial_icon = 'icons/effects/beam.dmi'
	radial_icon_state = "solar_beam"
	speech_commands = list("beam", "solar")
	pet_ability_key = BB_SOLARBEAM_ABILITY

/datum/pet_command/point_targeting/use_ability/rapidseeds
	command_name = "Rapid seeds"
	command_desc = "Command your pet to launch a volley of seeds at your target!"
	radial_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	radial_icon_state = "seedling"
	speech_commands = list("rapid", "seeds", "volley")
	pet_ability_key = BB_RAPIDSEEDS_ABILITY
