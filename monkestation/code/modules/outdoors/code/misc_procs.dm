/mob/living/carbon/proc/handle_weather(delta_time = 1)
	var/turf/turf = get_turf(src)
	if(!turf)
		return
	var/datum/particle_weather/current_weather_effect
	if(is_eclipse_level(turf.z))
		current_weather_effect = SSparticle_weather.running_eclipse_weather
	else
		current_weather_effect = SSparticle_weather.running_weather
	if(current_weather_effect && (turf.turf_flags & TURF_WEATHER))
		current_weather_effect.process_mob_effect(src, delta_time)

/// Play sound for all on-map clients on a given Z-level. Good for ambient sounds.
/proc/playsound_z(z, soundin, volume = 100, _mixer_channel)
	var/sound/S = sound(soundin)
	for(var/mob/M in GLOB.player_list)
		if(M.z in z)
			M.playsound_local(get_turf(M), soundin, volume, channel = CHANNEL_Z, soundin = S, mixer_channel = _mixer_channel)
