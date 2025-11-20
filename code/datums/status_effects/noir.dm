/datum/status_effect/noir
	id = "noirmode"
	tick_interval = -1

	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

/datum/status_effect/noir/on_apply()
	. = ..()
	owner.add_client_colour(/datum/client_colour/monochrome/noir)

/datum/status_effect/noir/on_remove()
	. = ..()
	owner.remove_client_colour(/datum/client_colour/monochrome/noir)

/// Noir-in-area, removed if the user leaves the given area.
/datum/status_effect/grouped/noir_in_area
	id = "noirinarea"
	tick_interval = -1

	alert_type = null

	var/area/noir_area

/datum/status_effect/grouped/noir_in_area/on_creation(mob/living/new_owner, source, area/tracked_area)
	. = ..()
	if(!.)
		return

	noir_area = tracked_area

/datum/status_effect/grouped/noir_in_area/on_apply()
	. = ..()
	owner.add_client_colour(/datum/client_colour/monochrome/noir)
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(owner_entered_area))

/datum/status_effect/grouped/noir_in_area/on_remove()
	. = ..()
	owner.remove_client_colour(/datum/client_colour/monochrome/noir)
	UnregisterSignal(owner, COMSIG_ENTER_AREA)

/datum/status_effect/grouped/noir_in_area/proc/owner_entered_area(datum/source, area/entered)
	SIGNAL_HANDLER

	if(entered != noir_area)
		qdel(src)
