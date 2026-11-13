/datum/weather/wonderland
	name = "wonderland meadow"
	desc = "Petals fall from a sky that is not there."

	telegraph_duration = 0
	telegraph_message = null
	telegraph_overlay = "light_snow"

	weather_message = null
	weather_overlay = "light_snow"
	weather_color = "#ff9eb5"

	end_message = null
	end_overlay = "light_snow"

	area_type = /area
	protected_areas = list(/area/space)
	target_trait = ZTRAIT_STATION

	aesthetic = TRUE
	perpetual = TRUE
	/// Timer id of the music loop.
	var/music_timer
	/// Areas we gave a base lighting tint, so we can take it back off.
	var/list/area/tinted_areas = list()

/datum/weather/wonderland/start()
	. = ..()
	music_timer = addtimer(CALLBACK(src, PROC_REF(play_music)), SSsounds.get_sound_length('sound/ambience/wonderland.ogg'), TIMER_LOOP | TIMER_STOPPABLE)
	play_music()
	tint_areas()

/datum/weather/wonderland/end()
	deltimer(music_timer)
	for(var/area/tinted as anything in tinted_areas)
		tinted.set_base_lighting(new_alpha = 0)
	tinted_areas.Cut()
	return ..()

/// ambient_buzz would go quiet in any room with a dead APC, and never plays for ghosts
/datum/weather/wonderland/proc/play_music()
	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || !is_station_level(listener_turf.z))
			continue
		listener.playsound_local(null, 'sound/ambience/wonderland.ogg', 20, channel = CHANNEL_WEATHER)

/// Rooms that already set their own base lighting (space, solars) are left alone, we could not put them back
/datum/weather/wonderland/proc/tint_areas()
	for(var/area/tinted as anything in impacted_areas)
		if(tinted.base_lighting_alpha)
			continue
		tinted.set_base_lighting(weather_color, 35)
		tinted_areas += tinted
		CHECK_TICK
