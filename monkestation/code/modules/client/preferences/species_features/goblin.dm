/datum/preference/choiced/goblin_ears
	savefile_key = "feature_goblin_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Big Ears"
	should_generate_icons = TRUE

/datum/preference/choiced/goblin_ears/init_possible_values()
	return assoc_to_keys_features(GLOB.goblin_ears_list)

/datum/preference/choiced/goblin_ears/icon_for(value)
	var/datum/sprite_accessory/goblin_ears = GLOB.goblin_ears_list[value]
	if(goblin_ears.icon_state == null || goblin_ears.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(goblin_ears.icon, "m_goblin_ears_[goblin_ears.icon_state]_ADJ")
	final_icon.Blend(icon(goblin_ears.icon, "m_goblin_ears_[goblin_ears.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/goblin_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["goblin_ears"] = value

/datum/preference/choiced/goblin_nose
	savefile_key = "feature_goblin_nose"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Goblin Nose"
	should_generate_icons = TRUE

/datum/preference/choiced/goblin_nose/init_possible_values()
	return assoc_to_keys_features(GLOB.goblin_nose_list)

/datum/preference/choiced/goblin_nose/icon_for(value)
	var/datum/sprite_accessory/goblin_nose = GLOB.goblin_nose_list[value]
	if(goblin_nose.icon_state == null || goblin_nose.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(goblin_nose.icon, "m_goblin_nose_[goblin_nose.icon_state]_ADJ")
	return final_icon

/datum/preference/choiced/goblin_nose/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["goblin_nose"] = value
