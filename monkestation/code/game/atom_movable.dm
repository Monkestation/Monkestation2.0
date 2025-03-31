/datum/atom_voice
	var/datum/bark_sound/bark
	var/pitch = 1
	var/pitch_range = 0.2 //Actual pitch is (pitch - (vocal_pitch_range*0.5)) to (pitch + (vocal_pitch_range*0.5))
	var/volume = 100
	var/speed = 6 //Lower values are faster, higher values are slower

/datum/atom_voice/proc/set_bark(id)
	bark = GLOB.bark_list[id]

/datum/atom_voice/proc/copy_from(datum/atom_voice/other)
	bark = other.bark
	pitch = other.pitch
	pitch_range = other.pitch_range
	volume = other.volume
	speed = other.speed

/datum/atom_voice/proc/set_from_prefs(datum/preferences/prefs)
	if (!prefs)
		return
	set_bark(prefs.read_preference(/datum/preference/choiced/bark_sound))
	pitch = prefs.read_preference(/datum/preference/numeric/bark_speech_pitch)
	speed = prefs.read_preference(/datum/preference/numeric/bark_speech_speed)
	pitch_range = prefs.read_preference(/datum/preference/numeric/bark_pitch_range)

/datum/atom_voice/proc/randomise(atom/who)
	set_bark(pick(GLOB.random_barks))
	pitch = ((who.gender == MALE ? rand(60, 120) : (who.gender == FEMALE ? rand(80, 140) : rand(60,140))) / 100)
	pitch_range = 0.2
	speed = 6
	volume = 50

/atom/movable
	var/datum/atom_voice/voice = null
	/// When barks are queued, this gets passed to the bark proc. If long_bark_start_time doesn't match the args passed to the bark proc (if passed at all), then the bark simply doesn't play. Basic curtailing of spam~
	var/long_bark_start_time = -1

/atom/movable/proc/initial_bark_id()
	return null

/atom/movable/proc/get_or_init_voice(bark_id=null)
	if (voice)
		return voice
	voice = new()
	var/initial_bark_id = initial_bark_id()
	if (initial_bark_id)
		voice.set_bark(initial_bark_id)
		initial_bark_id = null
	return voice

/// Sets the vocal bark for the atom, using the bark's ID
/atom/movable/proc/set_bark(id)
	if (voice)
		voice.set_bark(id)
	else
		voice = new()
		voice.set_bark(id)

/atom/movable/proc/can_long_bark()
	return FALSE

/mob/initial_bark_id()
	return pick(GLOB.random_barks)

/mob/can_long_bark()
	return !isnull(client)

/atom/movable/proc/start_barking(message, list/hearers, message_range, talk_icon_state, is_speaker_whispering)
	var/datum/atom_voice/voice = get_or_init_voice()
	var/datum/bark_sound/bark = voice.bark
	if (!bark)
		return

	var/is_yell = talk_icon_state == "2"
	var/volume = min(voice.volume * (is_yell ? 1.5 : 1), 200)
	var/sound_range = message_range + 1

	if (is_speaker_whispering)
		volume *= 0.5
		sound_range += 1

	var/list/short_hearers = null
	var/list/long_hearers = null

	if (can_long_bark())
		for(var/mob/hearer in hearers)
			if(!hearer.client)
				continue
			if(hearer.client.prefs.read_preference(/datum/preference/toggle/short_barks))
				LAZYADD(short_hearers, hearer)
			else
				LAZYADD(long_hearers, hearer)
	else
		short_hearers = hearers

	if (LAZYLEN(short_hearers))
		var/speak_sound
		if (talk_icon_state == "1")
			speak_sound = bark.ask
		else if (is_yell)
			speak_sound = bark.exclaim
		if (!speak_sound)
			speak_sound = bark.talk
		short_bark(short_hearers, sound_range, volume, 0, speak_sound, voice)

	if (LAZYLEN(long_hearers))
		long_bark(long_hearers, sound_range, volume, is_yell, LAZYLEN(message))

/atom/movable/proc/long_bark(list/hearers, sound_range, volume, is_yell, message_len)
	var/vocal_speed = clamp(voice.speed, voice.bark.min_speed, voice.bark.max_speed)

	var/num_barks = min(round((message_len / vocal_speed)) + 1, 24)
	var/total_delay = 0
	long_bark_start_time = world.time //this is juuuuust random enough to reliably be unique every time send_speech() is called, in most scenarios

	// Any bark speeds below this feature higher bark density, any speeds above feature lower bark density. Keeps barking length consistent
	var/bark_speed_baseline = 4
	var/base_duration = vocal_speed / bark_speed_baseline

	for (var/i in 1 to num_barks)
		if (total_delay > (1.5 SECONDS))
			break
		addtimer(CALLBACK(src, /atom/movable/proc/short_bark, hearers, sound_range, volume, long_bark_start_time, voice.bark.talk, voice), total_delay)
		total_delay += (DS2TICKS(base_duration) + rand(DS2TICKS(base_duration * (is_yell ? 0.5 : 1)))) TICKS
	return total_delay

/atom/movable/proc/short_bark(list/hearers, distance, volume, queue_time, sound/sound_to_use, datum/atom_voice/voice)
	if(queue_time && long_bark_start_time != queue_time)
		return

	var/pitch = voice.pitch
	var/variance = voice.pitch_range
	pitch = rand(((pitch * 100) - (variance * 50)), ((pitch * 100) + (variance * 50))) / 100
	pitch = clamp(pitch, voice.bark.min_pitch, voice.bark.max_pitch)

	if(HAS_TRAIT(src, TRAIT_HELIUM))
		pitch *= 2
		volume *= 0.75

	// At lower ranges, we want the exponent to be below 1 so that whispers don't sound too awkward. At higher ranges, we want the exponent fairly high to make yelling less obnoxious
	var/falloff_exponent = distance / 7

	var/turf/turf = get_turf(src)
	for(var/mob/M in hearers)
		M.playsound_local(turf, vol = volume, vary = TRUE, frequency = pitch,
			max_distance = distance, falloff_distance = 0, use_reverb = FALSE,
			falloff_exponent = falloff_exponent, sound_to_use = sound_to_use,
			distance_multiplier = 1, mixer_channel = CHANNEL_BARKS)
