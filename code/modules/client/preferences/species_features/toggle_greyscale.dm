/datum/preference/toggle/greyscale_toggle
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "greyscale_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_inherent_trait = TRAIT_GREYSCALE_TOGGLE

/datum/preference/toggle/greyscale_toggle/create_default_value()
	return FALSE

/datum/preference/toggle/greyscale_toggle/apply_to_human(mob/living/carbon/human/target, value)
	target.greyscale_limbs = value
