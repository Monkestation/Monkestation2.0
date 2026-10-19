/datum/preference/choiced/floran_leaves
	main_feature_name = "Floran Leaves"
	savefile_key = "feature_floran_leaves"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/floran_leaves/init_possible_values()
	return assoc_to_keys_features(GLOB.floran_leaves_list)

/datum/preference/choiced/floran_leaves/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["floran_leaves"] = value

/datum/preference/choiced/floran_leaves/icon_for(value)
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

	var/static/datum/universal_icon/floran_body
	if(isnull(floran_body))
		floran_body = uni_icon('icons/blanks/32x32.dmi', "nothing")

		for(var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST ? "_m" : ""
			floran_body.blend_icon(uni_icon('icons/mob/species/floran/bodyparts.dmi', "floran_[body_part][gender]"), ICON_OVERLAY)

		floran_body.blend_color("#8fc433", ICON_MULTIPLY)
		floran_body.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/floran::eye_icon_state]_l"), ICON_OVERLAY)
		floran_body.blend_icon(uni_icon('icons/mob/species/human/human_face.dmi', "[/obj/item/organ/internal/eyes/floran::eye_icon_state]_r"), ICON_OVERLAY)

	var/datum/sprite_accessory/floran_leaves = GLOB.floran_leaves_list[value]
	var/datum/universal_icon/icon_with_leaves = floran_body.copy()

	if(!isnull(floran_leaves) && floran_leaves.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/leaves = uni_icon(floran_leaves.icon, "m_floran_leaves_[floran_leaves.icon_state]_ADJ")
		leaves.blend_color("#ff99ff", ICON_MULTIPLY)
		icon_with_leaves.blend_icon(leaves, ICON_OVERLAY)

	return icon_with_leaves

/datum/preference/numeric/hiss_length
	savefile_key = "hiss_length"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	minimum = 2
	maximum = 6

/datum/preference/numeric/hiss_length/create_default_value()
	return 3

/datum/preference/numeric/hiss_length/is_accessible(datum/preferences/preferences)
	return ..() && ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/floran)

/datum/preference/numeric/hiss_length/apply_to_human(mob/living/carbon/human/target, value)
	var/obj/item/organ/internal/tongue/floran/tongue = target.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!istype(tongue))
		return
	tongue.draw_length = value
