/datum/preference/choiced/language
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "language"
	savefile_identifier = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/language/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return /datum/quirk/bilingual::name in preferences.all_quirks

/datum/preference/choiced/language/init_possible_values()
	var/list/values = list()

	if(!GLOB.roundstart_languages.len)
		generate_selectable_species_and_languages()

	values += "Random"
	//we add uncommon as it's foreigner-only.
	values += /datum/language/uncommon::name

	for(var/datum/language/language_type as anything in GLOB.roundstart_languages)
		if(ispath(language_type, /datum/language/common))
			continue
		if(initial(language_type.name) in values)
			continue
		values += initial(language_type.name)

	return values

/datum/preference/choiced/language/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/language_skill
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "language_skill"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/language_skill/create_default_value()
	return "100%"

/datum/preference/choiced/language_skill/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE
	return /datum/quirk/bilingual::name in preferences.all_quirks

/datum/preference/choiced/language_skill/init_possible_values()
	return list("100%", "75%", "50%", "33%", "25%", "10%")

/datum/preference/choiced/language_skill/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/csl_strength
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "csl_strength"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/csl_strength/create_default_value()
	return "90%"

/datum/preference/choiced/csl_strength/is_accessible(datum/preferences/preferences)
	return ..() && (/datum/quirk/csl::name in preferences.all_quirks)

/datum/preference/choiced/csl_strength/init_possible_values()
	return list("90%", "75%", "50%", "33%", "25%", "10%")

/datum/preference/choiced/csl_strength/apply_to_human(mob/living/carbon/human/target, value)
	return
