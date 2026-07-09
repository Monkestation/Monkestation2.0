/datum/preference/choiced/alcoholic_brand
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "alcoholic_brand"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/alcoholic_brand/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.alcoholic_drinks)

/datum/preference/choiced/alcoholic_brand/create_default_value()
	return "Random"

/datum/preference/choiced/alcoholic_brand/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return "Alcoholic" in preferences.all_quirks

/datum/preference/choiced/alcoholic_brand/apply_to_human(mob/living/carbon/human/target, value)
	return
