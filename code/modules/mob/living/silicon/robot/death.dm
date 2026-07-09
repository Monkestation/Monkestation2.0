
/mob/living/silicon/robot/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/silicon/robot/dust(just_ash, drop_items, force)
	// You do not get MMI'd if you are dusted
	QDEL_NULL(mmi)
	return ..()

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(gibbed)
		dump_into_mmi()
	else
		logevent("FATAL -- SYSTEM HALT")
		modularInterface.shutdown_computer()
	. = ..()

	notify_ai(AI_NOTIFICATION_CYBORG_DEATH)

	locked = FALSE //unlock cover

	if(!QDELETED(builtInCamera) && builtInCamera.camera_enabled)
		builtInCamera.toggle_cam(src, FALSE)

	toggle_headlamp(TRUE) //So borg lights are disabled when killed.

	drop_all_held_items() // particularly to ensure sight modes are cleared

	update_icons()

	unbuckle_all_mobs(TRUE)

	SSblackbox.ReportDeath(src)
