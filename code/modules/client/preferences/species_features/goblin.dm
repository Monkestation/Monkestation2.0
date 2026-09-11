/datum/preference/choiced/goblin_ears
	savefile_key = "feature_goblin_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Big Ears"
	should_generate_icons = TRUE

/datum/preference/choiced/goblin_ears/init_possible_values()
	return assoc_to_keys_features(GLOB.goblin_ears_list)

/datum/preference/choiced/goblin_ears/icon_for(value)
	var/static/datum/universal_icon/goblin_head

	if(isnull(goblin_head))
		goblin_head = uni_icon('icons/mob/species/goblin/bodyparts.dmi', "goblin_head", color = "#336919")
		var/datum/universal_icon/eyes = uni_icon('icons/mob/species/human/human_face.dmi', "eyes_l")
		eyes.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "eyes_r"), ICON_OVERLAY)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		goblin_head.blend_icon(eyes, ICON_OVERLAY)

	var/datum/sprite_accessory/goblin_ears = GLOB.goblin_ears_list[value]
	var/datum/universal_icon/final_icon = goblin_head.copy()

	final_icon.blend_icon(uni_icon(goblin_ears.icon, "m_goblin_ears_[goblin_ears.icon_state]_ADJ", color = "#336919"), ICON_OVERLAY)

	final_icon.scale(64, 64)
	final_icon.crop(15, 64 - 31, 15 + 31, 64)

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
	var/static/datum/universal_icon/goblin_side

	if(isnull(goblin_side))
		goblin_side = uni_icon('icons/mob/species/goblin/bodyparts.dmi', "goblin_head", EAST)
		goblin_side.blend_icon(uni_icon('icons/mob/species/goblin/goblin_ears.dmi', "m_goblin_ears_normal_ADJ", EAST), ICON_OVERLAY)
		goblin_side.blend_color("#336919", ICON_MULTIPLY)

		var/datum/universal_icon/eyes = uni_icon('icons/mob/species/human/human_face.dmi', "eyes_l", EAST)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		goblin_side.blend_icon(eyes, ICON_OVERLAY)

	var/datum/universal_icon/final_icon = goblin_side.copy()
	var/datum/sprite_accessory/goblin_nose = GLOB.goblin_nose_list[value]

	if(!isnull(goblin_nose) && goblin_nose.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/nose_icon = uni_icon(goblin_nose.icon, "m_goblin_nose_[goblin_nose.icon_state]_ADJ", EAST)
		nose_icon.blend_color("#336919", ICON_MULTIPLY)
		final_icon.blend_icon(nose_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/goblin_nose/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["goblin_nose"] = value
