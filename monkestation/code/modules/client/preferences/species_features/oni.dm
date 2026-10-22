//Oni Tail
/datum/preference/choiced/oni_tail
	savefile_key = "feature_oni_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Oni Tail"
	should_generate_icons = TRUE

/datum/preference/choiced/oni_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.oni_tail_list)

/datum/preference/choiced/oni_tail/icon_for(value)
	var/datum/sprite_accessory/oni_tail = GLOB.oni_tail_list[value]
	if(oni_tail.icon_state == null || oni_tail.icon_state == "None")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(oni_tail.icon, "m_oni_tail_[oni_tail.icon_state]_BEHIND")
	final_icon.Blend(icon(oni_tail.icon, "m_oni_tail_[oni_tail.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/oni_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["oni_tail"] = value

//Oni Wings
/datum/preference/choiced/oni_wings
	savefile_key = "feature_oni_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Oni Wings"
	should_generate_icons = TRUE

/datum/preference/choiced/oni_wings/init_possible_values()
	return assoc_to_keys_features(GLOB.oni_wings_list)

/datum/preference/choiced/oni_wings/icon_for(value)
	var/datum/sprite_accessory/oni_wings = GLOB.oni_wings_list[value]
	if(oni_wings.icon_state == null || oni_wings.icon_state == "None")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(oni_wings.icon, "m_oni_wings_[oni_wings.icon_state]_BEHIND")
	final_icon.Blend(icon(oni_wings.icon, "m_oni_wings_[oni_wings.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/oni_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["oni_wings"] = value

//Oni Horns
/datum/preference/choiced/oni_horns
	savefile_key = "feature_oni_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Oni Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/oni_horns/init_possible_values()
	return assoc_to_keys_features(GLOB.oni_horns_list)

/datum/preference/choiced/oni_horns/icon_for(value)
	var/datum/sprite_accessory/oni_horns = GLOB.oni_horns_list[value]
	if(oni_horns.icon_state == null || oni_horns.icon_state == "None")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon
	if(icon_exists(oni_horns.icon, "m_oni_horns_[oni_horns.icon_state]_BEHIND"))
		final_icon = icon(oni_horns.icon, "m_oni_horns_[oni_horns.icon_state]_BEHIND")
		final_icon.Blend(icon(oni_horns.icon, "m_oni_horns_[oni_horns.icon_state]_FRONT"), ICON_OVERLAY)
	else
		final_icon = icon(oni_horns.icon, "m_oni_horns_[oni_horns.icon_state]_FRONT")
	return final_icon

/datum/preference/choiced/oni_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["oni_horns"] = value
