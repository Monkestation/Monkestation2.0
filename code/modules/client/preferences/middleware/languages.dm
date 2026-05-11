#define MAX_LANGUAGES_NORMAL 4

/datum/asset/spritesheet/languages
	name = "languages"
	early = TRUE
	cross_round_cachable = TRUE

/datum/asset/spritesheet/languages/create_spritesheets()
	var/list/to_insert = list()

	if(!GLOB.all_languages.len)
		stack_trace("Warning: Language spritesheets could not be created because language subsystem has not been loaded yet. This should not happen--adjust the init_order in master_files/code/controllers/subsystem/language.dm.")
		return

	for (var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.language_datum_instances[language_name]
		var/icon/language_icon = icon(language.icon, icon_state = language.icon_state)
		to_insert[sanitize_css_class_name(language.name)] = language_icon

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

/// Middleware to handle languages
/datum/preference_middleware/languages
	/// A associative list of language names to their typepath
	var/static/list/name_to_language = list()
	action_delegations = list(
		"speak_language" = PROC_REF(speak_language),
		"understand_language" = PROC_REF(understand_language),
		"forget_speak_language" = PROC_REF(forget_speak_language),
		"forget_understand_language" = PROC_REF(forget_understand_language)
	)

/datum/preference_middleware/languages/apply_to_human(mob/living/carbon/human/target, datum/preferences/preferences, visuals_only = FALSE)
	var/datum/language_holder/language_holder = target.get_language_holder()
	language_holder.adjust_languages_to_prefs(preferences)

/datum/preference_middleware/languages/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/languages),
	)

/datum/preference_middleware/languages/post_set_preference(mob/user, preference, value)
	if(preference != "species")
		return
	preferences.languages = list()
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/language_holder/lang_holder = GLOB.prototype_language_holders[species_type::species_language_holder]
	for(var/language in lang_holder.spoken_languages)
		preferences.languages[language] = LANGUAGE_SPOKEN

/datum/preference_middleware/languages/proc/define_max_languages(mob/user) //Monke edit: Instead of using a switch that checks for just the linguist quirk, we're checking for multiple quirks.
	var/max_languages = MAX_LANGUAGES_NORMAL
	if(/datum/quirk/linguist::name in preferences.all_quirks)
		max_languages += 2
	if(/datum/quirk/polyglot::name in preferences.all_quirks)
		max_languages += 8
	return max_languages

/datum/preference_middleware/languages/proc/define_language_points(mob/user) //Monke edit: Speaking a language is 2 cost, making the equations a little more complicated.
	var/language_points = 0
	for (var/language_path, language_instance in GLOB.language_datum_instances)
		var/datum/language/language = language_instance
		if(preferences.languages[language.type])
			language_points += 1
			if(preferences.languages[language.type] == LANGUAGE_SPOKEN)
				language_points += 1
	return language_points

/datum/preference_middleware/languages/get_ui_data(mob/user)
	if(length(name_to_language) != length(GLOB.all_languages))
		initialize_name_to_language()

	var/list/data = list()

	var/max_languages = define_max_languages()
	var/current_language_points = define_language_points()
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	var/datum/language_holder/lang_holder = GLOB.prototype_language_holders[species.species_language_holder]

	if(current_language_points < 1 || !preferences.languages || !preferences.languages.len || (current_language_points > max_languages)) // Too many languages, or no languages.
		preferences.languages = list()
		for(var/language in lang_holder.spoken_languages)
			preferences.languages[language] = LANGUAGE_SPOKEN

	if(current_language_points > max_languages)
		preferences.languages -= name_to_language[/datum/language/common]

	if(!preferences.languages.len)
		preferences.languages[/datum/language/uncommon] = LANGUAGE_SPOKEN

	var/list/selected_languages = list()
	var/list/unselected_languages = list()

	for (var/language_path, language_instance in GLOB.language_datum_instances)
		var/datum/language/language = language_instance
		if(language.secret && (isnull(species.language_prefs_whitelist) || isnull(species.language_prefs_whitelist[language_path]))) // For ghostrole species who are able to speak a secret language, e.g. ashwalkers, display it.
			continue
		if(preferences.languages[language.type])
			selected_languages += list(list(
				"description" = language.desc,
				"name" = language.name,
				"icon" = sanitize_css_class_name(language.name),
				"speaking" = !!(preferences.languages[language.type] == LANGUAGE_SPOKEN),
			))
		else
			unselected_languages += list(list(
				"description" = language.desc,
				"name" = language.name,
				"icon" = sanitize_css_class_name(language.name)
			))

	data["total_language_points"] = max_languages
	data["selected_languages"] = selected_languages
	data["unselected_languages"] = unselected_languages
	data["current_language_points"] = define_language_points()
	return data

/// (Re-)Initializes the `name_to_language` associative list, to ensure that it's properly populated.
/datum/preference_middleware/languages/proc/initialize_name_to_language()
	name_to_language = list()
	for(var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.language_datum_instances[language_name]
		name_to_language[language.name] = language_name

/**
 * Proc that gives understanding and speaking capabilities of a language to a character,
 * granted that they don't already have too many of them, based on their maximum amount of languages.
 *
 * Returns TRUE all the time, to ensure that the UI is updated.
 */
/datum/preference_middleware/languages/proc/speak_language(list/params, mob/user)
	var/language_name = params["language_name"]
	var/language_points = define_language_points()
	var/max_languages = define_max_languages()
	if(language_points == max_languages) //at the language limit
		to_chat(user, span_warning("You have too many languages learned!"))
		return TRUE
	if(preferences.languages && !(name_to_language[language_name] in preferences.languages) && language_points == (max_languages - 1)) // this is a new language and we can only pick a language to understand
		to_chat(user, span_warning("You have too many languages learned!"))
		return TRUE

	preferences.languages[name_to_language[language_name]] = LANGUAGE_SPOKEN
	return TRUE

/**
 * Proc that gives understanding capabilities only of a language to a character,
 * granted that they don't already have too many of them, based on their maximum amount of languages.
 *
 * Returns TRUE all the time, to ensure that the UI is updated.
 */
/datum/preference_middleware/languages/proc/understand_language(list/params, mob/user)
	var/language_name = params["language_name"]
	var/language_points = define_language_points()
	var/max_languages = define_max_languages()
	if(preferences.languages && !(name_to_language[language_name] in preferences.languages) && language_points == max_languages) // this is a new language and we're at the limit
		to_chat(user, span_warning("You have too many languages learned!"))
		return TRUE

	preferences.languages[name_to_language[language_name]] = LANGUAGE_UNDERSTOOD
	return TRUE

/**
 * Proc that takes away speaking capabilities of a language from a character.
 *
 * Returns TRUE all the time, to ensure that the UI is updated.
 */
/datum/preference_middleware/languages/proc/forget_speak_language(list/params, mob/user)
	var/language_name = params["language_name"]
	preferences.languages[name_to_language[language_name]] = LANGUAGE_UNDERSTOOD
	return TRUE

/**
 * Proc that takes away speaking and understanding capabilities of a language from a character.
 *
 * Returns TRUE all the time, to ensure that the UI is updated.
 */
/datum/preference_middleware/languages/proc/forget_understand_language(list/params, mob/user)
	var/language_name = params["language_name"]
	preferences.languages -= name_to_language[language_name]
	return TRUE
