/// Manages the security cameras and camera chunks
SUBSYSTEM_DEF(cameras)
	name = "Cameras"
	flags = SS_BACKGROUND
	priority = FIRE_PRIORITY_CAMERAS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 MINUTES

	/// The default camera network.
	var/datum/cameranet/default_net
	/// All camera networks, keyed by id.
	var/list/datum/cameranet/nets = list()
	/// The cameras on the map, no matter if they work or not.
	/// Updated in obj/machinery/camera.dm in Initialize() and Destroy().
	var/list/obj/machinery/camera/cameras = list()
	/// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	/// List of images cloned by all chunk static images put onto turfs cameras cant see
	/// Indexed by the plane offset to use
	var/list/image/obscured_images = list()
	/// Primarily for debugging, outright prevents all camera chunk updates
	var/disable_camera_updates = FALSE
	/// Tracks current subsystem run
	var/list/current_run = list()

/datum/controller/subsystem/cameras/PreInit()
	. = ..()
	default_net = new(CAMERANET_ID_DEFAULT)
	default_net.cameras = cameras
	default_net.chunks = chunks
	nets[CAMERANET_ID_DEFAULT] = default_net

/datum/controller/subsystem/cameras/Initialize()
	update_offsets(SSmapping.max_plane_offset)
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_growth))
	GLOB.thrallnet = get_or_create_net(ROLE_DARKSPAWN)
	GLOB.thrallnet.name = "Thrall Net"
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cameras/fire(resumed = FALSE)
	if(!resumed)
		src.current_run = list()
		for(var/net_id in nets)
			var/datum/cameranet/net = nets[net_id]
			src.current_run += net.chunks_to_update
			net.chunks_to_update = list()

	var/list/current_run = src.current_run
	while(current_run.len)
		var/datum/camerachunk/chunk = current_run[current_run.len]
		if(chunk.yield_update())
			current_run.len--
		if(MC_TICK_CHECK)
			break

/datum/controller/subsystem/cameras/stat_entry(msg)
	var/total_cameras = 0
	var/total_chunks = 0
	var/total_updating = 0
	for(var/net_id in nets)
		var/datum/cameranet/net = nets[net_id]
		total_cameras += length(net.cameras)
		total_chunks += length(net.chunks)
		total_updating += length(net.chunks_to_update)
	msg = "Nets: [length(nets)] | Cams: [total_cameras] | Chunks: [total_chunks] | Updating: [total_updating]"
	return ..()

/// Updates the images for new plane offsets
/datum/controller/subsystem/cameras/proc/update_offsets(new_offset)
	for(var/i in length(obscured_images) to new_offset)
		var/image/obscured = new('icons/effects/cameravis.dmi')
		SET_PLANE_W_SCALAR(obscured, CAMERA_STATIC_PLANE, i)
		obscured.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
		obscured.override = TRUE
		obscured_images += obscured

/datum/controller/subsystem/cameras/proc/on_offset_growth(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	update_offsets(new_offset)

/datum/controller/subsystem/cameras/proc/get_or_create_net(net_id)
	RETURN_TYPE(/datum/cameranet)
	. = nets[net_id]
	if(!.)
		. = new /datum/cameranet(net_id)
		nets[net_id] = .

/datum/controller/subsystem/cameras/proc/get_net(net_id)
	RETURN_TYPE(/datum/cameranet)
	return nets[net_id]

/datum/controller/subsystem/cameras/proc/update_eye_chunk(mob/eye/camera/eye)
	var/datum/cameranet/net = eye.camnet || default_net
	return net.update_eye_chunk(eye)

/datum/controller/subsystem/cameras/proc/get_camera_chunk(x, y, z)
	return default_net.get_camera_chunk(x, y, z)

/datum/controller/subsystem/cameras/proc/generate_chunk(x, y, z)
	return default_net.generate_chunk(x, y, z)

/datum/controller/subsystem/cameras/proc/update_visibility(atom/relevant_atom)
	if(!SSticker)
		return
	for(var/net_id in nets)
		var/datum/cameranet/net = nets[net_id]
		net.update_visibility(relevant_atom)

/datum/controller/subsystem/cameras/proc/remove_camera_from_chunk(obj/machinery/camera/old_cam)
	var/datum/cameranet/net = old_cam.camnet || default_net
	return net.remove_camera_from_chunk(old_cam)

/datum/controller/subsystem/cameras/proc/add_camera_to_chunk(obj/machinery/camera/new_cam)
	var/datum/cameranet/net = new_cam.camnet || default_net
	return net.add_camera_to_chunk(new_cam)

/datum/controller/subsystem/cameras/proc/camera_moved(obj/machinery/camera/updating_camera, turf/old_turf, turf/new_turf, update_delay_buffer)
	var/datum/cameranet/net = updating_camera.camnet || default_net
	return net.camera_moved(updating_camera, old_turf, new_turf, update_delay_buffer)

/datum/controller/subsystem/cameras/proc/bare_major_chunk_change(turf/changed)
	for(var/net_id in nets)
		var/datum/cameranet/net = nets[net_id]
		net.bare_major_chunk_change(changed)

/datum/controller/subsystem/cameras/proc/is_visible_by_cameras(atom/target)
	return default_net.is_visible_by_cameras(target)

/datum/controller/subsystem/cameras/proc/turf_visible_by_cameras(turf/position)
	return default_net.turf_visible_by_cameras(position)

/datum/controller/subsystem/cameras/proc/get_turf_camera_chunk(turf/position)
	return default_net.get_turf_camera_chunk(position)

/datum/controller/subsystem/cameras/proc/get_available_cameras_data(list/networks_available, list/z_levels_available)
	return default_net.get_available_cameras_data(networks_available, z_levels_available)

/datum/controller/subsystem/cameras/proc/get_available_camera_by_tag_list(list/networks_available, list/z_levels_available)
	return default_net.get_available_camera_by_tag_list(networks_available, z_levels_available)

/obj/effect/overlay/camera_static
	name = "static"
	icon = null
	icon_state = null
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	appearance_flags = RESET_TRANSFORM | TILE_BOUND | LONG_GLIDE
	// this combination makes the static block clicks to everything below it,
	// without appearing in the right-click menu for non-AI clients
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_ABSTRACT

	plane = CAMERA_STATIC_PLANE

ADMIN_VERB(pause_camera_updates, R_ADMIN, FALSE, "Toggle Camera Updates", "Stop security cameras from updating, meaning what they see now is what they will see forever.", ADMIN_CATEGORY_DEBUG)
	SScameras.disable_camera_updates = !SScameras.disable_camera_updates
