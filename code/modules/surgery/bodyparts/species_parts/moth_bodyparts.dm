#define BRUTE_MOD 1.15
#define BURN_MOD 1.15
#define WOUND_RES_LIMB_MALUS -10 // ouch
#define WOUND_RES_CORE_MALUS -20 // ouch!!!

/obj/item/bodypart/head/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS |HEAD_EYESPRITES |HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_HAIR
	bodypart_traits = list(TRAIT_ANTENNAE)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/head::wound_resistance + WOUND_RES_CORE_MALUS

/obj/item/bodypart/chest/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	wing_types = list(/obj/item/organ/external/wings/functional/moth/megamoth, /obj/item/organ/external/wings/functional/moth/mothra)
	bodypart_traits = list(TRAIT_TACKLING_WINGED_ATTACKER)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/chest::wound_resistance + WOUND_RES_CORE_MALUS
	can_be_disabled = TRUE // to allow disabling the chest arms

	VAR_PRIVATE/obj/item/bodypart/arm/left/moth/inner/left_inner
	VAR_PRIVATE/obj/item/bodypart/arm/right/moth/inner/right_inner

/obj/item/bodypart/chest/moth/Initialize(mapload)
	. = ..()
	left_inner = new(src)
	right_inner = new(src)
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/moth_arms())
	RegisterSignal(left_inner, COMSIG_BODYPART_POST_REMOVED, PROC_REF(slurp_up_limbs))
	RegisterSignal(right_inner, COMSIG_BODYPART_POST_REMOVED, PROC_REF(slurp_up_limbs))

/obj/item/bodypart/chest/moth/Destroy()
	. = ..() // lets on_removal() drop the arms from our owner first
	QDEL_NULL(left_inner)
	QDEL_NULL(right_inner)

/obj/item/bodypart/chest/moth/proc/slurp_up_limbs(datum/source, mob/living/carbon/owner, special, dismembered)
	SIGNAL_HANDLER

	astype(source, /obj/item/bodypart/arm)?.forceMove(src)

/obj/item/bodypart/chest/moth/set_disabled(new_disabled, update_limbs)
	. = ..()
	left_inner.set_disabled(new_disabled, update_limbs)
	right_inner.set_disabled(new_disabled, update_limbs)

/obj/item/bodypart/chest/moth/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(!.)
		return

	attach_inner_arms(new_owner)

/obj/item/bodypart/chest/moth/on_body_created(mob/living/carbon/new_owner)
	attach_inner_arms(new_owner)

/// Gives our owner the two extra hands and attaches the chest arms to them
/obj/item/bodypart/chest/moth/proc/attach_inner_arms(mob/living/carbon/new_owner)
	new_owner.change_number_of_hands(4)
	left_inner.try_attach_limb(new_owner, special = TRUE)
	right_inner.try_attach_limb(new_owner, special = TRUE)

/obj/item/bodypart/chest/moth/on_removal()
	var/mob/living/carbon/old_owner = owner
	for(var/obj/item/bodypart/arm/inner_arm as anything in list(left_inner, right_inner))
		if(isnull(inner_arm))
			continue
		inner_arm.drop_limb(special = TRUE, dismembered = FALSE, move_to_floor = FALSE)
		// special drops keep the hand slot for the arm that replaces it, nothing replaces these
		if(length(old_owner.hand_bodyparts) >= inner_arm.held_index && old_owner.hand_bodyparts[inner_arm.held_index] == inner_arm)
			old_owner.hand_bodyparts[inner_arm.held_index] = null
	old_owner.change_number_of_hands(2)
	return ..()

/obj/item/bodypart/arm/left/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/arm/left::wound_resistance + WOUND_RES_LIMB_MALUS

/obj/item/bodypart/arm/right/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/arm/right::wound_resistance + WOUND_RES_LIMB_MALUS

/obj/item/bodypart/leg/left/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	should_draw_greyscale = FALSE
	limb_id = SPECIES_MOTH
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/leg/left::wound_resistance + WOUND_RES_LIMB_MALUS

/obj/item/bodypart/leg/right/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	should_draw_greyscale = FALSE
	limb_id = SPECIES_MOTH
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

	brute_modifier = BRUTE_MOD
	burn_modifier = BURN_MOD
	wound_resistance = /obj/item/bodypart/leg/right::wound_resistance + WOUND_RES_LIMB_MALUS

/obj/item/bodypart/arm/left/moth/inner
	body_zone = null
	held_index = 3
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_ABSTRACT | BODYPART_VIRGIN
	plaintext_zone = "left chest-arm"

/obj/item/bodypart/arm/left/moth/inner/Initialize(mapload)
	name = "left chest-arm"
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 2, "south" = -2, "east" = 2, "west" = -8),
		offset_y = list("south" = -12), // shhh
	)
	return ..()

/obj/item/bodypart/arm/left/moth/inner/drop_limb(special, dismembered, violent, move_to_floor = TRUE)
	if(special)
		return ..()
	return FALSE

/obj/item/bodypart/arm/left/moth/inner/generate_icon_key()
	return list()

/obj/item/bodypart/arm/right/moth/inner
	body_zone = null
	held_index = 4
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_ABSTRACT | BODYPART_VIRGIN
	plaintext_zone = "right chest-arm"

/obj/item/bodypart/arm/right/moth/inner/Initialize(mapload)
	name = "right chest-arm"
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = -2, "south" = 2, "east" = 8, "west" = -2),
		offset_y = list("south" = -12),
	)
	return ..()

/obj/item/bodypart/arm/right/moth/inner/drop_limb(special, dismembered, violent, move_to_floor = TRUE)
	if(special)
		return ..()
	return FALSE

/obj/item/bodypart/arm/right/moth/inner/generate_icon_key()
	return list()

// TODO: should be mutant overlay at some point?
/datum/bodypart_overlay/simple/moth_arms
	layers = EXTERNAL_FRONT
	icon = 'icons/mob/species/moth/moth_arms.dmi'
	icon_state = "m_moth_arms_generic_FRONT"

#undef BRUTE_MOD
#undef BURN_MOD
#undef WOUND_RES_LIMB_MALUS
#undef WOUND_RES_CORE_MALUS
