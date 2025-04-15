/// A media source linked to a specific turf.
/datum/media_source
	/// A list of mobs currently listening to this media source.
	var/list/mob/listeners
	/// The atom this source is tied to.
	var/atom/movable/source
	/// The current turf of our source.
	var/turf/source_turf
	/// The current track being played by this source.
	var/datum/media_track/current_track
	/// The base volume of the media.
	var/volume = 100
	/// The maximum distance this media source can be heard from.
	var/max_distance = 10
	/// The time this media source started playing.
	var/start_time

/datum/media_source/New(atom/movable/source, volume = 100, max_distance = 10)
	if(!ismovable(source))
		CRASH("Attempted to add [type] to a non-movable source")
	if(QDELING(source))
		QDEL_IN(src, 0)
		CRASH("Attempted to add [type] to a qdeling source")
	src.source = source
	src.volume = volume
	src.max_distance = max_distance
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_qdeleting))
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(on_source_moved))

/datum/media_source/Destroy(force)
	for(var/mob/listener as anything in listeners)
		remove_listener(listener)
	if(!isnull(source))
		UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	source = null
	source_turf = null
	current_track = null
	return ..()

/datum/media_source/proc/on_source_qdeleting(atom/movable/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/datum/media_source/proc/on_source_moved(atom/movable/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		source_turf = get_turf(source)
		update_for_all_listeners()

/datum/media_source/proc/add_listener(mob/target)
	if(!ismob(target))
		CRASH("Attempted to add non-mob as a listener to a [type]")
	if(QDELING(target) || (target in listeners) || QDELETED(src))
		return
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_listener))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(update_for_listener))
	LAZYADD(listeners, target)

/datum/media_source/proc/remove_listener(mob/target)
	SIGNAL_HANDLER
	if(isnull(target) || !(target in listeners))
		return
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	LAZYREMOVE(listeners, target)

/datum/media_source/proc/update_for_listener(mob/target)
	SIGNAL_HANDLER
	var/datum/media_player/media_player = target?.client?.media_player
	if(!media_player || QDELETED(src))
		return
	if(!current_track?.url)
		media_player.stop()
		return
	var/turf/listener_turf = get_turf(target)
	if(isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || get_dist(source_turf, listener_turf) > max_distance)
		remove_listener(target)
		return
	var/x = listener_turf.x - source_turf.x
	var/y = listener_turf.y - source_turf.y
	// just update the volume and position if they're already listening to the same url
	if(media_player.current_url == current_track.url)
		media_player.set_volume(volume)
		media_player.set_position(x, y)
	else
		media_player.play(current_track.url, volume, x, y)

/datum/media_source/proc/update_for_all_listeners()
	for(var/mob/listener as anything in listeners)
		update_for_listener(listener)

/datum/media_source/proc/get_priority(mob/target)
	var/turf/listener_turf = get_turf(target)
	if(QDELETED(src) || isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || volume <= 0 || !current_track?.url)
		return -1
	var/distance_mul = 1 - (get_dist(source_turf, listener_turf) / (max_distance + 1))
	var/volume_mul = volume / 100
	return distance_mul * volume_mul
