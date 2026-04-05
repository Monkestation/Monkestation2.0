/datum/component/blessed_plant_tray
	var/delete_timer_id

/datum/component/blessed_plant_tray/Initialize(delete_after = 2 MINUTES)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	delete_timer_id = QDEL_IN_STOPPABLE(src, delete_after)

/datum/component/blessed_plant_tray/Destroy(force)
	deltimer(delete_timer_id)
	delete_timer_id = null
	return ..()
