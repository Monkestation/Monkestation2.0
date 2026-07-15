/// Used in [/datum/cameranet/proc/major_chunk_change] - indicates the camera should be removed from the chunk list.
#define REMOVE_CAMERA 0
/// Used in [/datum/cameranet/proc/major_chunk_change] - indicates the camera should be added to the chunk list.
#define ADD_CAMERA 1
/// Used in [/datum/cameranet/proc/major_chunk_change] - indicates the chunk should be updated without adding/removing a camera.
#define IGNORE_CAMERA 2

/datum/cameranet
	/// This network's id.
	var/id
	/// Name to show for VV and stat()
	var/name = "Camera Net"
	/// The cameras on this net, no matter if they work or not.
	/// Updated in obj/machinery/camera.dm in Initialize() and Destroy().
	var/list/obj/machinery/camera/cameras = list()
	/// The chunks of the map on this net, mapping the areas that the cameras can see.
	var/list/chunks = list()
	/// Chunks on this net that must be updated.
	var/list/chunks_to_update = list()

/datum/cameranet/New(net_id)
	id = net_id
	name = "Camera Net ([net_id])"

/// Checks if a chunk has been generated in x, y, z.
/datum/cameranet/proc/get_camera_chunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	if(GET_LOWEST_STACK_OFFSET(z) != 0)
		var/turf/lowest = get_lowest_turf(locate(x, y, z))
		return chunks["[x],[y],[lowest.z]"]

	return chunks["[x],[y],[z]"]

/// Returns the chunk in the x, y, z. If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/generate_chunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	var/turf/lowest = get_lowest_turf(locate(x, y, z))
	var/key = "[x],[y],[lowest.z]"
	. = chunks[key]
	if(!.)
		. = new /datum/camerachunk(x, y, lowest.z, src)
		chunks[key] = .

/// Updates what the camera eye can see.
/// It is recommended you use this when a camera eye moves or its location is set.
/datum/cameranet/proc/update_eye_chunk(mob/eye/camera/eye)
	var/list/visibleChunks = list()
	//Get the eye's turf in case its located in an object like a mecha
	var/turf/eye_turf = get_turf(eye)
	if(eye.loc)
		var/static_range = eye.static_visibility_range
		var/x1 = max(1, eye_turf.x - static_range)
		var/y1 = max(1, eye_turf.y - static_range)
		var/x2 = min(world.maxx, eye_turf.x + static_range)
		var/y2 = min(world.maxy, eye_turf.y + static_range)

		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				visibleChunks |= generate_chunk(x, y, eye_turf.z)

	var/list/remove = eye.visibleCameraChunks - visibleChunks
	var/list/add = visibleChunks - eye.visibleCameraChunks

	for(var/datum/camerachunk/chunk as anything in remove)
		chunk.remove(eye)

	for(var/datum/camerachunk/chunk as anything in add)
		chunk.add(eye)

/// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or when doors open.
/datum/cameranet/proc/update_visibility(atom/relevant_atom)
	if(!SSticker)
		return
	major_chunk_change(relevant_atom, IGNORE_CAMERA)

/// Removes a camera from a chunk.
/datum/cameranet/proc/remove_camera_from_chunk(obj/machinery/camera/old_cam)
	major_chunk_change(old_cam, REMOVE_CAMERA)

/// Add a camera to a chunk.
/datum/cameranet/proc/add_camera_to_chunk(obj/machinery/camera/new_cam)
	if(new_cam.can_use())
		major_chunk_change(new_cam, ADD_CAMERA)

