/**
 * A datum for sounds that need to loop, with a high amount of configurability.
 */
/datum/looping_sound
	/// (list or soundfile) Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end. In a list, path must have also be assigned a value or it will be assigned 0 and not play.
	var/mid_sounds
	/// The length of time to wait between playing mid_sounds.
	var/mid_length
	/// Amount of time to add/take away from the mid length, randomly
	var/mid_length_vary = 0
	/// If we should always play each sound once per loop of all sounds. Weights here only really effect order, and could be disgarded
	var/each_once = FALSE
	/// Whether if the sounds should be played in order or not. Defaults to FALSE.
	var/in_order = FALSE
	/// Override for volume of start sound.
	var/start_volume
	/// (soundfile) Played before starting the mid_sounds loop.
	var/start_sound
	/// How long to wait before starting the main loop after playing start_sound.
	var/start_length
	/// Override for volume of end sound.
	var/end_volume
	/// (soundfile) The sound played after the main loop has concluded.
	var/end_sound
	/// Chance per loop to play a mid_sound.
	var/chance
	/// Sound output volume.
	var/volume = 100
	/// Whether or not the sounds will vary in pitch when played.
	var/vary = FALSE
	/// The max amount of loops to run for.
	var/max_loops
	/// The extra range of the sound in tiles, defaults to 0.
	var/extra_range = 0
	/// How much the sound will be affected by falloff per tile.
	var/falloff_exponent
	/// The falloff distance of the sound.
	var/falloff_distance
	/// Are the sounds affected by pressure? Defaults to TRUE.
	var/pressure_affected = TRUE
	/// Are the sounds subject to reverb? Defaults to TRUE.
	var/use_reverb = TRUE
	/// Are we ignoring walls? Defaults to TRUE.
	var/ignore_walls = TRUE

	// State stuff
	/// The source of the sound, or the recipient of the sound.
	var/atom/parent
	/// The ID of the timer that's used to loop the sounds.
	var/timer_id
	/// Has the looping started yet?
	var/loop_started = FALSE
	/// If we're using cut_mid, this is the list we cut from
	var/list/cut_list
	/// The index of the current song we're playing in the mid_sounds list, only used if in_order is used
	var/audio_index = 1

	// Args
	/// Do we skip the starting sounds?
	var/skip_starting_sounds = FALSE
	/// If true, plays directly to provided atoms instead of from them.
	var/direct
	/// Sound channel to play on, random if not provided
	var/sound_channel

	// Live attenuation
	/// If TRUE, mid_sounds update listener volume/position while the current loop segment is still playing.
	var/live_attenuation = FALSE
	/// How often live attenuation refreshes listener volume/position.
	var/live_attenuation_interval = 0.5 SECONDS
	/// Absolute max distance this live loop can be heard from. If null, uses SOUND_RANGE + extra_range.
	var/live_attenuation_max_distance
	/// Mixer channel used for client volume preferences during live attenuation.
	var/live_attenuation_mixer_channel
	/// The ID of the timer used to update live attenuation.
	var/live_attenuation_timer_id
	/// The exact mid_sound currently playing.
	var/live_current_sound
	/// The base source volume of the currently playing mid_sound segment.
	var/live_current_base_volume
	/// Mobs that are currently receiving this live attenuated loop.
	var/list/live_listeners = list()

/datum/looping_sound/New(
	_parent,
	start_immediately = FALSE,
	_direct = FALSE,
	_skip_starting_sounds = FALSE,
	sound_channel,
)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	set_parent(_parent)
	direct = _direct
	skip_starting_sounds = _skip_starting_sounds
	if(sound_channel)
		src.sound_channel = sound_channel

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop(TRUE)
	return ..()

/**
 * The proc to actually kickstart the whole sound sequence. This is what you should call to start the `looping_sound`.
 *
 * Arguments:
 * * on_behalf_of - The new object to set as a parent.
 */
/datum/looping_sound/proc/start(on_behalf_of)
	if(on_behalf_of)
		set_parent(on_behalf_of)
	if(timer_id)
		return
	on_start()

/**
 * The proc to call to stop the sound loop.
 *
 * Arguments:
 * * null_parent - Whether or not we should set the parent to null (useful when destroying the `looping_sound` itself). Defaults to FALSE.
 */
/datum/looping_sound/proc/stop(null_parent = FALSE)
	stop_live_attenuation()
	stop_current()
	if(null_parent)
		set_parent(null)
	if(!timer_id)
		return
	on_stop()
	deltimer(timer_id, SSsound_loops)
	timer_id = null
	loop_started = FALSE

