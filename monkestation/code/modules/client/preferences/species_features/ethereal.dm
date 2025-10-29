/datum/preference/choiced/ethereal_horns
	savefile_key = "feature_ethereal_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ethereal Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/ethereal_horns/init_possible_values()
	return assoc_to_keys_features(GLOB.ethereal_horns_list)

/datum/preference/choiced/ethereal_horns/icon_for(value)
	var/datum/sprite_accessory/ethereal_horns = GLOB.ethereal_horns_list[value]
	if(ethereal_horns.icon_state == null || ethereal_horns.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(ethereal_horns.icon, "m_ethereal_horns_[ethereal_horns.icon_state]_FRONT")
	return final_icon

/datum/preference/choiced/ethereal_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethereal_horns"] = value

/datum/preference/choiced/ethereal_tail
	savefile_key = "feature_ethereal_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ethereal Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/ethereal_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.ethereal_tail_list)

/datum/preference/choiced/ethereal_tail/icon_for(value)
	var/datum/sprite_accessory/ethereal_tail = GLOB.ethereal_tail_list[value]
	if(ethereal_tail.icon_state == null || ethereal_tail.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(ethereal_tail.icon, "m_ethereal_tail_[ethereal_tail.icon_state]_BEHIND")
	final_icon.Blend(icon(ethereal_tail.icon, "m_ethereal_tail_[ethereal_tail.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/ethereal_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethereal_tail"] = value
