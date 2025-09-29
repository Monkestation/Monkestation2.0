// Color
/datum/preference/choiced/beefman_color
	savefile_key = "feature_beef_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman color"
	should_generate_icons = TRUE

/datum/preference/choiced/beefman_color/has_relevant_feature(datum/preferences/preferences)
	// Skips checks for relevant_organ, relevant trait etc. because ethereal color is tied directly to species (atm)
	return current_species_has_savekey(preferences)

/datum/preference/choiced/beefman_color/init_possible_values()
	return assoc_to_keys(GLOB.color_list_beefman)

/datum/preference/choiced/beefman_color/icon_for(value)
	var/static/datum/universal_icon/beefman_base
	if(isnull(beefman_base))
		beefman_base = uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_head")
		beefman_base.blend_icon(uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_chest"), ICON_OVERLAY)
		beefman_base.blend_icon(uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_l_arm"), ICON_OVERLAY)
		beefman_base.blend_icon(uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_r_arm"), ICON_OVERLAY)

		var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes_l")
		eyes.blend_icon(uni_icon('icons/mob/human/human_face.dmi', "eyes_r"), ICON_OVERLAY)
		eyes.blend_color(COLOR_BLACK, ICON_MULTIPLY)
		beefman_base.blend_icon(eyes, ICON_OVERLAY)

		beefman_base.scale(64, 64)
		beefman_base.crop(15, 64 - 31, 15 + 31, 64)
	var/color = GLOB.color_list_beefman[value]

	var/datum/universal_icon/icon = beefman_base.copy()
	icon.blend_color("[color]", ICON_MULTIPLY)

	return icon

/datum/preference/choiced/beefman_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_color"] = GLOB.color_list_beefman[value]

// Eyes
/datum/preference/choiced/beefman_eyes
	savefile_key = "feature_beef_eyes"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman Eyes"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/beefman_eyes

/datum/preference/choiced/beefman_eyes/init_possible_values()
	return assoc_to_keys(SSaccessories.eyes_beefman_list)

/datum/preference/choiced/beefman_eyes/icon_for(value)
	var/static/datum/universal_icon/beef_head
	if(isnull(beef_head))
		beef_head = uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_head")
		beef_head.blend_color("#d93356", ICON_MULTIPLY) // Make it red at least

	var/datum/sprite_accessory/eyes = SSaccessories.eyes_beefman_list[value]

	var/datum/universal_icon/icon_with_eye = beef_head.copy()
	icon_with_eye.blend_icon(uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "[eyes.icon_state]_head"), ICON_OVERLAY)
	icon_with_eye.scale(64, 64)
	icon_with_eye.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_eye

/datum/preference/choiced/beefman_eyes/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_eyes"] = value

// Mouth
/datum/preference/choiced/beefman_mouth
	savefile_key = "feature_beef_mouth"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Beefman Mouth"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/beefman_mouth

/datum/preference/choiced/beefman_mouth/init_possible_values()
	return assoc_to_keys(SSaccessories.mouths_beefman_list)

/datum/preference/choiced/beefman_mouth/icon_for(value)
	var/datum/universal_icon/beef_head
	if(isnull(beef_head))
		beef_head = uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "beefman_head")
		beef_head.blend_color("#d93356", ICON_MULTIPLY) // Make it red at least

	var/datum/sprite_accessory/mouths = SSaccessories.mouths_beefman_list[value]

	var/datum/universal_icon/icon_with_mouth = beef_head.copy()
	icon_with_mouth.blend_icon(uni_icon('fulp_modules/icons/species/mob/beefman_bodyparts.dmi', "[mouths.icon_state]_head"), ICON_OVERLAY)
	icon_with_mouth.scale(64, 64)
	icon_with_mouth.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_mouth

/datum/preference/choiced/beefman_mouth/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["beef_mouth"] = value
