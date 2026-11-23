/proc/generate_underwear_icon(datum/sprite_accessory/accessory, datum/universal_icon/base_icon, color, icon_file)
	var/datum/universal_icon/final_icon = base_icon.copy()

	if(!isnull(accessory) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		var/datum/universal_icon/accessory_icon = uni_icon(icon_file || accessory.icon, accessory.icon_state)
		if(color && !accessory.use_static)
			accessory_icon.blend_color(color, ICON_MULTIPLY)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(10, 1, 22, 13)
	final_icon.scale(32, 32)

	return final_icon

/**
 * Underwear, undershirt and socks preferences come in a normal version, and fitted versions (see their fitted_species var)
 * for species whose limbs have underwear sprites of their own (/datum/species/var/custom_worn_icons).
 * A species with fitted sprites for a slot sees only the fitted version, so it needs one. Returns whether the preference is shown for the selected species.
 * * underwear_slot: LOADOUT_ITEM_UNDERWEAR, LOADOUT_ITEM_UNDERSHIRT or LOADOUT_ITEM_SOCKS
 */
/proc/is_underwear_preference_accessible(datum/preferences/preferences, datum/species/fitted_species, underwear_slot)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	if(TRAIT_NO_UNDERWEAR in species.inherent_traits)
		return FALSE
	if(fitted_species)
		return species_type == fitted_species
	return !species.custom_worn_icons[underwear_slot]

/// Returns the icon file a species' fitted underwear sprites are in, for fitted underwear preferences
/proc/get_fitted_underwear_icon(datum/species/fitted_species, underwear_slot)
	var/datum/species/species = GLOB.species_prototypes[fitted_species]
	return species?.custom_worn_icons[underwear_slot]

/// Returns the names of the accessories that have a sprite fitted to the given species, for fitted underwear preferences
/proc/get_fitted_underwear_names(list/accessory_list, datum/species/fitted_species, underwear_slot)
	. = list()
	var/fitted_icon = get_fitted_underwear_icon(fitted_species, underwear_slot)
	for(var/accessory_name in accessory_list)
		var/datum/sprite_accessory/accessory = accessory_list[accessory_name]
		if(!accessory.icon_state || accessory.icon_state == SPRITE_ACCESSORY_NONE) // "Nude" has nothing to draw
			. += accessory_name
			continue
		if(!accessory.locked && fitted_icon && icon_exists(fitted_icon, accessory.icon_state))
			. += accessory_name

/// Returns an icon of a species' default limbs in the given body zones, for previews of fitted underwear
/proc/generate_species_limbs_icon(datum/species/species_type, list/body_zones)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	var/datum/universal_icon/final_icon = uni_icon('icons/blanks/32x32.dmi', "nothing")
	for(var/zone in body_zones)
		var/limb_zone = zone
		switch(zone) // hands are drawn by the arms
			if(BODY_ZONE_PRECISE_L_HAND)
				limb_zone = BODY_ZONE_L_ARM
			if(BODY_ZONE_PRECISE_R_HAND)
				limb_zone = BODY_ZONE_R_ARM
		var/obj/item/bodypart/limb = species.bodypart_overrides[limb_zone]
		final_icon.blend_icon(uni_icon(initial(limb.icon_static), "[initial(limb.limb_id)]_[zone]"), ICON_OVERLAY)
	return final_icon

/// Backpack preference
/datum/preference/choiced/backpack
	savefile_key = "backpack"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Backpack"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	return list(
		GBACKPACK,
		GSATCHEL,
		LSATCHEL,
		BSATCHEL,
		RSATCHEL,
		GDUFFELBAG,
		DBACKPACK,
		DSATCHEL,
		DDUFFELBAG,
	)

