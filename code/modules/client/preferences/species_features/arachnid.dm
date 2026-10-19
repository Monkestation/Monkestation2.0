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

	if(isnull(arachnid_appendages) || arachnid_appendages.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(arachnid_appendages.icon, "m_arachnid_appendages_[arachnid_appendages.icon_state]_BEHIND")

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
	var/static/datum/universal_icon/arachnid_head
	if(isnull(arachnid_head))
		arachnid_head = uni_icon('icons/mob/species/arachnid/bodyparts.dmi', "arachnid_head")
		arachnid_head.blend_color("#3e3143", ICON_MULTIPLY)
		arachnid_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/night_vision/arachnid::eye_icon_state]_l"), ICON_OVERLAY)
		arachnid_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/night_vision/arachnid::eye_icon_state]_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/arachnid_chelicerae = GLOB.arachnid_chelicerae_list[value]
	var/datum/universal_icon/icon_with_fang = arachnid_head.copy()

	if(!isnull(arachnid_chelicerae) && arachnid_chelicerae.icon_state != SPRITE_ACCESSORY_NONE)
		icon_with_fang.blend_icon(uni_icon(arachnid_chelicerae.icon, "m_arachnid_chelicerae_[arachnid_chelicerae.icon_state]_FRONT"), ICON_OVERLAY)
		icon_with_fang.scale(64, 64)
		icon_with_fang.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_fang

/datum/preference/choiced/arachnid_chelicerae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_chelicerae"] = value
