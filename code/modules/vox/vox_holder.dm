#ifdef AI_VOX
/datum/vox_holder
	/// The current [/datum/vox_voice] instance being used.
	VAR_PRIVATE/datum/vox_voice/current_voice
	/// The VOX word(s) that were previously inputed.
	var/previous_words

/datum/vox_holder/New()
	set_voice(/datum/vox_voice/normal)

/datum/vox_holder/Destroy(force)
	current_voice = null
	return ..()

/datum/vox_holder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("set_voice")
			. = TRUE
			var/new_voice = params["voice"]
			if(isnull(new_voice))
				return
			set_voice(new_voice)

/datum/vox_holder/ui_data(mob/user)
	return list(
		"current_voice" = current_voice.name,
		"previous_words" = previous_words,
	)

/datum/vox_holder/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/json/vox_voices)) // this is an asset so we don't have to send a huge list each time

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
#endif
