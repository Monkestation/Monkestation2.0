/obj/item/organ/external/tail/cetanoid
	name = "cetanoid tail"
	desc = "A severed cetanoid tail."
	preference = "feature_cetanoid_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cetanoid

/datum/bodypart_overlay/mutant/tail/cetanoid
	feature_key = "tail_lizard"

/datum/bodypart_overlay/mutant/tail/cetanoid/get_global_feature_list()
	return GLOB.tails_list_cetanoid

/obj/item/organ/external/frills/cetanoid
	name = "cetanoid frills"
	preference = "feature_cetanoid_frills"

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills/cetanoid

/datum/bodypart_overlay/mutant/frills/cetanoid/get_global_feature_list()
	return GLOB.frills_list_cetanoid
