/datum/preference/choiced/prosthetic_organ
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "prosthetic_organ"
	savefile_identifier = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/prosthetic_organ/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return /datum/quirk/prosthetic_organ::name in preferences.all_quirks

/datum/preference/choiced/prosthetic_organ/init_possible_values()
	var/list/values = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_SPLEEN,
	)
	values += "Random"
	return values

/datum/preference/choiced/prosthetic_organ/apply_to_human(mob/living/carbon/human/target, value)
	return
