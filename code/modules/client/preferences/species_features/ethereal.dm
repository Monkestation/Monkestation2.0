/datum/preference/choiced/ethereal_color
	savefile_key = "feature_ethcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ethereal color"
	should_generate_icons = TRUE

/datum/preference/choiced/ethereal_color/init_possible_values()
	return assoc_to_keys(GLOB.color_list_ethereal)

/datum/preference/choiced/ethereal_color/icon_for(value)
	var/static/datum/universal_icon/ethereal_base
	if (isnull(ethereal_base))
		ethereal_base = uni_icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_head_m")
		ethereal_base.blend_icon(uni_icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_chest_m"), ICON_OVERLAY)
		ethereal_base.blend_icon(uni_icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_l_arm"), ICON_OVERLAY)
		ethereal_base.blend_icon(uni_icon('icons/mob/species/ethereal/bodyparts.dmi', "ethereal_r_arm"), ICON_OVERLAY)

		var/datum/universal_icon/eyes = uni_icon('icons/mob/species/human/human_face.dmi', "etherealeyes_l")
		eyes.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "etherealeyes_r"), ICON_OVERLAY)
		eyes.blend_color(COLOR_BLACK, ICON_MULTIPLY)
		ethereal_base.blend_icon(eyes, ICON_OVERLAY)

		ethereal_base.scale(64, 64)
		ethereal_base.crop(15, 64 - 31, 15 + 31, 64)

	var/datum/universal_icon/icon = ethereal_base.copy()
	icon.blend_color(GLOB.color_list_ethereal[value], ICON_MULTIPLY)
	return icon

/datum/preference/choiced/ethereal_color/apply_to_human(mob/living/carbon/human/target, value)
	return

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

	if(isnull(ethereal_horns) || ethereal_horns.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon('icons/mob/species/ethereal/ethereal_horns.dmi', "m_ethereal_horns_[ethereal_horns.icon_state]_ADJ")

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

	if(isnull(ethereal_tail) || ethereal_tail.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon('icons/mob/species/ethereal/ethereal_tail.dmi', "m_ethereal_tail_[ethereal_tail.icon_state]_BEHIND")

/datum/preference/choiced/ethereal_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ethereal_tail"] = value
