/datum/preference/choiced/apid_wings
	savefile_key = "feature_apid_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid wings"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_wings/init_possible_values()
	return assoc_to_keys_features(GLOB.apid_wings_list)

/datum/preference/choiced/apid_wings/icon_for(value)
	var/datum/sprite_accessory/apid_wings = GLOB.apid_wings_list[value]

	if(isnull(apid_wings) || apid_wings.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(apid_wings.icon, "m_apid_wings_[apid_wings.icon_state]_FRONT")

/datum/preference/choiced/apid_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_wings"] = value

/datum/preference/choiced/apid_antenna
	savefile_key = "feature_apid_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Apid Antennae"
	should_generate_icons = TRUE

/datum/preference/choiced/apid_antenna/init_possible_values()
	return assoc_to_keys_features(GLOB.apid_antenna_list)

/datum/preference/choiced/apid_antenna/icon_for(value)
	var/static/datum/universal_icon/apid_head

	if(isnull(apid_head))
		apid_head = uni_icon('monkestation/code/modules/botany/icons/apid_sprites.dmi', "apid_head")
		apid_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/apid::eye_icon_state]_l"), ICON_OVERLAY)
		apid_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/apid::eye_icon_state]_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/antennae = GLOB.apid_antenna_list[value]
	var/datum/universal_icon/icon_with_antennae = apid_head.copy()

	if(!isnull(antennae) && antennae.icon_state != SPRITE_ACCESSORY_NONE)
		icon_with_antennae.blend_icon(uni_icon(antennae.icon, "m_apid_antenna_[antennae.icon_state]_ADJ"), ICON_OVERLAY)
		icon_with_antennae.scale(64, 64)
		icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_antennae

/datum/preference/choiced/apid_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["apid_antenna"] = value