/// The proc that handles starting the actual core sound loop.
/datum/looping_sound/proc/start_sound_loop()
	loop_started = TRUE
	sound_loop()
	timer_id = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME, SSsound_loops)

	if(live_attenuation && !direct)
		start_live_attenuation()

/**
 * A simple proc handling the looping of the sound itself.
 *
 * Arguments:
 * * start_time - The time at which the `mid_sounds` started being played (so we know when to stop looping).
 */
/datum/looping_sound/proc/sound_loop(start_time)
	if(max_loops && world.time >= start_time + mid_length * max_loops)
		stop()
		return

	// If we have a timer, we're varying mid length, and this is happening while we're runnin mid_sounds
	if(timer_id && mid_length_vary && start_time)
		updatetimedelay(timer_id, mid_length + rand(-mid_length_vary, mid_length_vary), timer_subsystem = SSsound_loops)

	if(!chance || prob(chance))
		var/soundfile = get_sound()
		if(live_attenuation && !direct)
			play_live_attenuated(soundfile)
		else
			play(soundfile)
	else if(live_attenuation)
		stop_live_channels()
		live_current_sound = null
		live_current_base_volume = null

/**
 * Applies a new mid length to the sound
 */
/datum/looping_sound/proc/set_mid_length(new_mid)
	mid_length = new_mid
	if(!timer_id)
		return
	updatetimedelay(timer_id, mid_length + rand(-mid_length_vary, mid_length_vary), timer_subsystem = SSsound_loops)

/**
 * The proc that handles actually playing the sound.
 *
 * Arguments:
 * * soundfile - The soundfile we want to play.
 * * volume_override - The volume we want to play the sound at, overriding the `volume` variable.
 */
/datum/looping_sound/proc/play(soundfile, volume_override)
	var/sound/sound_to_play = sound(soundfile)

	if(direct)
		var/mob/mob_parent = parent
		if(!mob_parent?.client)
			return
		sound_to_play.channel = sound_channel || guess_mixer_channel(soundfile) || SSsounds.random_available_channel()
		sound_to_play.volume = volume_override || calculate_mixed_volume(mob_parent.client, sound_to_play.volume, sound_to_play.channel)
		SEND_SOUND(mob_parent, sound_to_play)
	else
		playsound(
			parent,
			sound_to_play,
			volume_override || volume,
			vary,
			extra_range,
			falloff_exponent = falloff_exponent,
			channel = sound_channel || sound_to_play.channel,
			pressure_affected = pressure_affected,
			ignore_walls = ignore_walls,
			falloff_distance = falloff_distance,
			use_reverb = use_reverb,
			mixer_channel = sound_to_play.channel,
		)

/// Returns the absolute max distance used by live attenuation.
/datum/looping_sound/proc/get_live_max_distance()
	return live_attenuation_max_distance || (SOUND_RANGE + extra_range)

/// Returns the mixer channel used for live attenuation client volume preferences.
/datum/looping_sound/proc/get_live_mixer_channel(soundfile)
	return live_attenuation_mixer_channel || guess_mixer_channel(soundfile) || sound_channel

/// Makes sure this datum can safely use live attenuation.
/datum/looping_sound/proc/validate_live_attenuation()
	if(!sound_channel)
		CRASH("[type] has live_attenuation enabled without a fixed sound_channel.")
	if(direct)
		CRASH("[type] has live_attenuation enabled while direct is TRUE. Direct live attenuation is unsupported.")

/// Returns nearby candidate listeners for this live attenuated loop.
/datum/looping_sound/proc/get_live_listener_candidates()
	var/list/candidates = list()

	if(!parent)
		return candidates

	var/max_distance = get_live_max_distance()
	if(!max_distance)
		return candidates

	if(ignore_walls)
		for(var/mob/listener in range(max_distance, parent))
			candidates += listener
	else
		for(var/mob/listener in get_hearers_in_view(max_distance, parent))
			candidates += listener

	return candidates

