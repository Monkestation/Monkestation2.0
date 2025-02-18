// MONKESTATION EDIT START
/datum/preference/toggle/limb_missing/prosthetic
	savefile_key = "prosthetic_missing"
	quirk_name = "Prosthetic Limb"

/datum/preference/choiced/limb/prosthetic
	savefile_key = "prosthetic"
	quirk_name = "Prosthetic Limb"

/* original
/datum/preference/choiced/prosthetic
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "prosthetic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/prosthetic/init_possible_values()
	return list("Random") + GLOB.limb_choice

/datum/preference/choiced/prosthetic/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Prosthetic Limb" in preferences.all_quirks

/datum/preference/choiced/prosthetic/apply_to_human(mob/living/carbon/human/target, value)
	return
*/
// MONKESTATION EDIT END
