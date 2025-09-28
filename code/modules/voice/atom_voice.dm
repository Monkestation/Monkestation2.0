/datum/atom_voice
	var/datum/voice_pack/voicepack
	var/pitch = 1
	var/pitch_range = 0.2 //Actual pitch is (pitch - (vocal_pitch_range*0.5)) to (pitch + (vocal_pitch_range*0.5))
	var/base_volume = 300
	var/speed = 6 //Lower values are faster, higher values are slower

/datum/atom_voice/proc/set_voice_pack(id)
	voicepack = GLOB.voice_pack_list[id]

/datum/atom_voice/proc/copy_from(datum/atom_voice/other)
	voicepack = other.voicepack
	pitch = other.pitch
	pitch_range = other.pitch_range
	base_volume = other.base_volume
	speed = other.speed

/datum/atom_voice/proc/set_from_prefs(datum/preferences/prefs)
	if (!prefs)
		return
	set_voice_pack(prefs.read_preference(/datum/preference/choiced/voice_pack))
	pitch = prefs.read_preference(/datum/preference/numeric/bark_speech_pitch)
	speed = prefs.read_preference(/datum/preference/numeric/bark_speech_speed)
	pitch_range = prefs.read_preference(/datum/preference/numeric/bark_pitch_range)

/datum/atom_voice/proc/randomise(atom/who)
	set_voice_pack(pick(GLOB.random_voice_packs))
	pitch = ((who.gender == MALE ? rand(60, 120) : (who.gender == FEMALE ? rand(80, 140) : rand(60,140))) / 100)
	pitch_range = 0.2
	speed = 6
	base_volume = 300

/datum/atom_voice/proc/start_barking(message, list/hearers, message_range, talk_icon_state, is_speaker_whispering, atom/movable/speaker)
	if (!voicepack || !GLOB.voices_enabled)
		return
	var/len = LAZYLEN(message)
	if (!len)
		return

	var/is_yell = talk_icon_state == "2"
	var/volume = min(base_volume * (is_yell ? 1.5 : 1), 300)
	var/sound_range = message_range + 1

	if (is_speaker_whispering)
		volume *= 0.5
		sound_range += 1

	var/list/short_hearers = null
	var/list/long_hearers = null
	var/cant_long_bark = !speaker.can_long_bark()

	for(var/mob/hearer in hearers)
		if(!hearer.client)
			continue
		if(cant_long_bark || hearer.client.prefs.read_preference(/datum/preference/toggle/barks_short))
			LAZYADD(short_hearers, hearer)
		else
			LAZYADD(long_hearers, hearer)

	if (LAZYLEN(short_hearers))
		var/sound_idx = 1
		if (is_yell)
			sound_idx = 3
		else if (talk_icon_state == "1")
			sound_idx = 2
		short_bark(short_hearers, sound_range, volume, 0, speaker, sound_idx)

	if (LAZYLEN(long_hearers))
		long_bark(long_hearers, sound_range, volume, is_yell, len, speaker)

/datum/atom_voice/proc/long_bark(list/hearers, sound_range, volume, is_yell, message_len, atom/movable/speaker)
	var/vocal_speed = clamp(speed, voicepack.min_speed, voicepack.max_speed)
	// Any bark speeds below this feature higher bark density, any speeds above feature lower bark density. Keeps barking length consistent
	var/bark_speed_baseline = 4
	var/base_duration = vocal_speed / bark_speed_baseline

	var/num_barks = min(round((message_len / vocal_speed)), 24)
	var/total_delay = 0
	speaker.long_bark_start_time = world.time //this is juuuuust random enough to reliably be unique every time send_speech() is called, in most scenarios

	for (var/i in 0 to num_barks)
		if (total_delay > (1.5 SECONDS))
			break
		addtimer(CALLBACK(src, PROC_REF(short_bark), hearers, sound_range, volume, speaker.long_bark_start_time, speaker), total_delay)
		total_delay += (DS2TICKS(base_duration) + rand(DS2TICKS(base_duration * (is_yell ? 0.5 : 1)))) TICKS
	return total_delay

/datum/atom_voice/proc/short_bark(list/hearers, distance, volume, queue_time, atom/movable/speaker, sound_idx=1, sound/sound_override=null)
	if(queue_time && speaker.long_bark_start_time != queue_time)
		return

	var/vocal_pitch = pitch + (rand(pitch_range * -50, pitch_range * 50) / 100)
	vocal_pitch = clamp(vocal_pitch, voicepack.min_pitch, voicepack.max_pitch)

	if(HAS_TRAIT(speaker, TRAIT_HELIUM))
		vocal_pitch *= 2
		volume *= 0.9

	// At lower ranges, we want the exponent to be below 1 so that whispers don't sound too awkward. At higher ranges, we want the exponent fairly high to make yelling less obnoxious
	var/falloff_exponent = distance / 7

	var/turf/turf = get_turf(speaker)
	for(var/mob/hearer in hearers)
		if(!hearer.client)
			continue
		var/pitch_to_use = 0
		var/sound/sound_to_use
		if (sound_override)
			sound_to_use = sound_override
		else
			if (hearer.client.prefs.read_preference(/datum/preference/toggle/voice_sounds_only_simple) && !voicepack.is_simple)
				sound_to_use = voicepack.simple_equiv.sounds[sound_idx]
				volume *= voicepack.simple_equiv.volume
			else
				volume *= voicepack.volume
				sound_to_use = voicepack.sounds[sound_idx]
			if (!hearer.client.prefs.read_preference(/datum/preference/toggle/barks_limited_pitch))
				pitch_to_use = vocal_pitch
		hearer.playsound_local(turf, vol = volume, vary = TRUE,
			max_distance = distance, falloff_distance = 0, use_reverb = FALSE,
			falloff_exponent = falloff_exponent,
			distance_multiplier = 1, mixer_channel = CHANNEL_VOICES,
			sound_to_use = sound_to_use,
			frequency = pitch_to_use,
			)
