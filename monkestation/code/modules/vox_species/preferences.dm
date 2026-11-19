/// Makes a preview icon of a vox head wearing the passed quills (or nothing).
/proc/generate_vox_head_shot(datum/sprite_accessory/sprite_accessory, key, skin_tone = "lime")
	var/datum/universal_icon/final_icon = uni_icon(GLOB.vox_skin_tones[skin_tone], "vox_head", SOUTH)
	final_icon.blend_icon(uni_icon('icons/mob/human/species/vox/bodyparts_static.dmi', skin_tone == "mossy" ? "vox_head_static_mossy" : "vox_head_static", SOUTH), ICON_OVERLAY) // the beak
	for(var/eye_state in list("eyes_l", "eyes_r"))
		var/datum/universal_icon/eye = uni_icon('icons/mob/human/species/vox/eyes.dmi', eye_state, SOUTH)
		eye.blend_color(COLOR_CYAN, ICON_MULTIPLY)
		final_icon.blend_icon(eye, ICON_OVERLAY)
	var/static_color = (skin_tone in list("crimson", "mossy")) ? "blue" : "green" // the uncolored part of the eyes, as on Yogstation
	final_icon.blend_icon(uni_icon('icons/mob/human/species/vox/eyes.dmi', "eyes_static_[static_color]", SOUTH), ICON_OVERLAY)

	if(!isnull(sprite_accessory) && sprite_accessory.name != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", SOUTH)
		accessory_icon.blend_color(COLOR_DARKER_BROWN, ICON_ADD)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)
	return final_icon

/datum/preference/choiced/vox_skin_tone
	savefile_key = "feature_vox_skin_tone"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	main_feature_name = "Skin Tone"
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_skin_tone/init_possible_values()
	return assoc_to_keys(GLOB.vox_skin_tones)

/datum/preference/choiced/vox_skin_tone/create_default_value()
	return "lime"

/datum/preference/choiced/vox_skin_tone/compile_constant_data()
	var/list/data = ..()
	var/list/capitalized_skin_tones = list()
	for(var/skin_tone in GLOB.vox_skin_tones)
		capitalized_skin_tones[skin_tone] = capitalize(skin_tone)
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = capitalized_skin_tones
	var/static/list/skin_tones_to_hex = list(
		"lime" = "#617b0f",
		"crimson" = "#a32e2e",
		"plum" = "#564759",
		"azure" = "#124746",
		"emerald" = "#04572d",
		"brown" = "#774c22",
		"grey" = "#4a514b",
		"nebula" = "#5a4787",
		"mossy" = "#626d0d",
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
	target.dna.features["vox_skin_tone"] = value

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
	sync_vox_quills_organ(target, value, facial = FALSE)

/**
 * Feature preferences apply before the species one, and the species is only set when it changes.
 * So a mob that is already a vox (the character preview dummy) never gets its quills organ added or removed
 * by the species code when the style goes from or to "None". Do it here instead.
 * A mob that isn't a vox yet gets its organs from the species, which reads the features set above.
 */
/proc/sync_vox_quills_organ(mob/living/carbon/human/target, value, facial)
	if(!isvox(target))
		return
	var/slot = facial ? ORGAN_SLOT_EXTERNAL_VOX_FACIAL_QUILLS : ORGAN_SLOT_EXTERNAL_VOX_QUILLS
	var/has_organ = !isnull(target.get_organ_slot(slot))
	if(has_organ == (value != SPRITE_ACCESSORY_NONE))
		return // the organ is already right, its sprite follows the features in vox_update_limb()
	target.set_vox_quills(value, facial, update = FALSE)

/datum/preference/choiced/vox_quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_vox_quills_color"
	return data

/// The hair color, which vox wear on their quills. On Yogstation this is a subtype of the hair color preference.
/// Applied after the (hidden) normal hair color preference, so it wins for vox.
/datum/preference/color/vox_quills_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "feature_vox_quills_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/vox_quills

/datum/preference/color/vox_quills_color/create_default_value()
	return COLOR_DARKER_BROWN

/datum/preference/color/vox_quills_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isvox(target))
		target.set_haircolor(value, update = FALSE)

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
	sync_vox_quills_organ(target, value, facial = TRUE)

/datum/preference/choiced/vox_facial_quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_vox_facial_quills_color"
	return data

/// The facial hair color, which vox wear on their facial quills. On Yogstation this is a subtype of the facial hair color preference.
/datum/preference/color/vox_facial_quills_color
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "feature_vox_facial_quills_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_external_organ = /obj/item/organ/external/vox_quills/facial

/datum/preference/color/vox_facial_quills_color/create_default_value()
	return COLOR_DARKER_BROWN

/datum/preference/color/vox_facial_quills_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isvox(target))
		target.set_facial_haircolor(value, update = FALSE)

/datum/preference/choiced/vox_body_markings
	savefile_key = "feature_vox_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_body_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_body_markings_list)

/datum/preference/choiced/vox_body_markings/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/vox_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body_markings"] = value

/datum/preference/color/vox_body_markings_color
	savefile_key = "feature_vox_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/color/vox_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_body_markings_color"] = value

/datum/preference/choiced/vox_tail_markings
	savefile_key = "feature_vox_tail_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_tail_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.vox_tail_markings_list)

/datum/preference/choiced/vox_tail_markings/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/vox_tail_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail_markings"] = value

/datum/preference/color/vox_tail_markings_color
	savefile_key = "feature_vox_tail_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/color/vox_tail_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_tail_markings_color"] = value

/// Which nitrogen tank a vox spawns with.
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
	return // read straight from the preferences when equipping a job, as on Yogstation

/// Which breath mask a vox spawns with.
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
	return // read straight from the preferences when equipping a job, as on Yogstation

/// The hair gradient, which vox wear on their quills. On Yogstation this is a subtype of the hair gradient preference.
/// Applied after the (hidden) normal hair gradient preference, so it wins for vox.
/datum/preference/choiced/vox_quills_gradient
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "feature_quill_gradientstyle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/vox_quills

/datum/preference/choiced/vox_quills_gradient/init_possible_values()
	return assoc_to_keys_features(GLOB.hair_gradients_list)

/datum/preference/choiced/vox_quills_gradient/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/vox_quills_gradient/apply_to_human(mob/living/carbon/human/target, value)
	if(isvox(target))
		target.set_hair_gradient_style(value, update = FALSE)

/datum/preference/color/vox_quills_gradient
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "feature_quill_gradientcolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/vox_quills

/datum/preference/color/vox_quills_gradient/apply_to_human(mob/living/carbon/human/target, value)
	if(isvox(target))
		target.set_hair_gradient_color(value, update = FALSE)

/datum/preference/color/vox_quills_gradient/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/vox_quills_gradient) != SPRITE_ACCESSORY_NONE
