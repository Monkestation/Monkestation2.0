
/datum/preference/color/anime_color
	savefile_key = "feature_animecolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/anime_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/anime_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["animecolor"] = value

/datum/preference/color/anime_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE

/datum/preference/color/anime_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_top
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Top"
	savefile_key = "feature_anime_top"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_top/init_possible_values()
	return assoc_to_keys_features(GLOB.anime_top_list)

/datum/preference/choiced/anime_top/icon_for(value)
	var/static/datum/universal_icon/head_icon

	if(isnull(head_icon))
		head_icon = uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_head_m")
		head_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)

	var/datum/sprite_accessory/accessory = GLOB.anime_top_list[value]
	var/datum/universal_icon/final_icon = head_icon.copy()

	if(!isnull(accessory) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		final_icon.blend_icon(uni_icon(accessory.icon, "m_anime_top_[accessory.icon_state]_FRONT"), ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/anime_top/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_top"] = value

/datum/preference/choiced/anime_top/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_middle
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Middle"
	savefile_key = "feature_anime_middle"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_middle/init_possible_values()
	return assoc_to_keys_features(GLOB.anime_middle_list)

/datum/preference/choiced/anime_middle/icon_for(value)
	var/static/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)

	var/static/datum/universal_icon/body_icon
	if(isnull(body_icon))
		body_icon = uni_icon('icons/blanks/32x32.dmi', "nothing")

		for(var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
			body_icon.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)

		body_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)
		body_icon.blend_icon(uni_icon('icons/mob/clothing/under/civilian.dmi', "barman", dir = NORTH), ICON_OVERLAY)

	var/datum/sprite_accessory/accessory = GLOB.anime_middle_list[value]
	var/datum/universal_icon/final_icon = body_icon.copy()

	if(!isnull(accessory) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		final_icon.blend_icon(uni_icon(accessory.icon, "m_anime_middle_[accessory.icon_state]_FRONT", NORTH), ICON_OVERLAY)

	return final_icon

/datum/preference/choiced/anime_middle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_middle"] = value

/datum/preference/choiced/anime_middle/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_bottom
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Bottom"
	savefile_key = "feature_anime_bottom"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_bottom/init_possible_values()
	return assoc_to_keys_features(GLOB.anime_bottom_list)

/datum/preference/choiced/anime_bottom/icon_for(value)
	var/static/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)

	var/static/datum/universal_icon/body_icon
	if(isnull(body_icon))
		body_icon = uni_icon('icons/blanks/32x32.dmi', "nothing")
		for(var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
			body_icon.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)

		body_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)
		var/datum/universal_icon/jumpsuit_icon = uni_icon('icons/mob/clothing/under/civilian.dmi', "barman", dir = NORTH)
		jumpsuit_icon.blend_color("#b3b3b3", ICON_MULTIPLY)
		body_icon.blend_icon(jumpsuit_icon, ICON_OVERLAY)

	var/datum/sprite_accessory/accessory = GLOB.anime_bottom_list[value]
	var/datum/universal_icon/final_icon = body_icon.copy()

	if(!isnull(accessory) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		final_icon.blend_icon(uni_icon(accessory.icon, "m_anime_bottom_[accessory.icon_state]_FRONT", NORTH), ICON_OVERLAY)

	return final_icon

/datum/preference/choiced/anime_bottom/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_bottom"] = value

/datum/preference/choiced/anime_bottom/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/choiced/anime_halo
	category = PREFERENCE_CATEGORY_CLOTHING
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Anime Halo"
	savefile_key = "feature_anime_halo"
	should_generate_icons = TRUE

/datum/preference/choiced/anime_halo/init_possible_values()
	return assoc_to_keys_features(GLOB.anime_halo_list)

/datum/preference/choiced/anime_halo/create_default_value()
	return /datum/sprite_accessory/anime_halo/none::name

/datum/preference/choiced/anime_halo/icon_for(value)
	var/datum/sprite_accessory/accessory = GLOB.anime_halo_list[value]

	if(isnull(accessory.icon_state) || accessory.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon('icons/mob/anime/anime_halo_preview.dmi', "[accessory.icon_state]_preview")

/datum/preference/choiced/anime_halo/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_halo"] = value

/datum/preference/choiced/anime_halo/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE

/datum/preference/color/anime_halo_color
	savefile_key = "feature_animehalocolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/color/anime_halo_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/anime_halo_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["animehalocolor"] = value

/datum/preference/color/anime_halo_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/datum/preference_middleware/quirks/located = locate(/datum/preference_middleware/quirks) in preferences.middleware
	if(!located)
		return FALSE
	var/list/quirks = located.get_selected_quirks()
	for(var/item in quirks)
		if(item == "Anime")
			return TRUE
	return FALSE
