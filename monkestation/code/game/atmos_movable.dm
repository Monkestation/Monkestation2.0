/atom/movable
	// Text-to-bark sounds
	var/sound/vocal_bark
	var/vocal_bark_id
	var/vocal_pitch = 1
	var/vocal_pitch_range = 0.2 //Actual pitch is (pitch - (vocal_pitch_range*0.5)) to (pitch + (vocal_pitch_range*0.5))
	var/vocal_volume = 70 //Baseline. This gets modified by yelling and other factors
	var/vocal_speed = 4 //Lower values are faster, higher values are slower

	var/vocal_current_bark //When barks are queued, this gets passed to the bark proc. If vocal_current_bark doesn't match the args passed to the bark proc (if passed at all), then the bark simply doesn't play. Basic curtailing of spam~

/atom/movable/vv_edit_var(var_name, var_value, massedit)
	if(NAMEOF(src, vocal_bark))
		if(isfile(var_value))
			vocal_bark = sound(var_value) //bark() expects vocal_bark to already be a sound datum, for performance reasons. adminbus QoL!
		. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	return ..()

/// Sets the vocal bark for the atom, using the bark's ID
/atom/movable/proc/set_bark(id)
	if(!id)
		return FALSE
	var/datum/bark/B = GLOB.bark_list[id]
	if(!B)
		return FALSE
	vocal_bark = sound(initial(B.soundpath))
	vocal_bark_id = id
	return vocal_bark

/atom/movable/proc/send_bark(message, list/hearers, range, volume, is_yell)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_QUEUE_BARK, hearers, args) || vocal_bark || vocal_bark_id)
		for(var/mob/M in hearers)
			if(!M.client)
				continue
			if(!(M.client.prefs.toggles & SOUND_BARK))
				hearers -= M
		var/barks = min(round((LAZYLEN(message) / vocal_speed)) + 1, BARK_MAX_BARKS)
		var/total_delay
		vocal_current_bark = world.time //this is juuuuust random enough to reliably be unique every time send_speech() is called, in most scenarios
		for(var/i in 1 to barks)
			if(total_delay > BARK_MAX_TIME)
				break
			addtimer(CALLBACK(src, /atom/movable/proc/bark, hearers, range, volume, BARK_DO_VARY(vocal_pitch, vocal_pitch_range), vocal_current_bark), total_delay)
			total_delay += rand(DS2TICKS((vocal_speed / BARK_SPEED_BASELINE) * (is_yell ? 0.5 : 1)), DS2TICKS(vocal_speed / BARK_SPEED_BASELINE) + DS2TICKS((vocal_speed / BARK_SPEED_BASELINE) * (is_yell ? 0.5 : 1))) TICKS

/atom/movable/proc/bark(list/hearers, distance, volume, pitch, queue_time)
	if(queue_time && vocal_current_bark != queue_time)
		return
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_BARK, hearers, distance, volume, pitch))
		return //bark interception. this probably counts as some flavor of BDSM
	if(!vocal_bark)
		if(!vocal_bark_id || !set_bark(vocal_bark_id)) //just-in-time bark generation
			return
	volume = min(volume, 100)
	var/turf/T = get_turf(src)
	for(var/mob/M in hearers)
		M.playsound_local(T, vol = volume, vary = TRUE, frequency = pitch, max_distance = distance, falloff_distance = 0, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(distance), S = vocal_bark, distance_multiplier = 1)
