
/mob/living/silicon/robot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	regenerate_icons()
	show_laws(0)

	addtimer(CALLBACK(src, PROC_REF(prompt_ghosts_if_unborgable)), 2 SECONDS, TIMER_UNIQUE)
