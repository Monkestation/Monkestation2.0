/datum/media_source
	/// A list of mobs currently listening to this media source.
	var/list/mob/listeners
	/// The current track being played by this source.
	var/datum/media_track/current_track
	/// The base volume of the media.
	var/volume = 100
	/// The time this media source started playing.
	var/start_time
	/// The mixer channel to use to multiply the volume by.
	var/mixer_channel

/datum/media_source/New(datum/media_track/track, volume, mixer_channel)
	src.current_track = track
	if(!isnull(volume))
		src.volume = volume
	if(!isnull(mixer_channel))
		src.mixer_channel = "[mixer_channel]"
	else if(!isnull(src.mixer_channel))
		src.mixer_channel = "[src.mixer_channel]"

/datum/media_source/Destroy(force)
	for(var/mob/listener as anything in listeners)
		remove_listener(listener)
	current_track = null
	return ..()

/datum/media_source/proc/add_listener(mob/target)
	if(!ismob(target))
		CRASH("Attempted to add non-mob as a listener to a [type]")
	if(QDELING(target) || QDELETED(src))
		return
	if(target in listeners)
		update_for_listener(target)
		return
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_listener))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(update_for_listener_signal))
	LAZYADD(listeners, target)
	target.add_media_source(src)

/datum/media_source/proc/remove_listener(mob/target)
	SIGNAL_HANDLER
	if(isnull(target) || !(target in listeners))
		return
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	LAZYREMOVE(listeners, target)
	LAZYREMOVE(target.available_media_sources, src)
	target.remove_media_source(src)

/datum/media_source/proc/get_position(mob/target, x_ptr, y_ptr, z_ptr)
	*x_ptr = 0
	*y_ptr = 0
	*z_ptr = 0
	return TRUE

/datum/media_source/proc/get_volume(mob/target)
	. = volume
	if(isnull(mixer_channel))
		return volume
	var/client/client = CLIENT_FROM_VAR(target)
	var/list/channel_volume = client?.prefs?.channel_volume
	if("[CHANNEL_MASTER_VOLUME]" in channel_volume)
		. *= (channel_volume["[CHANNEL_MASTER_VOLUME]"] / 100)
	if(mixer_channel in channel_volume)
		. *= (channel_volume[mixer_channel] / 100)

/datum/media_source/proc/get_balance(mob/target)
	return 0

/// Wrapper for update_for_listener to be used with signals, to avoid passing extra args in.
/datum/media_source/proc/update_for_listener_signal(mob/target)
	SIGNAL_HANDLER
	update_for_listener(target)

/datum/media_source/proc/update_for_listener(mob/target, force_update_time = FALSE)
	if(!QDELETED(src) && !QDELETED(target))
		target.update_media_source(force_update_time)

/datum/media_source/proc/play_for_listener(mob/target, datum/media_player/media_player, update_time = FALSE)
	if(QDELETED(src) || QDELETED(media_player) || !current_track?.url)
		return
	var/x = 0
	var/y = 0
	var/z = 0
	// get_position returns FALSE if they shouldn't be hearing it anyways
	if(!get_position(target, &x, &y, &z))
		CRASH("Tried to play media for mob that should not be able to hear it!")
	var/volume = get_volume(target)
	var/balance = get_balance(target)
	if(media_player.current_url == current_track.url)
		media_player.set_volume(volume)
		media_player.set_position(x, y, z)
		media_player.set_panning(balance)
	else
		media_player.play(current_track.url, volume, x, y, z, balance)
	if(update_time)
		var/time = get_current_time()
		if(time > 0)
			media_player.set_time(time)

/datum/media_source/proc/update_for_all_listeners(force_update_time = FALSE)
	for(var/mob/listener as anything in listeners)
		update_for_listener(listener, force_update_time)

/datum/media_source/proc/get_current_time()
	if(!start_time)
		return 0
	if(isnull(current_track) || !current_track.url || !current_track.duration)
		start_time = 0
		return 0
	var/current_time = max(REALTIMEOFDAY - start_time, 0)
	if(current_time > current_track.duration)
		return 0
	return current_time / 10

/datum/media_source/proc/get_priority(mob/target)
	return -1

/datum/media_source/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name in list(NAMEOF(src, current_track), NAMEOF(src, volume), NAMEOF(src, start_time), NAMEOF(src, mixer_channel)))
		update_for_all_listeners()
