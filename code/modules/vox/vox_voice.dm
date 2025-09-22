#ifdef AI_VOX
/// A list of all files of the sounds of all VOX voices.
/// This list is populated by [/datum/vox_voice/New()]
GLOBAL_LIST_EMPTY(all_vox_sounds)
/// An associative list of voice names to /datum/vox_voice instances.
GLOBAL_LIST_INIT_TYPED(vox_voices, /datum/vox_voice, initialize_vox_voices())

/// An voice used by the VOX speech system.
/datum/vox_voice
	/// The name/ID of the voice.
	var/name
	/// The default volume of the voice.
	var/volume = 100
	/// An associative list of words to their respective sound file.
	var/list/sounds
	/// A list of all the words this voice supports.
	/// Automatically filled based on the `sounds` list during `New()`.
	var/list/words = list()

/datum/vox_voice/New()
	var/list/all_vox_sounds = GLOB.all_vox_sounds
	for(var/name in sounds)
		var/file = sounds[name]
		all_vox_sounds += file
		words += name

/datum/vox_voice/Destroy(force)
	if(!force)
		. = QDEL_HINT_LETMELIVE
		CRASH("Tried to delete a /datum/vox_voice, this should not happen!")
	return ..()

/// Sends the sound for the given word.
/// If `origin_turf` is set, only mobs on the same/linked z-level as the origin turf will hear it. This argument is ignored if `only_listener` is set.
/// If `only_listener`, only that mob will hear it. This will NOT do the usual checks for preferences, z-levels, and deafness.
/// If `check_hearing` is TRUE (default), then deafened players will be skipped over. This argument is ignored if `only_listener` is set.
/// Returns FALSE if the word doesn't exist, TRUE otherwise.
/datum/vox_voice/proc/play_word(word, turf/origin_turf, mob/only_listener, check_hearing = TRUE)
	word = lowertext(word)

	var/sound_file = sounds[word]
	if(isnull(sound_file))
		return FALSE
	var/sound/voice = sound(sound_file, wait = TRUE, channel = CHANNEL_VOX, volume = volume)
	voice.status = SOUND_STREAM

	var/list/listeners
	if(!isnull(only_listener))
		listeners = list(only_listener)
	else
		LAZYINITLIST(listeners)
		for(var/mob/player_mob as anything in GLOB.player_list)
			if(player_mob.client && !player_mob.client?.prefs)
				stack_trace("[player_mob] ([player_mob.ckey]) has null prefs, which shouldn't be possible!")
				continue
			if(check_hearing && !player_mob.can_hear())
				continue
			if(!player_mob.client?.prefs?.read_preference(/datum/preference/toggle/sound_vox))
				continue
			if(!isnull(origin_turf))
				var/turf/player_turf = get_turf(player_mob)
				if(!is_valid_z_level(origin_turf, player_turf))
					continue
			listeners += player_mob
	for(var/mob/listener as anything in listeners)
		if(!QDELETED(listener))
			SEND_SOUND(listener, voice)
	return TRUE

/proc/initialize_vox_voices()
	. = list()
	for(var/datum/vox_voice/voice_type as anything in subtypesof(/datum/vox_voice))
		var/name = voice_type::name
		if(!name)
			continue
		.[name] = new voice_type
#endif
