///Default override for echo
/sound
	echo = list(
		0, // Direct
		0, // DirectHF
		-10000, // Room, -10000 means no low frequency sound reverb
		-10000, // RoomHF, -10000 means no high frequency sound reverb
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)
	environment = SOUND_ENVIRONMENT_NONE //Default to none so sounds without overrides dont get reverb

/**
 * playsound is a proc used to play a 3D sound in a specific range. This uses SOUND_RANGE + extra_range to determine that.
 *
 * source - Origin of sound.
 * soundin - Either a file, or a string that can be used to get an SFX.
 * vol - The volume of the sound, excluding falloff and pressure affection.
 * vary - bool that determines if the sound changes pitch every time it plays.
 * extrarange - modifier for sound range. This gets added on top of SOUND_RANGE.
 * falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * frequency - playback speed of audio.
 * channel - The channel the sound is played at.
 * pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space).
 * ignore_walls - Whether or not the sound can pass through walls.
 * falloff_distance - Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 */
/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE, mixer_channel)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	if(islist(soundin))
		CRASH("playsound(): soundin attempted to pass a list! Consider using pick()")

	var/turf/turf_source = get_turf(source)

	if (!turf_source || !soundin || !vol)
		return

	if(!mixer_channel)
		mixer_channel = guess_mixer_channel(soundin)

	if(vol < SOUND_AUDIBLE_VOLUME_MIN) // never let sound go below SOUND_AUDIBLE_VOLUME_MIN or bad things will happen
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

	var/sound/S = sound(get_sfx(soundin))
	var/maxdistance = SOUND_RANGE + extrarange
	var/source_z = turf_source.z

	if (falloff_distance >= maxdistance)
		CRASH("playsound(): falloff_distance is equal to or higher than maxdistance! Bump up extrarange or reduce the falloff_distance.")

	if(vary && !frequency)
		frequency = get_rand_frequency() // skips us having to do it per-sound later. should just make this a macro tbh

	var/list/listeners

	var/turf/above_turf = GET_TURF_ABOVE(turf_source)
	var/turf/below_turf = GET_TURF_BELOW(turf_source)

	var/audible_distance = falloff_exponent ? CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE(vol, maxdistance, falloff_distance, falloff_exponent) : maxdistance

	if(ignore_walls)
		listeners = get_hearers_in_range(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)
		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_range(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_range(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

	else //these sounds don't carry through walls
		listeners = get_hearers_in_view(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_view(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_view(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
		for(var/mob/listening_ghost as anything in SSmobs.dead_players_by_zlevel[source_z])
			if(get_dist(listening_ghost, turf_source) <= audible_distance)
				listeners += listening_ghost

	for(var/mob/listening_mob as anything in listeners)
		listening_mob?.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, 1, use_reverb, mixer_channel)

	return listeners

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/sound_to_use, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = 1, use_reverb = TRUE, mixer_channel = 0)
	if(!client || !can_hear())
		return

	if(!sound_to_use)
		sound_to_use = sound(get_sfx(soundin))

	sound_to_use.wait = 0 //No queue
	sound_to_use.channel = channel || SSsounds.random_available_channel()
	sound_to_use.volume = vol

	if((mixer_channel == CHANNEL_PRUDE) && client?.prefs?.read_preference(/datum/preference/toggle/prude_mode))
		return

	if (HAS_TRAIT_FROM(src, TRAIT_HARD_OF_HEARING, EAR_DAMAGE))
		sound_to_use.volume *= 0.2

	if(vary)
		if(frequency)
			sound_to_use.frequency = frequency
		else
			sound_to_use.frequency = get_rand_frequency()

	var/distance = 0

	if(isturf(turf_source))
		var/turf/turf_loc = get_turf(src)

		//sound volume falloff with distance
		distance = get_dist(turf_loc, turf_source) * distance_multiplier

		if(max_distance && falloff_exponent) //If theres no max_distance we're not a 3D sound, so no falloff.
			sound_to_use.volume -= CALCULATE_SOUND_VOLUME(vol, distance, max_distance, falloff_distance, falloff_exponent)

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = turf_loc.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			sound_to_use.volume *= pressure_factor
			//End Atmosphere affecting sound

		if(sound_to_use.volume < SOUND_AUDIBLE_VOLUME_MIN)
			return //No sound

		var/dx = turf_source.x - turf_loc.x // Hearing from the right/left
		sound_to_use.x = dx * distance_multiplier
		var/dz = turf_source.y - turf_loc.y // Hearing from infront/behind
		sound_to_use.z = dz * distance_multiplier
		var/dy = (turf_source.z - turf_loc.z) * 5 * distance_multiplier // Hearing from  above / below, multiplied by 5 because we assume height is further along coords.
		sound_to_use.y = dy

		sound_to_use.falloff = max_distance || 1 //use max_distance, else just use 1 as we are a direct sound so falloff isnt relevant.

		// Sounds can't have their own environment. A sound's environment will be:
		// 1. the mob's
		// 2. the area's (defaults to SOUND_ENVRIONMENT_NONE)
		if(sound_environment_override != SOUND_ENVIRONMENT_NONE)
			sound_to_use.environment = sound_environment_override
		else
			var/area/A = get_area(src)
			sound_to_use.environment = A.sound_environment

		if(turf_source != get_turf(src))
			sound_to_use.echo = list(0,0,0,0,0,0,-10000,1.0,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
		else
			sound_to_use.echo = list(0,0,0,0,0,0,0,0.25,1.5,1.0,0,1.0,0,0,0,0,1.0,7)

		if(!use_reverb)
			sound_to_use.echo[3] = -10000
			sound_to_use.echo[4] = -10000

	if(HAS_TRAIT(src, TRAIT_SOUND_DEBUGGED))
		to_chat(src, span_admin("Max Range-[max_distance] Distance-[distance] Vol-[round(sound_to_use.volume, 0.01)] Sound-[sound_to_use.file]"))

	if(!mixer_channel)
		if(channel in GLOB.used_sound_channels)
			mixer_channel = channel
		else
			mixer_channel = guess_mixer_channel(soundin)

	sound_to_use.volume = calculate_mixed_volume(client, sound_to_use.volume, mixer_channel)

	SEND_SOUND(src, sound_to_use)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, null, channel, pressure_affected, S)

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music_done) //wait for SSticker init to set the login music // monkestation edit: fix-lobby-music
	UNTIL(fully_created)
	var/list/channel_volume = prefs?.channel_volume
	if("[CHANNEL_LOBBYMUSIC]" in channel_volume)
		vol = channel_volume["[CHANNEL_LOBBYMUSIC]"]
	if("[CHANNEL_MASTER_VOLUME]" in channel_volume)
		vol *= channel_volume["[CHANNEL_MASTER_VOLUME]"] * 0.01
	if(vol <= 0 || (prefs && (!prefs.read_preference(/datum/preference/toggle/sound_lobby))) || CONFIG_GET(flag/disallow_title_music))
		return

	if(QDELETED(media_player)) ///media is set on creation thats weird
		media_player = new(src)

	if(!length(SSmedia_tracks.lobby_tracks))
		return

	if(SSmedia_tracks.first_lobby_play)
		SSmedia_tracks.current_lobby_track = pick(SSmedia_tracks.lobby_tracks)
		// monkestation edit start: fix-lobby-music
		if (fexists("data/last_round_lobby_music.txt"))
			fdel("data/last_round_lobby_music.txt")
		text2file(SSmedia_tracks.current_lobby_track.url, "data/last_round_lobby_music.txt")
		// monkestation edit end
		SSmedia_tracks.first_lobby_play = FALSE
		GLOB.lobby_media.current_track = SSmedia_tracks.current_lobby_track
		GLOB.lobby_media.update_for_all_listeners()

	GLOB.lobby_media.add_listener(mob)
	var/datum/media_track/track = SSmedia_tracks.current_lobby_track
	to_chat(src, span_notice("Lobby music: <b>[track.title]</b> by <b>[track.artist]</b>."))

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	var/datum/sound_effect/sfx = SSsounds.sfx_datum_by_key[soundin]
	return sfx?.return_sfx() || soundin

/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_MASTER_VOLUME)
			return "Master Volume"
		if(CHANNEL_LOBBYMUSIC)
			return "Lobby Music"
		if(CHANNEL_ADMIN)
			return "Admin MIDIs"
		if(CHANNEL_VOX)
			return "Announcements / AI Noise"
		if(CHANNEL_JUKEBOX)
			return "Dance Machines"
		if(CHANNEL_HEARTBEAT)
			return "Heartbeat"
		if(CHANNEL_BUZZ)
			return "White Noise"
		if(CHANNEL_CHARGED_SPELL)
			return "Charged Spells"
		if(CHANNEL_TRAITOR)
			return "Traitor Sounds"
		if(CHANNEL_AMBIENCE)
			return "Ambience"
		if(CHANNEL_SOUND_EFFECTS)
			return "Sound Effects"
		if(CHANNEL_SOUND_FOOTSTEPS)
			return "Footsteps"
		if(CHANNEL_WEATHER)
			return "Weather"
		if(CHANNEL_MACHINERY)
			return "Machinery"
		if(CHANNEL_INSTRUMENTS)
			return "Player Instruments"
		if(CHANNEL_INSTRUMENTS_ROBOT)
			return "Robot Instruments" //you caused this DONGLE
		if(CHANNEL_MOB_SOUNDS)
			return "Mob Sounds"
		if(CHANNEL_PRUDE)
			return "Prude Sounds"
		if(CHANNEL_SQUEAK)
			return "Squeaks / Plushies"
		if(CHANNEL_MOB_EMOTES)
			return "Mob Emotes"
		if(CHANNEL_SILICON_EMOTES)
			return "Silicon Emotes"
		if(CHANNEL_VOICES)
			return "Voices"
		if(CHANNEL_RINGTONES)
			return "Ringtones (Modlinks/PDA)"
