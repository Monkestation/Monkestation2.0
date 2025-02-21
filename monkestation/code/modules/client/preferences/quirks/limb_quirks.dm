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

/// Base preference for quirks with optional limb removal
/datum/preference/toggle/limb_missing
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	default_value = FALSE
	abstract_type = /datum/preference/toggle/limb_missing
	var/quirk_name

/datum/preference/toggle/limb_missing/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return quirk_name in preferences.all_quirks

/datum/preference/toggle/limb_missing/apply_to_human(mob/living/carbon/human/target, value)
	return

/* Missing limb preference implementations */

/datum/preference/toggle/limb_missing/prosthetic
	savefile_key = "prosthetic_missing"
	quirk_name = "Prosthetic Limb"

/datum/preference/toggle/limb_missing/monoplegic
	savefile_key = "monoplegic_missing"
	quirk_name = "Monoplegic"

/datum/preference/toggle/limb_missing/hemiplegic
	savefile_key = "hemiplegic_limbs_missing"
	quirk_name = "Hemiplegic"

/datum/preference/toggle/limb_missing/paraplegic
	savefile_key = "paraplegic_limbs_missing"
	quirk_name = "Paraplegic"

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
