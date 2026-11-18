/mob/living/basic/pet/hamster
	name = "\improper hamster"
	real_name = "hamster"
	desc = "It's a hamster."
	icon = 'icons/mob/pets.dmi'
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	held_state = "hamster"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "bites"
	response_harm_simple = "bite"
	speak_emote = list("squeak", "hisses", "squeals")
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/food/meat/slab = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	held_lh = 'icons/mob/pets_held_lh.dmi'
	held_rh = 'icons/mob/pets_held_rh.dmi'
	ai_controller = /datum/ai_controller/basic_controller/hamster

/mob/living/basic/pet/hamster/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/can_be_held)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/pet/hamster)),\
		baby_path = /mob/living/basic/pet/hamster,\
	)

/datum/ai_controller/basic_controller/hamster
	behavior_tree_json = "monkestation/code/modules/mob/living/basic/pets/hamster.bt.json"
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

/// Hamsters squeak now and then
/datum/bt_node/ai_behavior/random_speech/hamster
	speech_chance = 1
	speak = list("Squeak", "SQUEAK!")
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("skitters.", "examines its claws.", "rolls around.")
