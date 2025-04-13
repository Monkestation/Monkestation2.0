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

/// Sets the VOX voice to the given [/datum/vox_voice].
/datum/vox_holder/proc/set_voice(voice_type = /datum/vox_voice/normal)
	if(!ispath(voice_type, /datum/vox_voice))
		CRASH("Invalid VOX voice typepath: [voice_type]")
	var/datum/vox_voice/new_voice = GLOB.vox_voices[voice_type]
	if(isnull(new_voice))
		CRASH("Invalid VOX voice instance: [new_voice]")
	current_voice = new_voice
#endif
