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

	//monkestation edit
	///Play a sound to indicate we just spoke
	// if(client && !HAS_TRAIT(src, TRAIT_SIGN_LANG))
	// 	var/ending = copytext_char(message, -1)
	// 	var/sound/speak_sound
	// 	if(HAS_TRAIT(src, TRAIT_HELIUM))
	// 		speak_sound = sound('monkestation/sound/effects/helium_squeak.ogg')
	// 	else if(ending == "?")
	// 		speak_sound = voice_type2sound[voice_type]["?"]
	// 	else if(ending == "!")
	// 		speak_sound = voice_type2sound[voice_type]["!"]
	// 	else
	// 		speak_sound = voice_type2sound[voice_type][voice_type]
	// 	playsound(src, speak_sound, 300, 1, SHORT_RANGE_SOUND_EXTRARANGE-2, falloff_exponent = 0, pressure_affected = FALSE, ignore_walls = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)
	//monkestation edit end

/atom/movable/proc/send_bark(message, list/hearers, range, is_yell)
	var/mob/mob_src = src

	if(!istype(mob_src) || !mob_src.client)
		return

	var/volume = vocal_volume * (is_yell ? 1.5 : 1)

	// if(!vocal_bark && !vocal_bark_id)
	// 	return

	// for(var/mob/M in hearers)
	// 	if(!M.client)
	// 		continue
		// if(!(M.client.prefs.toggles & SOUND_BARK))
		// 	hearers -= M
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
	// if(!vocal_bark)
	// 	if(!vocal_bark_id || !set_bark(vocal_bark_id)) //just-in-time bark generation
	// 		return

	var/vocal_bark = sound('goon/sounds/speak_1.ogg')
	volume = min(volume, 100)
	var/turf/T = get_turf(src)
	for(var/mob/M in hearers)
		M.playsound_local(T, vol = volume, vary = TRUE, frequency = pitch, max_distance = distance, falloff_distance = 0, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(distance), sound_to_use = vocal_bark, distance_multiplier = 1)