/**
 * Used to update cameras that are moving, since most everything in the game can.
 * update_delay_buffer is passed to allow variable update delays. useful so one
 * camera'd guy moving doesn't absolutely spam updates to watching ais (laggin the server)
*/
/datum/cameranet/proc/camera_moved(obj/machinery/camera/updating_camera, turf/old_turf, turf/new_turf, update_delay_buffer)
	if(old_turf == new_turf)
		return

	var/list/old_chunks = list()
	var/range_difference = MAX_CAMERA_RANGE + 1
	if(!isnull(old_turf))
		var/x1 = max(1, old_turf.x - range_difference)
		var/y1 = max(1, old_turf.y - range_difference)
		var/x2 = min(world.maxx, old_turf.x + range_difference)
		var/y2 = min(world.maxy, old_turf.y + range_difference)
		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				var/datum/camerachunk/chunk = get_camera_chunk(x, y, old_turf.z)
				if(isnull(chunk))
					continue
				old_chunks += chunk
				// if we've moved, what we can see will have changed so queue er up
				chunk.queue_update(updating_camera, update_delay_buffer)

	var/list/new_chunks = list()
	if(!isnull(new_turf) && updating_camera.can_use())
		if(QDELETED(updating_camera))
			stack_trace("Tried to add a qdeleting camera to the net")
		else
			var/x1 = max(1, new_turf.x - range_difference)
			var/y1 = max(1, new_turf.y - range_difference)
			var/x2 = min(world.maxx, new_turf.x + range_difference)
			var/y2 = min(world.maxy, new_turf.y + range_difference)
			for(var/x = x1; x <= x2; x += CHUNK_SIZE)
				for(var/y = y1; y <= y2; y += CHUNK_SIZE)
					var/datum/camerachunk/chunk = get_camera_chunk(x, y, new_turf.z)
					if(isnull(chunk))
						continue
					new_chunks += chunk
					// if we've moved, what we can see will have changed so queue er up
					chunk.queue_update(updating_camera, update_delay_buffer)

	// First, cut us from chunks who we can't see anymore
	for(var/datum/camerachunk/lost as anything in old_chunks - new_chunks)
		lost.cameras["[old_turf.z]"] -= updating_camera

	// Then we add to turfs who we can newly see!
	for(var/datum/camerachunk/found as anything in new_chunks - old_chunks)
		found.cameras["[new_turf.z]"] |= updating_camera

/**
 * Never access this proc directly!!!!
 * This will update the chunk and all the surrounding chunks.
 * It will also add the atom to the cameras list if you set the choice to ADD_CAMERA.
 * Setting the choice to REMOVE_CAMERA will remove the camera from the chunks.
 * If you want to update the chunks around an object, without adding/removing a camera, use IGNORE_CAMERA.
 * update_delay_buffer is passed all the way to queue_update() from portable camera updates on movement
 * to change the time between static updates.
 */
/datum/cameranet/proc/major_chunk_change(atom/center_or_camera, choice = IGNORE_CAMERA, update_delay_buffer = 0)
	PROTECTED_PROC(TRUE)

	if(QDELETED(center_or_camera) && choice == ADD_CAMERA)
		CRASH("Tried to add a qdeleting camera to the net")

	var/turf/chunk_turf = get_turf(center_or_camera)
	if(isnull(chunk_turf))
		return

	var/range_difference = MAX_CAMERA_RANGE + 1
	var/x1 = max(1, chunk_turf.x - range_difference)
	var/y1 = max(1, chunk_turf.y - range_difference)
	var/x2 = min(world.maxx, chunk_turf.x + range_difference)
	var/y2 = min(world.maxy, chunk_turf.y + range_difference)
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = get_camera_chunk(x, y, chunk_turf.z)
			if(isnull(chunk))
				continue
			if(choice == REMOVE_CAMERA)
				// Remove the camera.
				chunk.cameras["[chunk_turf.z]"] -= center_or_camera
			if(choice == ADD_CAMERA)
				// You can't have the same camera in the list twice.
				chunk.cameras["[chunk_turf.z]"] |= center_or_camera
			chunk.queue_update(center_or_camera, update_delay_buffer)

