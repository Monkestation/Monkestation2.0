/obj/item/bodypart/head/oozeling
	limb_id = SPECIES_OOZELING
	is_dimorphic = TRUE
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6
	body_damage_coeff = 0.75
	max_damage = 50
	can_dismember = TRUE

/obj/item/bodypart/head/oozeling/can_dismember(obj/item/item)
	if((bodypart_flags & BODYPART_UNREMOVABLE) || (owner && HAS_TRAIT(owner, TRAIT_NODISMEMBER)))
		return FALSE
	return TRUE

/obj/item/bodypart/chest/oozeling
	limb_id = SPECIES_OOZELING
	is_dimorphic = TRUE
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	ass_image = 'icons/ass/assslime.png'
	wing_types = list(/obj/item/organ/external/wings/functional/slime)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6

/obj/item/bodypart/arm/left/oozeling
	limb_id = SPECIES_OOZELING
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6

/obj/item/bodypart/arm/right/oozeling
	limb_id = SPECIES_OOZELING
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6

/obj/item/bodypart/leg/left/oozeling
	limb_id = SPECIES_OOZELING
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6

/obj/item/bodypart/leg/right/oozeling
	limb_id = SPECIES_OOZELING
	biological_state = BIO_INORGANIC

	dmg_overlay_type = null
	composition_effects = list(/datum/element/soft_landing = 0.5)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	burn_modifier = 0.6
