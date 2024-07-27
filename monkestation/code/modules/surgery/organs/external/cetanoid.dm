/obj/item/organ/external/tail/cetanoid
	name = "cetanoid tail"
	desc = "A severed cetanoid tail."
	preference = "feature_cetanoid_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cetanoid

/datum/bodypart_overlay/mutant/tail/cetanoid
	feature_key = "cetanoid_tail"

/datum/bodypart_overlay/mutant/tail/cetanoid/get_global_feature_list()
	return GLOB.cetanoid_tail_list

/obj/item/organ/external/frills/cetanoid
	name = "cetanoid frills"
	preference = "feature_cetanoid_frills"

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills/cetanoid

/datum/bodypart_overlay/mutant/frills/cetanoid
	layers = EXTERNAL_ADJACENT
	feature_key = "cetanoid_frills"

/datum/bodypart_overlay/mutant/frills/cetanoid/get_global_feature_list()
	return GLOB.cetanoid_frills_list

/obj/item/organ/external/cetanoid_fins
	name = "cetanoid fins"
	icon_state = "spines"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_SPINES

	preference = "feature_cetanoid_fins"

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/cetanoid_fins

/datum/bodypart_overlay/mutant/cetanoid_fins
	layers = EXTERNAL_ADJACENT|EXTERNAL_BEHIND
	feature_key = "cetanoid_fins"

/datum/bodypart_overlay/mutant/cetanoid_fins/get_global_feature_list()
	return GLOB.cetanoid_fins_list

/datum/bodypart_overlay/mutant/cetanoid_fins/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
