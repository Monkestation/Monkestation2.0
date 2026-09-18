//Satyr Fluff
/datum/preference/choiced/satyr_fluff
	savefile_key = "feature_satyr_fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Fluff"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_fluff/init_possible_values()
	return assoc_to_keys_features(GLOB.satyr_fluff_list)

/datum/preference/choiced/satyr_fluff/icon_for(value)
	var/datum/sprite_accessory/satyr_fluff = GLOB.satyr_fluff_list[value]

	if(isnull(satyr_fluff) || satyr_fluff.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(satyr_fluff.icon, "m_satyr_fluff_[satyr_fluff.icon_state]_ADJ")

/datum/preference/choiced/satyr_fluff/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_fluff"] = value

//Satyr Tail
/datum/preference/choiced/satyr_tail
	savefile_key = "feature_satyr_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.satyr_tail_list)

/datum/preference/choiced/satyr_tail/icon_for(value)
	var/datum/sprite_accessory/satyr_tail = GLOB.satyr_tail_list[value]

	if(isnull(satyr_tail) || satyr_tail.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(satyr_tail.icon, "m_satyr_tail_[satyr_tail.icon_state]_BEHIND", NORTH)

/datum/preference/choiced/satyr_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_tail"] = value

//Satyr Horns
/datum/preference/choiced/satyr_horns
	savefile_key = "feature_satyr_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Satyr Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/satyr_horns/init_possible_values()
	return assoc_to_keys_features(GLOB.satyr_horns_list)

/datum/preference/choiced/satyr_horns/icon_for(value)
	var/datum/sprite_accessory/satyr_horns = GLOB.satyr_horns_list[value]

	if(isnull(satyr_horns) || satyr_horns.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(satyr_horns.icon, "m_satyr_horns_[satyr_horns.icon_state]_FRONT")

/datum/preference/choiced/satyr_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["satyr_horns"] = value
