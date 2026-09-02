/datum/preference/choiced/ornithid_wings
	main_feature_name = "Arm Wings"
	savefile_key = "feature_arm_wings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	relevant_external_organ = /obj/item/organ/external/wings/functional/arm_wings
	should_generate_icons = TRUE

/datum/preference/choiced/ornithid_wings/init_possible_values()
	return assoc_to_keys_features(GLOB.arm_wings_list)

/datum/preference/choiced/ornithid_wings/icon_for(value)
	var/datum/sprite_accessory/arm_wings = GLOB.arm_wings_list[value]

	if(isnull(arm_wings) || arm_wings.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(arm_wings.icon, "m_arm_wings_[arm_wings.icon_state]_BEHIND")

/datum/preference/choiced/ornithid_wings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arm_wings"] = value

/datum/preference/choiced/ornithid_wings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = list("feather_color", "feather_color_secondary", "feather_color_tri")
	return data

/datum/preference/choiced/tail_avian
	main_feature_name = "Avian Tail"
	savefile_key = "feature_avian_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/external/tail/avian
	should_generate_icons = TRUE

/datum/preference/choiced/tail_avian/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feather_color_secondary"
	return data

/datum/preference/choiced/tail_avian/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_avian)

/datum/preference/choiced/tail_avian/icon_for(value)
	var/datum/sprite_accessory/tail_avian = GLOB.tails_list_avian[value]

	if(isnull(tail_avian) || tail_avian.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(tail_avian.icon, "m_tail_avian_[tail_avian.icon_state]_BEHIND")

/datum/preference/choiced/tail_avian/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_avian"] = value

/datum/preference/choiced/tail_avian/create_default_value()
	return /datum/sprite_accessory/tails/avian::name

/datum/preference/choiced/plumage
	main_feature_name = "Plumage"
	savefile_key = "feature_avian_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/external/plumage
	should_generate_icons = TRUE

/datum/preference/choiced/plumage/init_possible_values()
	return assoc_to_keys_features(GLOB.avian_ears_list)

/datum/preference/choiced/plumage/icon_for(value)
	var/datum/sprite_accessory/ears_avian = GLOB.avian_ears_list[value]

	if(isnull(ears_avian) || ears_avian.icon_state == SPRITE_ACCESSORY_NONE)
		return uni_icon('icons/mob/landmarks.dmi', "x")

	return uni_icon(ears_avian.icon, "m_ears_avian_[ears_avian.icon_state]_FRONT")

/datum/preference/choiced/plumage/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears_avian"] = value

/datum/preference/choiced/plumage/create_default_value()
	return /datum/sprite_accessory/plumage::name

/datum/preference/color/feather_color
	savefile_key = "feather_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED

/datum/preference/color/feather_color_secondary
	savefile_key = "feather_color_secondary"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/feather_color_tri
	savefile_key = "feather_color_tri"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/plummage_color
	savefile_key = "plummage_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE

/datum/preference/color/feather_tail_color
	savefile_key = "feather_tail_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_FEATHERED
	allows_nulls = TRUE
	default_null = TRUE
