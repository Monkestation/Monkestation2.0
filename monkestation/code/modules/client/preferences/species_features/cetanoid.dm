/datum/preference/choiced/cetanoid_tail
	savefile_key = "feature_cetanoid_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Cetanoid Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/cetanoid_tail/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.tails_list_cetanoid,
		"cetanoid_tail",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/cetanoid_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/datum/preference/choiced/cetanoid_frills
	savefile_key = "feature_cetanoid_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Cetanoid Frills"
	should_generate_icons = TRUE

/datum/preference/choiced/cetanoid_frills/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.frills_list_cetanoid,
		"cetanoid_frills",
		list("ADJ"),
	)

/datum/preference/choiced/cetanoid_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills"] = value