/// A faster, turf only version of [/datum/cameranet/proc/major_chunk_change]
/// For use in sensitive code, be careful with it
/datum/cameranet/proc/bare_major_chunk_change(turf/changed)
	var/range_difference = MAX_CAMERA_RANGE + 1
	var/x1 = max(1, changed.x - range_difference)
	var/y1 = max(1, changed.y - range_difference)
	var/x2 = min(world.maxx, changed.x + range_difference)
	var/y2 = min(world.maxy, changed.y + range_difference)
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = get_camera_chunk(x, y, changed.z)
			chunk?.queue_update(changed, 0)

/// Will check if an atom is on a viewable turf.
/// Returns TRUE if the atom is visible by any camera, FALSE otherwise.
/datum/cameranet/proc/is_visible_by_cameras(atom/target)
	return turf_visible_by_cameras(get_turf(target))

/// Checks if the passed turf is visible by any camera.
/// Returns TRUE if the turf is visible by any camera, FALSE otherwise.
/datum/cameranet/proc/turf_visible_by_cameras(turf/position)
	if(isnull(position))
		return FALSE
	var/datum/camerachunk/chunk = generate_chunk(position.x, position.y, position.z)
	if(isnull(chunk))
		return FALSE
	chunk.force_update(only_if_necessary = TRUE) // Update NOW if necessary
	if(chunk.visibleTurfs[position])
		return TRUE
	return FALSE

/// Gets the camera chunk the passed turf is in.
/// Returns the chunk if it exists and is visible, null otherwise.
/datum/cameranet/proc/get_turf_camera_chunk(turf/position)
	RETURN_TYPE(/datum/camerachunk)
	var/datum/camerachunk/chunk = generate_chunk(position.x, position.y, position.z)
	if(!chunk)
		return null
	chunk.force_update(only_if_necessary = TRUE) // Update NOW if necessary
	if(chunk.visibleTurfs[position])
		return chunk
	return null

/// Returns list of available cameras, ready to use for UIs displaying list of them
/// The format is: list("name" = "camera.c_tag", ref = REF(camera))
/datum/cameranet/proc/get_available_cameras_data(list/networks_available, list/z_levels_available)
	var/list/available_cameras_data = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_data += list(list(
			name = camera.c_tag,
			ref = REF(camera),
		))

	return available_cameras_data

/**
 * get_available_camera_by_tag_list
 *
 * Builds a list of all available cameras that can be seen to networks_available and in z_levels_available.
 * Entries are stored in `c_tag[camera.can_use() ? null : " (Deactivated)"]` => `camera` format
 * Args:
 *  networks_available - List of networks that we use to see which cameras are visible to it.
 *  z_levels_available - List of z levels to filter camera by. If empty, all z levels are considered valid.
 */
/datum/cameranet/proc/get_available_camera_by_tag_list(list/networks_available, list/z_levels_available)
	var/list/available_cameras_by_tag = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_by_tag["[camera.c_tag][camera.can_use() ? null : " (Deactivated)"]"] = camera

	return available_cameras_by_tag

/// Returns list of all cameras that passed `is_camera_available` filter and sorted by `cmp_camera_ctag_asc`
/datum/cameranet/proc/get_filtered_and_sorted_cameras(list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	var/list/filtered_cameras = list()
	for(var/obj/machinery/camera/camera as anything in cameras)
		if(!is_camera_available(camera, networks_available, z_levels_available))
			continue

		filtered_cameras += camera

	return sortTim(filtered_cameras, GLOBAL_PROC_REF(cmp_camera_ctag_asc))

/// Checks if the `camera_to_check` meets the requirements of availability.
/datum/cameranet/proc/is_camera_available(obj/machinery/camera/camera_to_check, list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	if(!camera_to_check.c_tag)
		return FALSE

	if(length(z_levels_available) && !(camera_to_check.z in z_levels_available))
		return FALSE

	return length(camera_to_check.network & networks_available) > 0

#undef ADD_CAMERA
#undef REMOVE_CAMERA
#undef IGNORE_CAMERA
