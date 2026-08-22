/datum/preference/choiced/ipc_antenna
	savefile_key = "feature_ipc_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Antenna"
	should_generate_icons = TRUE

/datum/preference/choiced/ipc_antenna/init_possible_values()
	return assoc_to_keys_features(GLOB.ipc_antennas_list)

/datum/preference/choiced/ipc_antenna/icon_for(value)
	var/static/datum/universal_icon/ipc_head
	if(isnull(ipc_head))
		ipc_head = uni_icon('icons/mob/species/ipc/bodyparts.dmi', "synth_head")

	var/datum/sprite_accessory/antennae = GLOB.ipc_antennas_list[value]

	var/datum/universal_icon/icon_with_antennae = ipc_head.copy()
	if(!isnull(antennae) && antennae.icon_state != SPRITE_ACCESSORY_NONE)
		icon_with_antennae.blend_icon(uni_icon(antennae.icon, "m_ipc_antenna_[antennae.icon_state]_FRONT"), ICON_OVERLAY)

	icon_with_antennae.scale(64, 64)
	icon_with_antennae.crop(15, 64- 31, 15 + 31, 64)

	return icon_with_antennae

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value

/datum/preference/choiced/ipc_chassis
	savefile_key = "feature_ipc_chassis"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Chassis"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "ipc_chassis"

/datum/preference/choiced/ipc_chassis/init_possible_values()
	return assoc_to_keys_features(GLOB.ipc_chassis_list)

/datum/preference/choiced/ipc_chassis/icon_for(value)
	var/static/datum/universal_icon/ipc_body
	if(isnull(ipc_body))
		ipc_body = uni_icon('icons/blanks/32x32.dmi', "nothing")

	var/datum/sprite_accessory/chassis = GLOB.ipc_chassis_list[value]

	var/datum/universal_icon/chassis_icon = uni_icon('icons/mob/species/ipc/ipc_chassis.dmi', "m_ipc_chassis_[chassis.icon_state]_FRONT")

	var/datum/universal_icon/final_icon = ipc_body.copy()
	final_icon.blend_icon(chassis_icon, ICON_OVERLAY)

	final_icon.crop(10, 8, 22, 23)
	final_icon.scale(26, 32)
	final_icon.crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/ipc_chassis/apply_to_human(mob/living/carbon/human/target, value)
	var/list/features = target.dna.features
	if(features["ipc_chassis"] == value)
		return
	features["ipc_chassis"] = value
	var/datum/species/ipc/ipc = target.dna?.species
	if(istype(ipc)) // this is awful. i'm sorry.
		ipc.update_chassis(target)

/datum/preference/choiced/ipc_screen
	savefile_key = "feature_ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "IPC Screen"
	relevant_mutant_bodypart = "ipc_screen"
	should_generate_icons = TRUE

/datum/preference/choiced/ipc_screen/init_possible_values()
	return assoc_to_keys_features(GLOB.ipc_screens_list)

/datum/preference/choiced/ipc_screen/icon_for(value)
	var/static/datum/universal_icon/ipc_head
	if(isnull(ipc_head))
		ipc_head = uni_icon('icons/mob/species/ipc/bodyparts.dmi', "synth_head")

	var/datum/sprite_accessory/screen = GLOB.ipc_screens_list[value]
	var/datum/universal_icon/icon_with_screen = ipc_head.copy()

	icon_with_screen.blend_icon(uni_icon(screen.icon, "m_ipc_screen_[screen.icon_state]_ADJ"), ICON_OVERLAY)
	icon_with_screen.scale(64, 64)
	icon_with_screen.crop(15, 64 - 31, 15 + 31, 64)

	return icon_with_screen

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value

/datum/preference/choiced/ipc_brain
	savefile_key = "ipc_brain"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_BODY_TYPE

/datum/preference/choiced/ipc_brain/init_possible_values()
	return list("Compact Positronic", "Compact MMI")

/datum/preference/choiced/ipc_brain/create_default_value()
	return "Compact Positronic"

/datum/preference/choiced/ipc_brain/apply_to_human(mob/living/carbon/human/target, value)
	if (!istype(target.dna.species, /datum/species/ipc))
		return
	if (value == "Compact MMI")
		var/obj/item/organ/internal/brain/synth/mmi/new_organ = new()
		var/obj/item/organ/internal/brain/existing_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(istype(existing_brain) && !existing_brain.decoy_override)
			existing_brain.before_organ_replacement(new_organ)
			existing_brain.Remove(target, special = TRUE, no_id_transfer = TRUE)
			qdel(existing_brain)
		new_organ.Insert(target, special = TRUE, drop_if_replaced = FALSE)

/datum/preference/choiced/ipc_brain/is_accessible(datum/preferences/preferences)
	return ..() && preferences.read_preference(/datum/preference/choiced/species) == /datum/species/ipc
