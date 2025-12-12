/mob/living/basic/pet/pcreacher
	name = "pineapple creacher"
	desc = "A pineapple, given life. Science weeps."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "pcreacher"
	icon_living = "pcreacher"
	icon_dead = "pcreacher_dead"
	speak_emote = list("rumbles")
	butcher_results = list(/obj/item/food/pineappleslice)
	response_help_continuous = "pats"
	response_help_simple = "pat"
	response_disarm_continuous = "shoves aside"
	response_disarm_simple = "shove aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gender = NEUTER
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = NO_SPAWN
	can_be_held = FALSE
	density = FALSE
	melee_damage_lower = 3
	melee_damage_upper = 3
	attack_verb_continuous = "bludgeons"
	attack_verb_simple = "bludgeon"
	attack_sound = 'sound/weapons/smash.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	ai_controller = /datum/ai_controller/basic_controller/pcreacher

/mob/living/basic/pet/pcreacher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "rumbles gleefully!")
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/pcreacher
	blackboard = list(
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/ours_or_smaller,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
	)

