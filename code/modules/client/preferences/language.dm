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
