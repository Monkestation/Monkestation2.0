/datum/atom_voice
	var/datum/bark_voice/voice
	var/pitch = 1
	var/pitch_range = 0.2 //Actual pitch is (pitch - (vocal_pitch_range*0.5)) to (pitch + (vocal_pitch_range*0.5))
	var/volume = 50
	var/speed = 4 //Lower values are faster, higher values are slower

/datum/atom_voice/proc/set_bark(id)
	voice = GLOB.bark_list[id]

/datum/atom_voice/proc/copy_from(datum/atom_voice/other)
	voice = other.voice
	pitch = other.pitch
	pitch_range = other.pitch_range
	volume = other.volume
	speed = other.speed

/datum/atom_voice/proc/set_from_prefs(datum/preferences/prefs)
	if (!prefs)
		return
	set_bark(prefs.read_preference(/datum/preference/choiced/bark_voice))
	pitch = prefs.read_preference(/datum/preference/numeric/bark_speech_pitch)
	speed = prefs.read_preference(/datum/preference/numeric/bark_speech_speed)
	pitch_range = prefs.read_preference(/datum/preference/numeric/bark_pitch_range)

/datum/atom_voice/proc/randomise(atom/who)
	set_bark(pick(GLOB.random_barks))
	pitch = BARK_PITCH_RAND(who.gender)
	pitch_range = BARK_VARIANCE_RAND
	speed = rand(BARK_DEFAULT_MINSPEED, BARK_DEFAULT_MAXSPEED)
	volume = 50

// target.vocal_bark = null
// 	target.vocal_bark_id = pick(GLOB.bark_list)
// 	target.vocal_speed = round((BARK_DEFAULT_MINSPEED + BARK_DEFAULT_MAXSPEED) / 2)
// 	target.vocal_pitch = round((BARK_DEFAULT_MINPITCH + BARK_DEFAULT_MAXPITCH) / 2)
// 	target.vocal_pitch_range = 0.2

/atom/movable
	/// Used for initialisation
	var/initial_bark_id
	var/datum/atom_voice/voice
	/// When barks are queued, this gets passed to the bark proc. If long_bark_start_time doesn't match the args passed to the bark proc (if passed at all), then the bark simply doesn't play. Basic curtailing of spam~
	var/long_bark_start_time = -1

/atom/movable/New(loc, ...)
	. = ..()
	voice = new()
	if (initial_bark_id)
		voice.set_bark(initial_bark_id)
		initial_bark_id = null

/// Sets the vocal bark for the atom, using the bark's ID
/atom/movable/proc/set_bark(id)
	voice.set_bark(id)

/atom/movable/proc/start_barking(message, list/hearers, range, talk_icon_state)
	var/datum/atom_voice/atom_voice = src.voice
	var/datum/bark_voice/bark_voice = atom_voice.voice
	var/is_yell = talk_icon_state == "2"
	var/volume = min(atom_voice.volume * (is_yell ? 1.5 : 1), 100)

	/*TODO
	if (is_whisper)
		volume *= 0.5
		range += 1
	*/

	// if (!vocal_bark)
	// 	if (!vocal_bark_id)
	// 		return
	// 	vocal_bark = GLOB.bark_list[vocal_bark_id]
	// 	if (!vocal_bark)
	// 		return

	var/list/short_hearers = list()
	var/list/long_hearers = list()

	for(var/mob/M in hearers)
		if(!M.client)
			continue
		if(M.client.prefs.read_preference(/datum/preference/toggle/short_barks))
			short_hearers += M
		else
			long_hearers += M

	var/sound_range = SHORT_RANGE_SOUND_EXTRARANGE-2
	sound_range = range

	// short
	if (short_hearers.len)
		var/ending = copytext_char(message, -1)
		var/speak_sound
		if (ending == "?")
			speak_sound = bark_voice.ask_beep
		else if (ending == "!")
			speak_sound = bark_voice.exclaim_beep
		if (speak_sound == null)
			speak_sound = bark_voice.talk
		for(var/mob/M in short_hearers)
			M.playsound_local(src, speak_sound, 300, FALSE, 1, sound_range, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(range), pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)

	sound_range = range + 1

	// long
	if (long_hearers.len)
		long_bark(long_hearers, sound_range, volume, is_yell, atom_voice.speed, LAZYLEN(message))

/atom/movable/proc/long_bark(list/hearers, sound_range, volume, is_yell, message_len)
	var/vocal_pitch_range = voice.pitch_range
	var/sound/talk = voice.voice.talk

	var/vocal_speed = clamp(voice.speed, voice.voice.min_speed, voice.voice.max_speed)
	var/vocal_pitch = clamp(voice.pitch, voice.voice.min_pitch, voice.voice.max_pitch)

	var/num_barks = min(round((message_len / vocal_speed)) + 1, BARK_MAX_BARKS)
	var/total_delay = 0
	long_bark_start_time = world.time //this is juuuuust random enough to reliably be unique every time send_speech() is called, in most scenarios

	for(var/i in 1 to num_barks)
		if(total_delay > BARK_MAX_TIME)
			break
		addtimer(CALLBACK(src, /atom/movable/proc/bark, hearers, sound_range, volume, BARK_DO_VARY(vocal_pitch, vocal_pitch_range), long_bark_start_time, talk), total_delay)
		total_delay += rand(DS2TICKS((vocal_speed / BARK_SPEED_BASELINE)), DS2TICKS(vocal_speed / BARK_SPEED_BASELINE) + DS2TICKS((vocal_speed / BARK_SPEED_BASELINE) * (is_yell ? 0.5 : 1))) TICKS
	return total_delay

/atom/movable/proc/bark(list/hearers, distance, volume, pitch, queue_time, sound/talk_sound)
	if(queue_time && long_bark_start_time != queue_time)
		return

	pitch = clamp(pitch, BARK_DEFAULT_MINPITCH, BARK_DEFAULT_MAXPITCH)

	var/turf/T = get_turf(src)
	for(var/mob/M in hearers)
		M.playsound_local(T, vol = volume, vary = TRUE, frequency = pitch, max_distance = distance, falloff_distance = 0, use_reverb = FALSE, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(distance), sound_to_use = talk_sound, distance_multiplier = 1)
