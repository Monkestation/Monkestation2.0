#ifdef AI_VOX
/// Maximum amount of words to allow in a VOX message.
#define MAX_WORDS 30

/datum/vox_holder
	/// The current [/datum/vox_voice] instance being used.
	VAR_PRIVATE/datum/vox_voice/current_voice
	/// Whether this VOX holder checks to see if mobs can hear or not by default.
	var/check_hearing = FALSE
	/// The VOX word(s) that were previously inputed.
	var/previous_words
	/// The cooldown between VOX announcements.
	var/cooldown = 1 MINUTES
	/// Cooldown on making VOX announcements.
	COOLDOWN_DECLARE(announcement_cooldown)

/datum/vox_holder/New()
	set_voice(/datum/vox_voice/normal)

/datum/vox_holder/Destroy(force)
	current_voice = null
	return ..()

/datum/vox_holder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VOX")
		ui.open()

/datum/vox_holder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("set_voice")
			var/new_voice = params["voice"]
			if(!isnull(new_voice))
				set_voice(new_voice)
			return TRUE
		if("speak")
			var/message = params["message"]
			if(message)
				speak(user, message)
			return TRUE
		if("test")
			var/message = params["message"]
			if(message)
				speak(user, message, test = TRUE)
			return TRUE

/datum/vox_holder/ui_data(mob/user)
	return list(
		"current_voice" = current_voice.name,
		"previous_words" = previous_words,
		"cooldown" = COOLDOWN_TIMELEFT(src, announcement_cooldown),
	)

/datum/vox_holder/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/json/vox_voices)) // this is an asset so we don't have to send a huge list each time

/datum/vox_holder/ui_state(mob/user)
	return GLOB.always_state

/datum/vox_holder/proc/default_name(mob/speaker)
	return "[speaker.real_name || speaker.name]"

/datum/vox_holder/proc/default_origin_turf(mob/speaker)
	return

/datum/vox_holder/proc/speak(mob/speaker, message, name_override, turf/origin_turf, test = FALSE, check_hearing)
	if(!test && !COOLDOWN_FINISHED(src, announcement_cooldown))
		return FALSE
	var/list/words = split_into_words(message)
	if(!words)
		return FALSE
	if(length(words) > MAX_WORDS)
		words.Cut(MAX_WORDS + 1)
	var/list/incorrect_words = list()
	for(var/word in words)
		if(!(word in current_voice.words))
			incorrect_words += word
	if(length(incorrect_words))
		to_chat(speaker, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return FALSE
	if(!test)
		COOLDOWN_START(src, announcement_cooldown, cooldown)
		speaker.log_message("made a vocal announcement with the following message: [message].", LOG_GAME)
		speaker.log_talk(message, LOG_SAY, tag = "VOX Announcement")
		minor_announce(capitalize(message), "[name_override || default_name(speaker)] announces:", should_play_sound = FALSE)
	if(isnull(check_hearing))
		check_hearing = src.check_hearing
	if(isnull(origin_turf))
		origin_turf = default_origin_turf(speaker)
	for(var/word in words)
		current_voice.play_word(
			word,
			origin_turf = origin_turf,
			only_listener = test ? speaker : null,
			check_hearing = check_hearing,
		)
	return TRUE

/datum/vox_holder/proc/split_into_words(message)
	. = list()
	var/trimmed_message = trimtext(lowertext(message))
	for(var/word in splittext_char(trimmed_message, " "))
		word = trimtext(word)
		if(word)
			. += word

/// Sets the VOX voice to the given [/datum/vox_voice].
/// The `voice` argument can either be the name/ID of a voice, or a `/datum/vox_voice` typepath or instance.
/datum/vox_holder/proc/set_voice(datum/vox_voice/voice = /datum/vox_voice/normal)
	var/datum/vox_voice/new_voice
	if(istext(voice))
		new_voice = GLOB.vox_voices[voice]
	else if(ispath(voice, /datum/vox_voice))
		new_voice = GLOB.vox_voices[voice::name]
	else if(istype(voice, /datum/vox_voice))
		new_voice = voice
	if(new_voice == current_voice)
		return
	if(!istype(new_voice, /datum/vox_voice))
		CRASH("Invalid VOX voice instance: [new_voice || "null"]")
	current_voice = new_voice

#ifdef TESTING
GLOBAL_DATUM(test_vox_holder, /datum/vox_holder)

/mob/verb/aivox2()
	set name = "VOX Test UI"
	set desc = "vox refactor test ui"
	set category = "!! VOX !!"

	if(isnull(GLOB.test_vox_holder))
		GLOB.test_vox_holder = new

	GLOB.test_vox_holder.ui_interact(src)
#endif

#undef MAX_WORDS
#endif