/datum/preference/choiced/backpack/icon_for(value)
	switch (value)
		if (GBACKPACK)
			return /obj/item/storage/backpack
		if (GSATCHEL)
			return /obj/item/storage/backpack/satchel
		if (LSATCHEL)
			return /obj/item/storage/backpack/satchel/leather
		if (BSATCHEL)
			return /obj/item/storage/backpack/satchel/blackleather
		if (RSATCHEL)
			return /obj/item/storage/backpack/satchel/retro
		if (GDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag

		// In a perfect world, these would be your department's backpack.
		// However, this doesn't factor in assistants, or no high slot, and would
		// also increase the spritesheet size a lot.
		// I play medical doctor, and so medical doctor you get.
		if (DBACKPACK)
			return /obj/item/storage/backpack/medic
		if (DSATCHEL)
			return /obj/item/storage/backpack/satchel/med
		if (DDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag/med

/datum/preference/choiced/backpack/apply_to_human(mob/living/carbon/human/target, value)
	target.backpack = value

/// Jumpsuit preference
/datum/preference/choiced/jumpsuit
	savefile_key = "jumpsuit_style"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Jumpsuit"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/jumpsuit/init_possible_values()
	return list(
		PREF_SUIT,
		PREF_SKIRT,
	)

/datum/preference/choiced/jumpsuit/icon_for(value)
	switch(value)
		if (PREF_SUIT)
			return /obj/item/clothing/under/color/grey
		if (PREF_SKIRT)
			return /obj/item/clothing/under/color/jumpskirt/grey

/datum/preference/choiced/jumpsuit/apply_to_human(mob/living/carbon/human/target, value)
	target.jumpsuit_style = value

/// Socks preference
/datum/preference/choiced/socks
	savefile_key = "socks"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Socks"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	/// If set, this is the fitted version of the preference for this species, see is_underwear_preference_accessible()
	var/datum/species/fitted_species

/datum/preference/choiced/socks/init_possible_values()
	if(fitted_species)
		return get_fitted_underwear_names(GLOB.socks_list, fitted_species, LOADOUT_ITEM_SOCKS)
	return assoc_to_keys_features(GLOB.socks_list)

/datum/preference/choiced/socks/create_default_value()
	return fitted_species ? "Nude" : ..()

/datum/preference/choiced/socks/icon_for(value)
	if(fitted_species)
		var/datum/sprite_accessory/accessory = GLOB.socks_list[value]
		var/datum/universal_icon/legs = generate_species_limbs_icon(fitted_species, list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		return generate_underwear_icon(accessory, legs, icon_file = get_fitted_underwear_icon(fitted_species, LOADOUT_ITEM_SOCKS))

	var/static/datum/universal_icon/lower_half

	if (isnull(lower_half))
		lower_half = uni_icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(GLOB.socks_list[value], lower_half)

/datum/preference/choiced/socks/apply_to_human(mob/living/carbon/human/target, value)
	if(fitted_species && !istype(target.dna.species, fitted_species)) // the normal version applies to everyone else
		return
	target.socks = value

/datum/preference/choiced/socks/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return is_underwear_preference_accessible(preferences, fitted_species, LOADOUT_ITEM_SOCKS)

/datum/preference/choiced/socks/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "socks_color"

	return data

/// Undershirt preference
/datum/preference/choiced/undershirt
	savefile_key = "undershirt"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Undershirt"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	/// If set, this is the fitted version of the preference for this species, see is_underwear_preference_accessible()
	var/datum/species/fitted_species

/datum/preference/choiced/undershirt/init_possible_values()
	if(fitted_species)
		return get_fitted_underwear_names(GLOB.undershirt_list, fitted_species, LOADOUT_ITEM_UNDERSHIRT)
	return assoc_to_keys_features(GLOB.undershirt_list)

/datum/preference/choiced/undershirt/create_default_value()
	return fitted_species ? "Nude" : ..()

/datum/preference/choiced/undershirt/icon_for(value)
	if(fitted_species)
		var/datum/sprite_accessory/accessory = GLOB.undershirt_list[value]
		var/datum/universal_icon/fitted_body = generate_species_limbs_icon(fitted_species, list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_CHEST))
		var/fitted_icon = get_fitted_underwear_icon(fitted_species, LOADOUT_ITEM_UNDERSHIRT)
		if(fitted_icon && accessory.icon_state != SPRITE_ACCESSORY_NONE)
			fitted_body.blend_icon(uni_icon(fitted_icon, accessory.icon_state), ICON_OVERLAY)
		fitted_body.crop(9, 9, 23, 23)
		fitted_body.scale(32, 32)
		return fitted_body

	var/static/datum/universal_icon/body
	if (isnull(body))
		body = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg")
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_arm"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_arm"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_hand"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_hand"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)

	var/datum/sprite_accessory/accessory = GLOB.undershirt_list[value]
	var/datum/universal_icon/icon_with_undershirt = body.copy()

	if(!isnull(accessory) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		icon_with_undershirt.blend_icon(uni_icon('icons/mob/clothing/underwear.dmi', accessory.icon_state), ICON_OVERLAY)

	icon_with_undershirt.crop(9, 9, 23, 23)
	icon_with_undershirt.scale(32, 32)

	return icon_with_undershirt

/datum/preference/choiced/undershirt/apply_to_human(mob/living/carbon/human/target, value)
	if(fitted_species && !istype(target.dna.species, fitted_species)) // the normal version applies to everyone else
		return
	target.undershirt = value

/datum/preference/choiced/undershirt/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return is_underwear_preference_accessible(preferences, fitted_species, LOADOUT_ITEM_UNDERSHIRT)

/// Underwear preference
/datum/preference/choiced/underwear
	savefile_key = "underwear"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	/// If set, this is the fitted version of the preference for this species, see is_underwear_preference_accessible()
	var/datum/species/fitted_species

/datum/preference/choiced/underwear/init_possible_values()
	if(fitted_species)
		return get_fitted_underwear_names(GLOB.underwear_list, fitted_species, LOADOUT_ITEM_UNDERWEAR)
	return assoc_to_keys_features(GLOB.underwear_list)

/datum/preference/choiced/underwear/create_default_value()
	return fitted_species ? "Nude" : ..()

/datum/preference/choiced/underwear/icon_for(value)
	if(fitted_species)
		var/datum/sprite_accessory/accessory = GLOB.underwear_list[value]
		var/datum/universal_icon/lower_body = generate_species_limbs_icon(fitted_species, list(BODY_ZONE_CHEST, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		return generate_underwear_icon(accessory, lower_body, COLOR_ALMOST_BLACK, get_fitted_underwear_icon(fitted_species, LOADOUT_ITEM_UNDERWEAR))

	var/static/datum/universal_icon/lower_half

	if(isnull(lower_half))
		lower_half = uni_icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(GLOB.underwear_list[value], lower_half, COLOR_ALMOST_BLACK)

/datum/preference/choiced/underwear/apply_to_human(mob/living/carbon/human/target, value)
	if(fitted_species && !istype(target.dna.species, fitted_species)) // the normal version applies to everyone else
		return
	target.underwear = value

/datum/preference/choiced/underwear/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return is_underwear_preference_accessible(preferences, fitted_species, LOADOUT_ITEM_UNDERWEAR)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"

	return data
