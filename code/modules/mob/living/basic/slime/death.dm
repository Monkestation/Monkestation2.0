/mob/living/basic/slime/death(gibbed)
	if(stat == DEAD)
		return
	pending_ranch_mutation = null
	if(!gibbed && life_stage == SLIME_LIFE_STAGE_ADULT && !blocks_reproduction)
		var/mob/living/basic/slime/new_slime = new(drop_location(), slime_type.type)

		new_slime.ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE)
		new_slime.regenerate_icons()

		set_life_stage(SLIME_LIFE_STAGE_BABY)
		SEND_SIGNAL(src, COMSIG_SLIME_SPLIT, new_slime)
		revive(HEAL_ALL)
		regenerate_icons()
		update_name()
		return

	if(buckled)
		stop_feeding(silent = TRUE)
	equipped_hat?.forceMove(drop_location())

	. = ..(gibbed)
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/slime/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	death(TRUE)
	qdel(src)
