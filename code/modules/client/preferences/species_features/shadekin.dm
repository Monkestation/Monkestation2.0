/datum/preference/choiced/shadekin_tail
	savefile_key = "feature_shadekin_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Tail"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/tail/shadekin

/datum/preference/choiced/shadekin_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_shadekin)

/datum/preference/choiced/shadekin_tail/icon_for(value)
	var/datum/sprite_accessory/shadekin_tail = GLOB.tails_list_shadekin[value]

	if(isnull(shadekin_tail) || shadekin_tail.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(shadekin_tail.icon, "m_tail_shadekin_[shadekin_tail.icon_state]_BEHIND")

/datum/preference/choiced/shadekin_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_shadekin"] = value

/datum/preference/choiced/shadekin_ears/create_default_value()
	return "Shadekin Classic"
// shadekin ears
/datum/preference/choiced/shadekin_ears
	savefile_key = "feature_shadekin_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Protruding Ears"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/ears/shadekin

/datum/preference/choiced/shadekin_ears/init_possible_values()
	return assoc_to_keys_features(GLOB.ears_list_shadekin)

/datum/preference/choiced/shadekin_ears/icon_for(value)
	var/datum/sprite_accessory/shadekin_ears = GLOB.ears_list_shadekin[value]

	if(isnull(shadekin_ears) || shadekin_ears.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(shadekin_ears.icon, "m_ears_shadekin_[shadekin_ears.icon_state]_FRONT")

/datum/preference/choiced/shadekin_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears_shadekin"] = value

/datum/preference/choiced/shadekin_ears/create_default_value()
	return "Shadekin Classic Ears"
