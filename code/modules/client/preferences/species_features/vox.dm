/datum/preference/choiced/head_quills
	savefile_key = "feature_head_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Head Quills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/head_quills

/datum/preference/choiced/head_quills/init_possible_values()
	return assoc_to_keys_features(GLOB.head_quills_list)

/datum/preference/choiced/head_quills/create_default_value()
	return pick(assoc_to_keys_features(GLOB.head_quills_list))

/datum/preference/choiced/head_quills/icon_for(value)
	var/datum/sprite_accessory/head_quills = GLOB.head_quills_list[value]
	if(head_quills.icon_state == null || head_quills.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(head_quills.icon, head_quills.icon_state)
	return final_icon

/datum/preference/choiced/head_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["head_quills"] = value

/datum/preference/choiced/face_quills
	savefile_key = "feature_face_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Face Quills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/face_quills

/datum/preference/choiced/face_quills/init_possible_values()
	return assoc_to_keys_features(GLOB.face_quills_list)

/datum/preference/choiced/face_quills/create_default_value()
	return pick(assoc_to_keys_features(GLOB.face_quills_list))

/datum/preference/choiced/face_quills/icon_for(value)
	var/datum/sprite_accessory/face_quills = GLOB.face_quills_list[value]
	if(face_quills.icon_state == null || face_quills.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(face_quills.icon, face_quills.icon_state)
	return final_icon

/datum/preference/choiced/face_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["face_quills"] = value

/datum/preference/choiced/vox_tail
	savefile_key = "feature_vox_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Vox Tail"
	should_generate_icons = TRUE
	relevant_external_organ =  /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_tail_list)

/datum/preference/choiced/vox_tail/icon_for(value)
	var/datum/sprite_accessory/vox_tail = GLOB.vox_tail_list[value]
	if(vox_tail.icon_state == null || vox_tail.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon
	var/icon/final_icon = icon(vox_tail.icon, vox_tail.icon_state)
	return final_icon

/datum/preference/choiced/vox_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail"] = value
