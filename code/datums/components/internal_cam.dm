///The static update delay on movement of the camera in a mob we use
#define INTERNAL_CAMERA_BUFFER (0.5 SECONDS)

/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
	///The camera object used to gather information for the camera net
	var/obj/machinery/camera/bodcam

/datum/component/internal_cam/Initialize(list/networks = list(CAMERANET_NETWORK_SS13))
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	bodcam = new(parent)
	bodcam.c_tag = parent
	bodcam.name = parent
	bodcam.network = networks
	bodcam.setViewRange(10)//standard mob viewrange
	bodcam.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/datum/component/internal_cam/Destroy(force, silent)
	. = ..()
	QDEL_NULL(bodcam) // has to be AFTER UnregisterFromParent runs

/datum/component/internal_cam/RegisterWithParent()
	bodcam.camera_enabled = TRUE
	update_cam()
	bodcam.built_in = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.camera_enabled = FALSE
	update_cam()
	bodcam.built_in = null
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/internal_cam/proc/set_network(list/network)
	bodcam.network = islist(network) ? network.Copy() : (lowertext(network))

///Updates the camera net, telling it that the camera has moved
/datum/component/internal_cam/proc/update_cam()
	SIGNAL_HANDLER
	SScameras.update_portable_camera(bodcam, INTERNAL_CAMERA_BUFFER)
