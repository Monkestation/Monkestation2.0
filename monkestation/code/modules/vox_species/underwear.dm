// Vox wear underwear cut for vox. They get their own preferences, listing only what actually has a fitted sprite.

/// Species hook that runs after the job outfit and loadout were equipped.
/datum/species/proc/post_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/// Returns the names in an underwear-like accessory list that have a sprite in the given fitted icon file.
/proc/get_fitted_underwear_names(list/accessory_list, icon_file)
	. = list()
	for(var/accessory_name in accessory_list)
		var/datum/sprite_accessory/accessory = accessory_list[accessory_name]
		if(!istype(accessory)) // "Nude" has no datum
			. += accessory_name
		else if(!accessory.locked && icon_exists(icon_file, accessory.icon_state))
			. += accessory_name

/// Makes a preview of a piece of fitted underwear on a vox body made of the given limbs.
/proc/generate_vox_underwear_icon(datum/sprite_accessory/accessory, icon_file, list/body_zones)
	var/datum/universal_icon/final_icon = uni_icon('icons/blanks/32x32.dmi', "nothing")
	for(var/zone in body_zones)
		final_icon.blend_icon(uni_icon('icons/mob/human/species/vox/bodyparts_lime.dmi', "vox_[zone]"), ICON_OVERLAY)
	if(istype(accessory))
		final_icon.blend_icon(uni_icon(icon_file, accessory.icon_state), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/vox_underwear
	savefile_key = "feature_vox_underwear"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_underwear/init_possible_values()
	return get_fitted_underwear_names(GLOB.underwear_list, 'icons/mob/clothing/species/vox/underwear.dmi')

/datum/preference/choiced/vox_underwear/icon_for(value)
	var/datum/universal_icon/final_icon = generate_vox_underwear_icon(GLOB.underwear_list[value], 'icons/mob/clothing/species/vox/underwear.dmi', list("chest", "r_leg", "l_leg"))
	final_icon.crop(10, 1, 22, 13)
	final_icon.scale(32, 32)
	return final_icon

/datum/preference/choiced/vox_underwear/create_default_value()
	return "Nude"

/datum/preference/choiced/vox_underwear/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_underwear"] = value

/datum/preference/choiced/vox_underwear/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"
	return data

/datum/preference/choiced/vox_socks
	savefile_key = "feature_vox_socks"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Socks"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_socks/init_possible_values()
	return get_fitted_underwear_names(GLOB.socks_list, 'icons/mob/clothing/species/vox/socks.dmi')

/datum/preference/choiced/vox_socks/icon_for(value)
	var/datum/universal_icon/final_icon = generate_vox_underwear_icon(GLOB.socks_list[value], 'icons/mob/clothing/species/vox/socks.dmi', list("r_leg", "l_leg"))
	final_icon.crop(10, 1, 22, 13)
	final_icon.scale(32, 32)
	return final_icon

/datum/preference/choiced/vox_socks/create_default_value()
	return "Nude"

/datum/preference/choiced/vox_socks/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_socks"] = value

/datum/preference/choiced/vox_socks/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "socks_color"
	return data

/datum/preference/choiced/vox_undershirt
	savefile_key = "feature_vox_undershirt"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Undershirt"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/tail/vox

/datum/preference/choiced/vox_undershirt/init_possible_values()
	return get_fitted_underwear_names(GLOB.undershirt_list, 'icons/mob/clothing/species/vox/undershirt.dmi')

/datum/preference/choiced/vox_undershirt/icon_for(value)
	var/datum/universal_icon/final_icon = generate_vox_underwear_icon(GLOB.undershirt_list[value], 'icons/mob/clothing/species/vox/undershirt.dmi', list("r_leg", "l_leg", "r_arm", "l_arm", "r_hand", "l_hand", "chest"))
	final_icon.crop(9, 9, 23, 23)
	final_icon.scale(32, 32)
	return final_icon

/datum/preference/choiced/vox_undershirt/create_default_value()
	return "Nude"

/datum/preference/choiced/vox_undershirt/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["vox_undershirt"] = value

// The Smooth-Headed quirk plucks a vox clean.

/datum/quirk/item_quirk/bald/add(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(isvox(human_holder))
		human_holder.set_vox_quills(SPRITE_ACCESSORY_NONE)
