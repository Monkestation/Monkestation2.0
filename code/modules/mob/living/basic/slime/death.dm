/mob/living/basic/slime/death(gibbed)
	if(stat == DEAD)
		return
	pending_ranch_mutation = null
	if(buckled)
		stop_feeding(silent = TRUE)
	equipped_hat?.forceMove(drop_location())

	. = ..(gibbed)
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/slime/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	death(TRUE)
	qdel(src)
