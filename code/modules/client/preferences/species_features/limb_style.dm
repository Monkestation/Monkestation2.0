/// How the limbs of species with TRAIT_GREYSCALE_TOGGLE look: classic, colored by the mutant color, or tundra fur
/datum/preference/choiced/limb_style
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "limb_style"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_inherent_trait = TRAIT_GREYSCALE_TOGGLE

/datum/preference/choiced/limb_style/init_possible_values()
	return list(LIMB_STYLE_CLASSIC, LIMB_STYLE_MUTANT_COLORS, LIMB_STYLE_TUNDRA)

/datum/preference/choiced/limb_style/create_default_value()
	return LIMB_STYLE_CLASSIC

/datum/preference/choiced/limb_style/apply_to_human(mob/living/carbon/human/target, value)
	target.limb_style = value
