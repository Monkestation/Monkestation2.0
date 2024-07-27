/datum/preference/choiced/cetanoid_tail
	savefile_key = "feature_cetanoid_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Cetanoid Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/cetanoid_tail/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.cetanoid_tail_list,
		"cetanoid_tail",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/cetanoid_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["cetanoid_tail"] = value

/datum/preference/choiced/cetanoid_frills
	savefile_key = "feature_cetanoid_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Cetanoid Frills"
	should_generate_icons = TRUE

/datum/preference/choiced/cetanoid_frills/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.cetanoid_frills_list,
		"cetanoid_frills",
		list("ADJ"),
	)

/datum/preference/choiced/cetanoid_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["cetanoid_frills"] = value

/datum/preference/choiced/cetanoid_fins
	savefile_key = "feature_cetanoid_fins"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Cetanoid Fins"
	should_generate_icons = TRUE

/datum/preference/choiced/cetanoid_fins/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.cetanoid_fins_list,
		"cetanoid_fins",
		list("BEHIND","ADJ"),
	)

/datum/preference/choiced/cetanoid_fins/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["cetanoid_fins"] = value
