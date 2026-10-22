/datum/preference/choiced/arachnid_appendages
	savefile_key = "feature_arachnid_appendages"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Appendages"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_appendages/init_possible_values()
	return assoc_to_keys_features(GLOB.arachnid_appendages_list)

/datum/preference/choiced/arachnid_appendages/icon_for(value)
	var/datum/sprite_accessory/arachnid_appendages = GLOB.arachnid_appendages_list[value]
	if(arachnid_appendages.icon_state == null || arachnid_appendages.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(arachnid_appendages.icon, "m_arachnid_appendages_[arachnid_appendages.icon_state]_BEHIND")
	final_icon.Blend(icon(arachnid_appendages.icon, "m_arachnid_appendages_[arachnid_appendages.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/arachnid_appendages/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_appendages"] = value

/datum/preference/choiced/arachnid_chelicerae
	savefile_key = "feature_arachnid_chelicerae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Chelicerae"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_chelicerae/init_possible_values()
	return assoc_to_keys_features(GLOB.arachnid_chelicerae_list)

/datum/preference/choiced/arachnid_chelicerae/icon_for(value)
	var/datum/sprite_accessory/arachnid_chelicerae = GLOB.arachnid_chelicerae_list[value]
	if(arachnid_chelicerae.icon_state == null || arachnid_chelicerae.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(arachnid_chelicerae.icon, "m_arachnid_chelicerae_[arachnid_chelicerae.icon_state]_BEHIND")
	final_icon.Blend(icon(arachnid_chelicerae.icon, "m_arachnid_chelicerae_[arachnid_chelicerae.icon_state]_FRONT"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/arachnid_chelicerae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_chelicerae"] = value
