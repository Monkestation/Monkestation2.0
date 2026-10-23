/mob/living/basic/turtle
	name = "Frank"
	desc = "An adorable, slow moving, Texas pal."
	icon = 'icons/mob/pets.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow_dead"

	speak_emote = list("yawns")

	can_be_held = TRUE

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT

	melee_damage_lower = 1
	melee_damage_upper = 2
	health = 1000
	maxHealth = 1000
	speed = 4
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/clothing/head/cowboy/frank = 1)
	chat_color = "#E7D26F"

	ai_controller = /datum/ai_controller/basic_controller/turtle

/mob/living/basic/turtle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)

/obj/item/clothing/head/cowboy/frank
	name = "Frank's Hat"
	desc = "You feel ashamed about what you had to do to get this hat"

/datum/ai_controller/basic_controller/turtle
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/random_speech/turtle,
	)

/datum/ai_planning_subtree/random_speech/turtle
	speech_chance = 1
	emote_hear = list("snores.", "yawns.")
	emote_see = list("Stretches out their neck.", "looks around slowly.")
