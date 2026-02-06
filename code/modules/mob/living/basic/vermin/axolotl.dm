#define AXOLOTL_VOLUME				60
#define AXOLOTL_NOISE_COOLDOWN		1.5 SECONDS
#define AXOLOTL_FALLOFF_EXPONENT	20 // same as bike horn

/mob/living/basic/axolotl
	name = "axolotl"
	desc = "Quite the colorful amphibian!"
	icon_state = "axolotl"
	icon_living = "axolotl"
	icon_dead = "axolotl_dead"
	maxHealth = 10
	health = 10
	attack_verb_continuous = "nibbles" //their teeth are just for gripping food, not used for self defense nor even chewing
	attack_verb_simple = "nibble"
	butcher_results = list(/obj/item/food/nugget = 1)
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"

	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_lh = 'icons/mob/inhands/animal_item_lefthand.dmi'
	held_rh = 'icons/mob/inhands/animal_item_righthand.dmi'
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'

	ai_controller = /datum/ai_controller/basic_controller/axolotl

	var/stepped_sound = 'sound/effects/axolotl.ogg'
	COOLDOWN_DECLARE(axolotlspam_cooldown)

/mob/living/basic/axolotl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_AXOLOTL, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)


/mob/living/basic/axolotl/proc/on_entered(datum/source, mob/living/stepper)
	SIGNAL_HANDLER
	if(stat || !isliving(stepper) || stepper.mob_size <= MOB_SIZE_TINY || !COOLDOWN_FINISHED(src, axolotlspam_cooldown))
		return
	playsound(
		src,
		stepped_sound,
		vol = AXOLOTL_VOLUME,
		vary = TRUE,
		extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
		falloff_exponent = AXOLOTL_FALLOFF_EXPONENT,
		ignore_walls = FALSE, // do you want to hear this the next department over? doesnt matter bc im copying frog code.
		mixer_channel = CHANNEL_SQUEAK,
	)
	COOLDOWN_START(src, axolotlspam_cooldown, AXOLOTL_NOISE_COOLDOWN)

/mob/living/basic/axolotl/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(
		src,
		stepped_sound,
		vol = AXOLOTL_VOLUME,
		vary = TRUE,
		extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
		falloff_exponent = AXOLOTL_FALLOFF_EXPONENT,
		ignore_walls = FALSE,
		mixer_channel = CHANNEL_SQUEAK,
	)

/mob/living/basic/axolotl/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(src.stat == DEAD)
		return
	else
		playsound(
		src,
		stepped_sound,
		vol = AXOLOTL_VOLUME,
		vary = TRUE,
		extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
		falloff_exponent = AXOLOTL_FALLOFF_EXPONENT,
		ignore_walls = FALSE,
		mixer_channel = CHANNEL_SQUEAK,
	)

/datum/ai_controller/basic_controller/axolotl
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

#undef AXOLOTL_FALLOFF_EXPONENT
#undef AXOLOTL_NOISE_COOLDOWN
#undef AXOLOTL_VOLUME