/// Calculates the unmixed volume a listener should hear right now.
/datum/looping_sound/proc/get_live_volume_for(mob/listener, base_volume)
	if(!listener?.client || HAS_TRAIT(listener, TRAIT_DEAF))
		return 0

	var/turf/source_turf = get_turf(parent)
	var/turf/listener_turf = get_turf(listener)

	if(!source_turf || !listener_turf || source_turf.z != listener_turf.z)
		return 0

	var/max_distance = get_live_max_distance()
	if(!max_distance)
		return 0

	var/resolved_falloff_distance = falloff_distance || SOUND_DEFAULT_FALLOFF_DISTANCE
	if(resolved_falloff_distance >= max_distance)
		CRASH("[type] has falloff_distance >= live_attenuation_max_distance.")

	var/distance = get_dist(listener_turf, source_turf)
	if(distance > max_distance)
		return 0

	var/effective_volume = base_volume

	if(falloff_exponent)
		effective_volume -= CALCULATE_SOUND_VOLUME(base_volume, distance, max_distance, resolved_falloff_distance, falloff_exponent)

	if(pressure_affected)
		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = listener_turf.return_air()
		var/datum/gas_mixture/source_env = source_turf.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE) / (ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else
			pressure_factor = 0

		if(distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)

		effective_volume *= pressure_factor

	if(HAS_TRAIT_FROM(listener, TRAIT_HARD_OF_HEARING, EAR_DAMAGE))
		effective_volume *= 0.2

	if(effective_volume < SOUND_AUDIBLE_VOLUME_MIN)
		return 0

	return max(effective_volume, 0)

/// Applies positional sound offsets for one listener.
/datum/looping_sound/proc/apply_live_position_to_sound(sound/sound_to_update, mob/listener)
	var/turf/source_turf = get_turf(parent)
	var/turf/listener_turf = get_turf(listener)

	if(!source_turf || !listener_turf)
		return

	sound_to_update.x = source_turf.x - listener_turf.x
	sound_to_update.z = source_turf.y - listener_turf.y
	sound_to_update.y = (source_turf.z - listener_turf.z) * 5
	sound_to_update.falloff = get_live_max_distance()

/// Sends the current live loop sound to one listener.
/datum/looping_sound/proc/send_live_sound_to(mob/listener, soundfile, effective_volume, mixer_channel)
	if(!listener?.client || !soundfile || effective_volume <= 0)
		return

	var/sound/listener_sound = sound(soundfile)
	listener_sound.wait = FALSE
	listener_sound.channel = sound_channel
	listener_sound.volume = calculate_mixed_volume(listener.client, effective_volume, mixer_channel)

	apply_live_position_to_sound(listener_sound, listener)

	SEND_SOUND(listener, listener_sound)

/// Updates volume/position on the currently playing live loop channel for one listener.
/datum/looping_sound/proc/update_live_sound_for(mob/listener, effective_volume, mixer_channel)
	if(!listener?.client)
		return

	var/final_volume = 0
	if(effective_volume > 0)
		final_volume = calculate_mixed_volume(listener.client, effective_volume, mixer_channel)

	var/sound/update = sound(null)
	update.channel = sound_channel
	update.status = SOUND_UPDATE
	update.volume = final_volume

	apply_live_position_to_sound(update, listener)

	SEND_SOUND(listener, update)

/// Plays a mid_sound using live attenuation instead of one-time playsound() attenuation.
/datum/looping_sound/proc/play_live_attenuated(soundfile, volume_override)
	validate_live_attenuation()

	if(!parent || !soundfile)
		return

	var/base_volume = volume_override || volume
	if(base_volume < SOUND_AUDIBLE_VOLUME_MIN)
		return

	live_current_sound = soundfile
	live_current_base_volume = base_volume

	var/mixer_channel = get_live_mixer_channel(soundfile)
	var/list/current_listeners = list()

	for(var/mob/listener in get_live_listener_candidates())
		if(!listener?.client)
			continue

		var/effective_volume = get_live_volume_for(listener, base_volume)
		if(effective_volume <= 0)
			continue

		current_listeners[listener] = TRUE
		send_live_sound_to(listener, soundfile, effective_volume, mixer_channel)

	for(var/mob/old_listener in live_listeners)
		if(old_listener in current_listeners)
			continue

		if(old_listener?.client)
			old_listener.stop_sound_channel(sound_channel)

	live_listeners = current_listeners

/// Starts the live attenuation update timer.
/datum/looping_sound/proc/start_live_attenuation()
	validate_live_attenuation()

	if(live_attenuation_timer_id)
		return

	live_attenuation_timer_id = addtimer(CALLBACK(src, PROC_REF(update_live_attenuation)), live_attenuation_interval, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP, SSsound_loops)

/// Stops the live attenuation update timer.
/datum/looping_sound/proc/stop_live_attenuation()
	if(!live_attenuation_timer_id)
		return

	deltimer(live_attenuation_timer_id, SSsound_loops)
	live_attenuation_timer_id = null
	live_current_sound = null
	live_current_base_volume = null

/// Updates volume/position on the currently playing live loop channel.
/datum/looping_sound/proc/update_live_attenuation()
	if(!parent || !sound_channel || !live_current_sound)
		return

	var/base_volume = live_current_base_volume || volume
	var/mixer_channel = get_live_mixer_channel(live_current_sound)
	var/list/current_listeners = list()

	for(var/mob/listener in get_live_listener_candidates())
		if(!listener?.client)
			continue

		var/effective_volume = get_live_volume_for(listener, base_volume)
		if(effective_volume <= 0)
			continue

		current_listeners[listener] = TRUE

		if(listener in live_listeners)
			update_live_sound_for(listener, effective_volume, mixer_channel)
		else
			send_live_sound_to(listener, live_current_sound, effective_volume, mixer_channel)

	for(var/mob/old_listener in live_listeners)
		if(old_listener in current_listeners)
			continue

		if(old_listener?.client)
			old_listener.stop_sound_channel(sound_channel)

	live_listeners = current_listeners

/// Stops this live loop channel for all listeners currently receiving it.
/datum/looping_sound/proc/stop_live_channels()
	if(!sound_channel)
		return

	for(var/mob/listener in live_listeners)
		if(!listener?.client)
			continue

		listener.stop_sound_channel(sound_channel)

	live_listeners.Cut()

/// Returns the sound we should now be playing.
/datum/looping_sound/proc/get_sound(_mid_sounds)
	var/list/play_from = _mid_sounds || mid_sounds
	if(!each_once)
		. = play_from
		while(!isfile(.) && !isnull(.))
			. = pick_weight_recursive(.)
		return .

	if(in_order)
		. = play_from
		audio_index++
		if(audio_index > length(play_from))
			audio_index = 1
		return .[audio_index]

	if(!length(cut_list))
		cut_list = shuffle(play_from.Copy())
	var/list/tree = list()
	. = cut_list
	while(!isfile(.) && !isnull(.))
		// Tree is a list of lists containign files
		// If an entry in the tree goes to 0 length, we cut it from the list
		tree += list(.)
		. = pick_weight_recursive(.)

	if(!isfile(.))
		return

	// Remove the sound file
	tree[length(tree)] -= .

	// Walk the tree bottom up, remove any lists that are empty
	// Don't do anything for the topmost list, cause we do not care
	for(var/i in length(tree) to 2 step -1)
		var/list/branch = tree[i]
		if(length(branch))
			break
		tree[i - 1] -= list(branch) // Remove the empty list
	return .

/// Returns the start sound.
/datum/looping_sound/proc/get_start_sound()
	return islist(start_sound) ? pick_weight_recursive(start_sound) : start_sound

/// Returns the end sound.
/datum/looping_sound/proc/get_end_sound()
	return islist(end_sound) ? pick_weight_recursive(end_sound) : end_sound

/// A proc that's there to handle delaying the main sounds if there's a start_sound, and simply starting the sound loop in general.
/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	var/start_sound = get_start_sound()
	if(start_sound && !skip_starting_sounds)
		play(start_sound, start_volume)
		start_wait = start_length
	timer_id = addtimer(CALLBACK(src, PROC_REF(start_sound_loop)), start_wait, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE, SSsound_loops)

/// Stops sound playing on current channel, if specified
/datum/looping_sound/proc/stop_current()
	if(live_attenuation)
		stop_live_channels()
		return

	if(!sound_channel || !ismob(parent))
		return
	var/mob/mob_parent = parent
	mob_parent.stop_sound_channel(sound_channel)

/// Simple proc that's executed when the looping sound is stopped, so that the `end_sound` can be played, if there's one.
/datum/looping_sound/proc/on_stop()
	if(loop_started) //monkestation edit - Allow null end_sound to stop sound
		play(get_end_sound(), end_volume)

/// A simple proc to change who our parent is set to, also handling registering and unregistering the QDELETING signals on the parent.
/datum/looping_sound/proc/set_parent(new_parent)
	if(parent)
		UnregisterSignal(parent, COMSIG_QDELETING)
	parent = new_parent
	if(parent)
		RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(handle_parent_del))

/// A simple proc that lets us know whether the sounds are currently active or not.
/datum/looping_sound/proc/is_active()
	return !!timer_id

/// A simple proc to handle the deletion of the parent, so that it does not force it to hard-delete.
/datum/looping_sound/proc/handle_parent_del(datum/source)
	SIGNAL_HANDLER
	set_parent(null)
