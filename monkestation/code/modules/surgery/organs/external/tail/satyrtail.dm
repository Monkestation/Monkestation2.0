/obj/item/organ/external/tail/satyr_tail
	name = "satyr tail"
	desc = "A goat's tail"
	icon_state = "satyr_tail"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_tail"

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_tail

/datum/bodypart_overlay/mutant/satyr_tail
	layers = EXTERNAL_ADJACENT | EXTERNAL_BEHIND
	feature_key = "satyr_tail"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/satyr_tail/get_global_feature_list()
	return GLOB.satyr_tail_list

/datum/bodypart_overlay/mutant/satyr_tail/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE
