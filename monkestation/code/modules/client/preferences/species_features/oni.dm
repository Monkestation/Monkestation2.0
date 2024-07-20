//Oni Tail
/datum/preference/choiced/oni_tail
	savefile_key = "feature_oni_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Oni Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/oni_tail/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.oni_tail_list,
		"oni_tail",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/oni_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["oni_tail"] = value

//Oni Horns
/datum/preference/choiced/oni_horns
	savefile_key = "feature_oni_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Oni Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/oni_horns/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.oni_horns_list,
		"oni_horns",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/oni_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["oni_horns"] = value
