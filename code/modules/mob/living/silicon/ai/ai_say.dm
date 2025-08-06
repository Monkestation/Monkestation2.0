/mob/living/silicon/ai/say(message, bubble_type,list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if(parent && istype(parent) && parent.stat != DEAD) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		return parent.say(arglist(args))
	return ..()

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
//	var/mob/M = speaker.GetSource() // MONKESTATION EDIT OLD
	var/mob/M = speaker.GetJob() // MONKESTATION EDIT NEW -- NTSL
	if(M)
		return "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	if(jobtitles)
		return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"
	return "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	// AIs cannot speak if silent AI is on.
	// Unless forced is set, as that's probably stating laws or something.
	if(!forced && CONFIG_GET(flag/silent_ai))
		to_chat(src, span_danger("The ability for AIs to speak is currently disabled via server config."))
		return FALSE

	return ..()

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)

	if (!message)
		return

	var/obj/machinery/holopad/active_pad = current
	if(istype(active_pad) && active_pad.masters[src])//If there is a hologram and its master is the user.
		var/obj/effect/overlay/holo_pad_hologram/ai_holo = active_pad.masters[src]
		var/turf/padturf = get_turf(active_pad)
		var/padloc
		if(padturf)
			padloc = AREACOORD(padturf)
		else
			padloc = "(UNKNOWN)"
		src.log_talk(message, LOG_SAY, tag="HOLOPAD in [padloc]")
		ai_holo.say(message, sanitize = FALSE, language = language)
	else
		to_chat(src, span_alert("No holopad connected."))


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
/mob/living/silicon/ai
	var/datum/vox_holder/ai/vox_holder

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	. = ..()
	vox_holder = new(src)

/mob/living/silicon/ai/Destroy()
	QDEL_NULL(vox_holder)
	return ..()

/datum/vox_holder/ai
	check_hearing = TRUE
	var/mob/living/silicon/ai/parent

/datum/vox_holder/ai/New(mob/living/silicon/ai/parent)
	. = ..()
	src.parent = parent

/datum/vox_holder/ai/Destroy(force)
	parent = null
	return ..()

/datum/vox_holder/ai/ui_host(mob/user)
	return parent

/datum/vox_holder/ai/ui_state(mob/user)
	return GLOB.default_state

/datum/vox_holder/ai/default_origin_turf(mob/speaker)
	return get_turf(parent)

/proc/play_vox_word_legacy(word, ai_turf, mob/only_listener)

	word = lowertext(word)

	var/datum/vox_voice/used_vox_voice = GLOB.vox_voices[/datum/vox_voice/normal::name]
	if(used_vox_voice.sounds[word])
		var/sound_file = used_vox_voice.sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM

	// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/player_mob as anything in GLOB.player_list)
				if(player_mob.client && !player_mob.client?.prefs)
					stack_trace("[player_mob] ([player_mob.ckey]) has null prefs, which shouldn't be possible!")
					continue

				if(!player_mob.can_hear() || !(player_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_vox)))
					continue

				var/turf/player_turf = get_turf(player_mob)
				if(!is_valid_z_level(ai_turf, player_turf))
					continue

				SEND_SOUND(player_mob, voice)
		else
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE
#endif
