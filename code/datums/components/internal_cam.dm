///The static update delay on movement of the camera in a mob we use
#define INTERNAL_CAMERA_BUFFER (0.5 SECONDS)

/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
	///The camera object used to gather information for the camera net
	var/obj/machinery/camera/bodcam

/datum/component/internal_cam/Initialize(list/networks = list("ss13"))
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	bodcam = new(parent)
	bodcam.c_tag = parent
	bodcam.name = parent
	var/list/lowercase_networks = list()
	for(var/network_name in networks)
		lowercase_networks += lowertext(network_name)
	bodcam.network = lowercase_networks
	bodcam.setViewRange(MAX_CAMERA_RANGE) //standard camera viewrange
	bodcam.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/datum/component/internal_cam/Destroy(force, silent)
	. = ..()
	QDEL_NULL(bodcam) // has to be AFTER UnregisterFromParent runs

/datum/component/internal_cam/RegisterWithParent()
	bodcam.camera_enabled = TRUE
	SScameras.add_camera_to_chunk(bodcam)
	bodcam.built_in = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.camera_enabled = FALSE
	SScameras.remove_camera_from_chunk(bodcam)
	bodcam.built_in = null
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

///Changes the camera net used by the interal camera, currently only used for the darkspawn cameranet
/datum/component/internal_cam/proc/change_cameranet(datum/cameranet/newnet)
	bodcam.change_camnet(newnet)

///Updates the camera net, telling it that the camera has moved
/datum/component/internal_cam/proc/update_cam(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	SScameras.camera_moved(bodcam, get_turf(old_loc), get_turf(parent), INTERNAL_CAMERA_BUFFER)

