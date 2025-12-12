/// Base preference for limb specific quirks
/datum/preference/choiced/limb
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	abstract_type = /datum/preference/choiced/limb
	var/quirk_name

/datum/preference/choiced/limb/create_default_value()
	return "Random"

/datum/preference/choiced/limb/init_possible_values()
	return list("Random") + GLOB.limb_choice

/datum/preference/choiced/limb/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return quirk_name in preferences.all_quirks

/datum/preference/choiced/limb/apply_to_human(mob/living/carbon/human/target, value)
	return

/* Limb choice preference implmentations */
/datum/preference/choiced/limb/prosthetic
	savefile_key = "prosthetic"
	quirk_name = "Prosthetic Limb"

/datum/preference/choiced/limb/monoplegic
	savefile_key = "monoplegic"
	quirk_name = "Monoplegic"

/// Preference for hemiplegic players to choose a specific side
/datum/preference/choiced/hemiplegic_side
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "hemiplegic_side"

/datum/preference/choiced/hemiplegic_side/create_default_value()
	return "Random"

/datum/preference/choiced/hemiplegic_side/init_possible_values()
	return list("Random", "Left", "Right")

/datum/preference/choiced/hemiplegic_side/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Hemiplegic" in preferences.all_quirks

/datum/preference/choiced/hemiplegic_side/apply_to_human(mob/living/carbon/human/target, value)
	return
