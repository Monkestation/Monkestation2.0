/// Makes a preview icon of a vox head wearing the passed quills
/proc/generate_vox_head_shot(datum/sprite_accessory/sprite_accessory, key)
	var/datum/universal_icon/final_icon = uni_icon(GLOB.vox_skin_tones[VOX_DEFAULT_SKIN_TONE], "vox_head", SOUTH)
	for(var/eye_state in list("eyes_l", "eyes_r"))
		var/datum/universal_icon/eye = uni_icon('icons/mob/human/species/vox/eyes.dmi', eye_state, SOUTH)
		eye.blend_color(COLOR_CYAN, ICON_MULTIPLY)
		final_icon.blend_icon(eye, ICON_OVERLAY)
	final_icon.blend_icon(uni_icon('icons/mob/human/species/vox/eyes.dmi', "eyes_static_green", SOUTH), ICON_OVERLAY)

	if(!isnull(sprite_accessory) && sprite_accessory.name != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", SOUTH)
		accessory_icon.blend_color(COLOR_DARKER_BROWN, ICON_ADD)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)
	return final_icon

/// Vox skin tones are limb styles, see GLOB.vox_skin_tones
/datum/preference/choiced/vox_skin_tone
	savefile_key = "feature_vox_skin_tone"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	main_feature_name = "Skin Tone"
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_skin_tone/init_possible_values()
	return assoc_to_keys(GLOB.vox_skin_tones)

/datum/preference/choiced/vox_skin_tone/create_default_value()
	return VOX_DEFAULT_SKIN_TONE

/datum/preference/choiced/vox_skin_tone/compile_constant_data()
	var/list/data = ..()
	var/list/display_names = list()
	for(var/skin_tone in GLOB.vox_skin_tones)
		display_names[skin_tone] = capitalize(skin_tone)
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = display_names
	var/static/list/skin_tones_to_hex = list(
		"azure" = "#124746",
		"brown" = "#774c22",
		"crimson" = "#a32e2e",
		"emerald" = "#04572d",
		"grey" = "#4a514b",
		"lime" = "#617b0f",
		"mossy" = "#626d0d",
		"nebula" = "#5a4787",
		"plum" = "#564759",
	)
	var/list/to_hex = list()
	for(var/choice in get_choices())
		var/hex_value = skin_tones_to_hex[choice]
		var/list/hsl = rgb2num(hex_value, COLORSPACE_HSL)
		to_hex[choice] = list(
			"lightness" = hsl[3],
			"value" = hex_value,
		)
	data["to_hex"] = to_hex
	return data

/datum/preference/choiced/vox_skin_tone/apply_to_human(mob/living/carbon/human/target, value)
	if(isvox(target)) // the limb style feature is also used by other species with limb styles
		target.dna.features["limb_style"] = value

/datum/preference/choiced/vox_quills
	savefile_key = "feature_vox_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Quills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/vox_quills

/datum/preference/choiced/vox_quills/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_quills_list)

/datum/preference/choiced/vox_quills/icon_for(value)
	return generate_vox_head_shot(GLOB.vox_quills_list[value], "vox_quills")

/datum/preference/choiced/vox_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_quills"] = value

/// Quills take the hair color, see /datum/species/vox/get_features()
/datum/preference/choiced/vox_quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = list("hair_color")
	return data

/datum/preference/choiced/vox_facial_quills
	savefile_key = "feature_vox_facial_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Facial Quills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/vox_quills/facial

/datum/preference/choiced/vox_facial_quills/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_facial_quills_list)

/datum/preference/choiced/vox_facial_quills/icon_for(value)
	return generate_vox_head_shot(GLOB.vox_facial_quills_list[value], "vox_facial_quills")

/datum/preference/choiced/vox_facial_quills/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/vox_facial_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_facial_quills"] = value

/// Facial quills take the facial hair color
/datum/preference/choiced/vox_facial_quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = list("facial_hair_color")
	return data

/// Colored by the mutant color
/datum/preference/choiced/vox_body_markings
	savefile_key = "feature_vox_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	main_feature_name = "Body Markings"
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_body_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_body_markings_list)

/datum/preference/choiced/vox_body_markings/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/vox_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body_markings"] = value

/// Colored by the secondary mutant color
/datum/preference/choiced/vox_tail_markings
	savefile_key = "feature_vox_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	main_feature_name = "Tail Markings"
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_tail_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_tail_markings_list)

/datum/preference/choiced/vox_tail_markings/create_default_value()
	return "Plain"

/datum/preference/choiced/vox_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail_markings"] = value

/// Which nitrogen tank a vox starts the shift with, see /datum/species/vox/pre_equip_species_outfit()
/datum/preference/choiced/vox_tank_type
	savefile_key = "feature_vox_tank_type"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_tank_type/init_possible_values()
	return list("Large", "Specialized")

/datum/preference/choiced/vox_tank_type/create_default_value()
	return "Specialized"

/datum/preference/choiced/vox_tank_type/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tank_type"] = value

/// Which breath mask a vox starts the shift with, see /datum/species/vox/pre_equip_species_outfit()
/datum/preference/choiced/vox_mask
	savefile_key = "feature_vox_mask"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_mask/init_possible_values()
	return list("Breath Mask", "Respirator")

/datum/preference/choiced/vox_mask/create_default_value()
	return "Breath Mask"

/datum/preference/choiced/vox_mask/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_mask"] = value

// Underwear that only lists what has a vox fitted sprite, see is_underwear_preference_accessible()

/datum/preference/choiced/underwear/vox
	savefile_key = "feature_vox_underwear"
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	fitted_species = /datum/species/vox

/datum/preference/choiced/undershirt/vox
	savefile_key = "feature_vox_undershirt"
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	fitted_species = /datum/species/vox

/datum/preference/choiced/socks/vox
	savefile_key = "feature_vox_socks"
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	fitted_species = /datum/species/vox
