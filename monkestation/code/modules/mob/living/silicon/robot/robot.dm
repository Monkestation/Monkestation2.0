/mob/living/silicon/robot
	var/unborgable_prompted_ghosts = FALSE

/mob/living/silicon/robot/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(prompt_ghosts_if_unborgable)), 2 SECONDS, TIMER_UNIQUE)

/mob/living/silicon/robot/Login()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(prompt_ghosts_if_unborgable)), 2 SECONDS, TIMER_UNIQUE)

/mob/living/silicon/robot/proc/prompt_ghosts_if_unborgable()
	if(unborgable_prompted_ghosts || !HAS_MIND_TRAIT(src, TRAIT_UNBORGABLE))
		return
	unborgable_prompted_ghosts = TRUE
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		check_jobban = JOB_CYBORG,
		role = JOB_CYBORG,
		poll_time = 25 SECONDS,
		checked_target = src,
		alert_pic = src,
		role_name_text = JOB_CYBORG,
	)
	if(chosen_one)
		to_chat(src, span_warning("Your mob has been taken over by a ghost, due to being otherwise unborgable."))
		message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(src)]) to replace unborgable player.")
		log_game("[key_name(chosen_one)] has taken control of ([key_name(src)]) to replace unborgable player.")
		ghostize(can_reenter_corpse = FALSE)
		key = chosen_one.key
