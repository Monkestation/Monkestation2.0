
/mob/living/silicon/robot/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/silicon/robot/dust(just_ash, drop_items, force)
	// You do not get MMI'd if you are dusted
	QDEL_NULL(mmi)
	return ..()

/mob/living/silicon/robot/death(gibbed, should_dump_mmi = gibbed)
	if(stat == DEAD)
		return
	if(should_dump_mmi)
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

/mob/living/silicon/set_suicide(suicide_state)
	return // Since silicons can be ordered to suicide, they shouldn't be unrevivable when they do it.

/mob/living/silicon/final_checkout(obj/item/suicide_tool, apply_damage = FALSE)
	if(apply_damage)
		apply_suicide_damage()

	suicide_log(suicide_tool)
	death(FALSE)
	ghostize(TRUE) // Same as parent, except we let them re-enter their corpse.

