/// A media source tied to a specific object.
/datum/media_source/object
	/// The atom this source is tied to.
	var/atom/movable/source
	/// The current turf of our source.
	var/turf/source_turf
	/// The maximum distance this media source can be heard from.
	var/max_distance = 10
	/// Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
	var/falloff_exponent = 2
	/// Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
	var/falloff_distance = 3
	/// Keeps track of who enters/exits the media source's range.
	var/datum/cell_tracker/tracker

/datum/media_source/object/New(datum/media_track/track, volume, mixer_channel, atom/movable/source, max_distance = 10, falloff_exponent = SOUND_FALLOFF_EXPONENT, falloff_distance = 3)
	. = ..()
	if(!ismovable(source))
		CRASH("Attempted to add [type] to a non-movable source")
	if(QDELING(source))
		QDEL_IN(src, 0)
		CRASH("Attempted to add [type] to a qdeling source")
	src.source = source
	src.source_turf = get_turf(source)
	src.max_distance = max_distance
	src.falloff_exponent = falloff_exponent
	src.tracker = new(max_distance, max_distance, 1)
	src.falloff_distance = min(falloff_distance, max_distance - 1)
	update_cells(init = TRUE)
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_qdeleting))
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(on_source_moved))

/datum/media_source/object/Destroy(force)
	for(var/datum/cell as anything in tracker?.member_cells)
		if(!isnull(cell))
			UnregisterSignal(cell, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))
	tracker = null
	if(!isnull(source))
		UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	source = null
	source_turf = null
	return ..()

/*
/datum/media_source/object/get_position(mob/target, x_ptr, y_ptr, z_ptr)
	var/turf/listener_turf = get_turf(target)
	if(isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || get_dist(source_turf, listener_turf) > max_distance)
		return FALSE
	*x_ptr = listener_turf.x - source_turf.x
	*y_ptr = listener_turf.y - source_turf.y
	*z_ptr = 0
	return TRUE
*/

/datum/media_source/object/get_volume(mob/target)
	. = ..()
	if(!max_distance)
		return
	var/turf/their_turf = get_turf(target)
	if(isnull(their_turf) || isnull(source_turf))
		return
	var/distance = get_dist(source_turf, their_turf)
	return ceil(. - CALCULATE_SOUND_VOLUME(., distance, max_distance, falloff_distance, falloff_exponent))

/datum/media_source/object/get_priority(mob/target)
	var/datum/preferences/prefs = target?.client?.prefs
	if(!QDELETED(prefs) && !prefs.read_preference(/datum/preference/toggle/sound_jukebox))
		return -1
	var/turf/listener_turf = get_turf(target)
	if(QDELETED(src) || isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || volume <= 0 || !current_track?.url)
		return -1
	var/distance_mul = 1 - (get_dist(source_turf, listener_turf) / (max_distance + 1))
	var/volume_mul = volume / 100
	return distance_mul * volume_mul

/datum/media_source/object/get_balance(mob/target)
	var/turf/their_turf = get_turf(target)
	if(isnull(their_turf) || isnull(source_turf) || their_turf == source_turf)
		return 0
	return clamp((source_turf.x - their_turf.x) / max_distance, -1, 1)

/datum/media_source/object/proc/on_source_qdeleting(atom/movable/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/datum/media_source/object/proc/on_source_moved(atom/movable/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	var/turf/new_turf = get_turf(source)
	if(source_turf != new_turf)
		source_turf = new_turf
		update_cells()
		update_for_all_listeners()

/datum/media_source/object/proc/update_cells(init = FALSE)
	if(QDELETED(src) || QDELETED(source) || QDELETED(tracker))
		return
	var/turf/our_turf = get_turf(source)
	if(isnull(our_turf))
		return

	var/list/cell_collections = tracker.recalculate_cells(our_turf)
	var/list/new_cells = cell_collections[1]
	var/list/old_cells = cell_collections[2]

	for(var/datum/old_grid as anything in old_cells)
		if(!isnull(old_grid))
			UnregisterSignal(old_grid, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))

	for(var/datum/spatial_grid_cell/new_grid as anything in new_cells)
		if(QDELETED(new_grid))
			continue
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_enter))
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_exit))
		if(init)
			for(var/mob/listener in new_grid.client_contents)
				add_listener(listener)

/datum/media_source/object/proc/on_client_enter(datum/source, list/target_list)
	SIGNAL_HANDLER
	for(var/mob/mob as anything in target_list)
		add_or_remove(mob)

/datum/media_source/object/proc/on_client_exit(datum/source, list/target_list)
	SIGNAL_HANDLER
	for(var/mob/mob as anything in target_list)
		add_or_remove(mob)

/datum/media_source/object/proc/add_or_remove(mob/target)
	if(!ismob(target) || QDELETED(src))
		return
	var/turf/their_turf = get_turf(target)
	if(isnull(their_turf) || isnull(source_turf))
		return
	var/dist = get_dist(source_turf, their_turf)
	if(dist > max_distance)
		remove_listener(target)
	else
		add_listener(target)

/datum/media_source/object/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name in list(NAMEOF(src, max_distance), NAMEOF(src, falloff_exponent), NAMEOF(src, falloff_distance)))
		update_for_all_listeners()
