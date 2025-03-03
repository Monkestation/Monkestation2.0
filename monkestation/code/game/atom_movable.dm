/atom/movable
	// Text-to-bark sounds
	var/vocal_bark_id = "Talk 1"
	var/datum/bark_voice/vocal_bark = null
	var/vocal_pitch = 1
	var/vocal_pitch_range = 0.2 //Actual pitch is (pitch - (vocal_pitch_range*0.5)) to (pitch + (vocal_pitch_range*0.5))
	var/vocal_volume = 70 //Baseline. This gets modified by yelling and other factors
	var/vocal_speed = 4 //Lower values are faster, higher values are slower

	var/vocal_current_bark = -1 //When barks are queued, this gets passed to the bark proc. If vocal_current_bark doesn't match the args passed to the bark proc (if passed at all), then the bark simply doesn't play. Basic curtailing of spam~

/// Sets the vocal bark for the atom, using the bark's ID
/atom/movable/proc/set_bark(id)
	if(!id)
		return FALSE
	var/datum/bark_voice/vocal_bark = GLOB.bark_list[id]
	if(!vocal_bark)
		return FALSE
	vocal_bark_id = id
	src.vocal_bark = vocal_bark
	return vocal_bark

/atom/movable/proc/start_barking(message, list/hearers, range, talk_icon_state)
	var/mob/mob_src = src

	if(!istype(mob_src) || !mob_src.client)
		return

	var/is_yell = talk_icon_state == "2"
	var/volume = vocal_volume * (is_yell ? 1.5 : 1)

	if (!vocal_bark)
		if (!vocal_bark_id)
			return
		vocal_bark = GLOB.bark_list[vocal_bark_id]
		if (!vocal_bark)
			return

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
			speak_sound = vocal_bark.ask_beep
		else if (ending == "!")
			speak_sound = vocal_bark.exclaim_beep
		if (speak_sound == null)
			speak_sound = vocal_bark.talk
		for(var/mob/M in short_hearers)
			M.playsound_local(src, speak_sound, 300, FALSE, 1, sound_range, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(range), pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)

	// long
	if (long_hearers.len)
		long_bark(long_hearers, sound_range, volume, is_yell, LAZYLEN(message))

/atom/movable/proc/long_bark(list/hearers, sound_range, volume, is_yell, message_len)
	var/barks = min(round((message_len / vocal_speed)) + 1, BARK_MAX_BARKS)

	var/total_delay
	vocal_current_bark = world.time //this is juuuuust random enough to reliably be unique every time send_speech() is called, in most scenarios
	for(var/i in 1 to barks)
		if(total_delay > BARK_MAX_TIME)
			break
		addtimer(CALLBACK(src, /atom/movable/proc/bark, hearers, sound_range, volume, BARK_DO_VARY(vocal_pitch, vocal_pitch_range), vocal_current_bark, vocal_bark.talk), total_delay)
		total_delay += rand(DS2TICKS((vocal_speed / BARK_SPEED_BASELINE) * (is_yell ? 0.5 : 1)), DS2TICKS(vocal_speed / BARK_SPEED_BASELINE) + DS2TICKS((vocal_speed / BARK_SPEED_BASELINE) * (is_yell ? 0.5 : 1))) TICKS
	return total_delay

/atom/movable/proc/bark(list/hearers, distance, volume, pitch, queue_time, talk_sound)
	if(queue_time && vocal_current_bark != queue_time)
		return

	volume = min(volume, 100)
	var/turf/T = get_turf(src)
	for(var/mob/M in hearers)
		M.playsound_local(T, soundin=talk_sound)
		// M.playsound_local(T, vol = volume, vary = TRUE, frequency = pitch, max_distance = distance, falloff_distance = 0, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(distance), sound_to_use = talk_sound, distance_multiplier = 1)
	// playsound(src, talk_sound, 50, FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)
