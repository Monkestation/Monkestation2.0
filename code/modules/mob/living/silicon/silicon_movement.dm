//We only call a camera static update if we have successfully moved and the camera is present and working
/mob/living/silicon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!builtInCamera?.can_use())
		return
	// Delay's a bit faster then standard cameras to "avoid running out of the camera's fov" whatever that means
	SScameras.camera_moved(builtInCamera, get_turf(old_loc), get_turf(builtInCamera), 0.5 SECONDS)

/obj/machinery/ai/data_core/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	for(var/mob/living/silicon/ai/internal_ai in contents)
		if(!internal_ai.builtInCamera?.can_use())
			continue
		SScameras.camera_moved(internal_ai.builtInCamera, get_turf(old_loc), get_turf(internal_ai.builtInCamera), 0.5 SECONDS)
