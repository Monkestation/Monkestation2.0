/**
 * Bodycamera subtype of Camera
 * Meant to make sure AIs and such cannot use this as pure vision,
 * and can't be 'disabled' by roundstart, though that really shouldn't happen anyway.
 */
/obj/machinery/camera/bodycamera
	start_active = TRUE
	internal_light = FALSE
	camera_upgrade_bitflags = CAMERA_UPGRADE_NO_AI

/obj/machinery/camera/bodycamera/can_use(mob/living/user)
	. = ..()
	if(!.)
		return .
	if(isnull(user))
		return TRUE
	return !!isAI(user) //AIs cant see through body cameras.

/obj/machinery/camera/bodycamera/can_see(ai_visibility = FALSE)
	if(ai_visibility)
		return list()
	return ..()

/obj/machinery/camera/bodycamera/Togglelight(on=0)
	return //no lights
