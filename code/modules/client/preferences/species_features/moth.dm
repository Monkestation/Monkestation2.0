/datum/preference/choiced/moth_antennae
	savefile_key = "feature_moth_antennae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antennae"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/antennae

/datum/preference/choiced/moth_antennae/init_possible_values()
	return assoc_to_keys_features(GLOB.moth_antennae_list)

/datum/preference/choiced/moth_antennae/icon_for(value)
	var/static/datum/universal_icon/moth_head

	if (isnull(moth_head))
		moth_head = uni_icon('icons/mob/species/moth/bodyparts.dmi', "moth_head")
		moth_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "motheyes_l"), ICON_OVERLAY)
		moth_head.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "motheyes_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/antennae = GLOB.moth_antennae_list[value]
	var/datum/universal_icon/icon_with_antennae = moth_head.copy()

	if(!isnull(antennae) && antennae.icon_state != SPRITE_ACCESSORY_NONE)
		icon_with_antennae.blend_icon(uni_icon(antennae.icon, "m_moth_antennae_[antennae.icon_state]_FRONT"), ICON_OVERLAY)

	icon_with_antennae.scale(64, 64)
	icon_with_antennae.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_antennae

/datum/preference/choiced/moth_antennae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_antennae"] = value

/datum/preference/choiced/moth_markings
	savefile_key = "feature_moth_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "moth_markings"

/datum/preference/choiced/moth_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.moth_markings_list)

/datum/preference/choiced/moth_markings/icon_for(value)
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

	var/static/datum/universal_icon/moth_body
	if(isnull(moth_body))
		moth_body = uni_icon('icons/blanks/32x32.dmi', "nothing")

		for(var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST ? "_m" : ""
			moth_body.blend_icon(uni_icon('icons/mob/species/moth/bodyparts.dmi', "moth_[body_part][gender]"), ICON_OVERLAY)

		moth_body.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "motheyes_l"), ICON_OVERLAY)
		moth_body.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "motheyes_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/markings = GLOB.moth_markings_list[value]
	var/datum/universal_icon/icon_with_markings = moth_body.copy()

	if(!isnull(markings) && markings.icon_state != SPRITE_ACCESSORY_NONE)
		for(var/body_part in body_parts)
			if(body_part == BODY_ZONE_PRECISE_L_HAND || body_part == BODY_ZONE_PRECISE_R_HAND) // :(((((((
				continue
			var/datum/universal_icon/body_part_icon = uni_icon(markings.icon, "[markings.icon_state]_[body_part]")
			body_part_icon.crop(1, 1, 32, 32)
			icon_with_markings.blend_icon(body_part_icon, ICON_OVERLAY)

	icon_with_markings.blend_icon(uni_icon('icons/mob/species/moth/moth_wings.dmi', "m_moth_wings_plain_FRONT"), ICON_OVERLAY)
	icon_with_markings.blend_icon(uni_icon('icons/mob/species/moth/moth_antennae.dmi', "m_moth_antennae_plain_FRONT"), ICON_OVERLAY)

	// Zoom in on the top of the head and the chest
	icon_with_markings.scale(64, 64)
	icon_with_markings.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_markings

/datum/preference/choiced/moth_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_markings"] = value

/datum/preference/choiced/moth_wings
	savefile_key = "feature_moth_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Moth wings"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/wings/moth

/datum/preference/choiced/moth_wings/init_possible_values()
	return assoc_to_keys_features(GLOB.moth_wings_list)

/datum/preference/choiced/moth_wings/icon_for(value)
	var/datum/sprite_accessory/moth_wings = GLOB.moth_wings_list[value]

	if(isnull(moth_wings) || moth_wings.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(moth_wings.icon, "m_moth_wings_[moth_wings.icon_state]_BEHIND")

/datum/preference/choiced/moth_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value
