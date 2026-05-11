GLOBAL_DATUM_INIT(language_holder_adjustor, /datum/language_holder_adjustor, new)

/// Language code needs to be purged. Make sure, once and for all, that we get the correct languages on spawn.
/// Every time a crew member joins the adjustor will personally fix their language, because there is too much coupling between mind and language code to do it reliably otherwise.
/// It has already needed to be fixed like 3 times. This will (hopefully) be the final time.
/datum/language_holder_adjustor/New()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(handle_new_player))

/datum/language_holder_adjustor/proc/handle_new_player(datum/source, mob/living/carbon/human/new_crewmember, rank)
	SIGNAL_HANDLER

	// sanity checking because we really do not want to be causing any runtimes
	if(!istype(new_crewmember))
		return
	if(isnull(new_crewmember.mind))
		return

	var/datum/language_holder/language_holder = new_crewmember.get_language_holder()

	if(isnull(language_holder))
		return

	language_holder.adjust_languages_to_prefs(new_crewmember.client?.prefs)

/datum/language_holder_adjustor/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/language_holder/proc/adjust_languages_to_prefs(datum/preferences/preferences, mob/living/carbon/human/new_crewmember)
	// no prefs? then don't remove any languages
	if(!preferences)
		return

	// remove the innate languages (like common, and other species languages) and instead use the language prefs
	// do not remove any languages granted by spawners, which are denoted by source = LANGUAGE_SPAWNER
	remove_languages_by_source(list(LANGUAGE_MIND, LANGUAGE_ATOM, LANGUAGE_SPECIES, LANGUAGE_TONGUE))
	selected_language = null // reset it to recalculate after applying our prefs

	for(var/lang_path in preferences.languages)
		grant_language(lang_path, (preferences.languages[lang_path] == LANGUAGE_SPOKEN ? ALL : UNDERSTOOD_LANGUAGE))

	get_selected_language()

/// Removes every language whose source(s) match the provided source list arg
/datum/language_holder/proc/remove_languages_by_source(list/sources)
	if(!length(sources))
		return
	for(var/language in understood_languages)
		for(var/source in sources)
			remove_language(language, ALL, source)
	// in most cases spoken_languages should be empty by now, but just in case we should remove what's left
	for(var/language in spoken_languages)
		for(var/source in sources)
			remove_language(language, ALL, source)

//************************************************
//*        Specific language holders              *
//*      Use atom language sources only.           *
//************************************************/

/// Modularized the Cyborg and AI language_holder, add here the languages that you want them to be able to speak and understand.
/datum/language_holder/synthetic/
	understood_languages = list()
	spoken_languages = list()

	/// list of [/datum/language]s (typepaths of them) with [/datum/language/var/secret] but still known by our borgs and AIs (not covered by GLOB.uncommon_roundstart_languages)
	var/static/list/known_secret_languages = list(
		/datum/language/ashtongue,
		/datum/language/beachbum,
		/datum/language/terrum,
		/datum/language/shadowtongue,
		/datum/language/wawa,
	)

/datum/language_holder/synthetic/New(atom/new_owner)
	. = ..()
	remove_all_languages() // tabula rasa. we dont need anything from TG in here

	for (var/datum/language/language as anything in GLOB.all_languages)
		if(language::secret && !(language in GLOB.uncommon_roundstart_languages)) // should align with all languages available to anyone from character preferences
			continue
		grant_language(language, source = LANGUAGE_ATOM)

	for (var/datum/language/language as anything in known_secret_languages)
		grant_language(language, source = LANGUAGE_ATOM)

	if(owner) // may be initialized without one, especially during init
		get_selected_language()
