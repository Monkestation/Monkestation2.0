/// A media source tied to a specific object.
/datum/media_source/object
	/// The atom this source is tied to.
	var/atom/movable/source
	/// The current turf of our source.
	var/turf/source_turf
	/// The maximum distance this media source can be heard from.
	var/max_distance = 10
	/// Keeps track of who enters/exits the media source's range.
	var/datum/cell_tracker/tracker

/datum/media_source/object/New(datum/media_track/track, volume = 100, atom/movable/source, max_distance = 10)
	. = ..()
	if(!ismovable(source))
		CRASH("Attempted to add [type] to a non-movable source")
	if(QDELING(source))
		QDEL_IN(src, 0)
		CRASH("Attempted to add [type] to a qdeling source")
	src.source = source
	src.source_turf = get_turf(source)
	src.max_distance = max_distance
	src.tracker = new(max_distance, max_distance, 1)
	update_cells()
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_qdeleting))
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(on_source_moved))

/datum/media_source/object/Destroy(force)
	QDEL_NULL(tracker)
	if(!isnull(source))
		UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	source = null
	source_turf = null
	return ..()

/datum/media_source/object/get_position(mob/target, x_ptr, y_ptr)
	var/turf/listener_turf = get_turf(target)
	if(isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || get_dist(source_turf, listener_turf) > max_distance)
		return FALSE
	*x_ptr = listener_turf.x - source_turf.x
	*y_ptr = listener_turf.y - source_turf.y
	return TRUE

/datum/media_source/object/get_priority(mob/target)
	var/turf/listener_turf = get_turf(target)
	if(QDELETED(src) || isnull(source_turf) || isnull(listener_turf) || source_turf.z != listener_turf.z || volume <= 0 || !current_track?.url)
		return -1
	var/distance_mul = 1 - (get_dist(source_turf, listener_turf) / (max_distance + 1))
	var/volume_mul = volume / 100
	return distance_mul * volume_mul

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

/datum/media_source/object/proc/update_cells()
	if(QDELETED(src) || QDELETED(tracker))
		return
	var/turf/our_turf = get_turf(src)
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

/datum/media_source/object/proc/on_client_enter(datum/source, list/target_list)
	SIGNAL_HANDLER
	for(var/mob/mob as anything in target_list)
		if(ismob(mob) && !QDELING(mob) && !(mob in listeners))
			add_listener(mob)

/datum/media_source/object/proc/on_client_exit(datum/source, list/target_list)
	SIGNAL_HANDLER
	for(var/mob/mob as anything in target_list)
		if(ismob(mob) && (mob in listeners))
			remove_listener(mob)
