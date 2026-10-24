/obj/item/organ/external/ethereal_horns
	name = "ethereal horns"
	desc = "These seemingly decorative horns are actually sensory organs, albiet somewhat vegistal ones in their current environment, for detecting nearby electromagnetic fields. They are also extremely sensitive, a fact that which whatever poor ethereal you took these from is probably heavily aware of."
	icon_state = "ethereal_horns"
	icon = 'icons/obj/medical/organs/organs.dmi'

	preference = "feature_ethereal_horns"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/ethereal_horns

/datum/bodypart_overlay/mutant/ethereal_horns
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
	)
	feature_key = "ethereal_horns"
	palette = /datum/color_palette/generic_colors
	palette_key = "ethereal_color"

/datum/bodypart_overlay/mutant/ethereal_horns/get_global_feature_list()
	return GLOB.ethereal_horns_list

/datum/bodypart_overlay/mutant/ethereal_horns/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE

/obj/item/organ/external/tail/ethereal
	name = "ethereal tail"
	desc = "A severed ethereal tail, it reminds you of a bundle of fiber optic cable."
	icon_state = "ethereal_horns"
	icon = 'icons/obj/medical/organs/organs.dmi'

	preference = "feature_ethereal_tail"

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/ethereal

/datum/bodypart_overlay/mutant/tail/ethereal
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)
	feature_key = "ethereal_tail"
	palette = /datum/color_palette/generic_colors
	palette_key = "ethereal_color"

/datum/bodypart_overlay/mutant/tail/ethereal/get_global_feature_list()
	return GLOB.ethereal_tail_list
