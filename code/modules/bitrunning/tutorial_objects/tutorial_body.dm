/mob/living/carbon/human/tutorial/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ENTER_AREA, PROC_REF(checks_area))
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(return_to_lobby))

/mob/living/carbon/human/tutorial/Destroy()
	UnregisterSignal(src, COMSIG_ENTER_AREA)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)
	return ..()

/mob/living/carbon/human/tutorial/proc/checks_area(atom/movable/source, area/new_area)
	SIGNAL_HANDLER
	if(istype(new_area, /area/centcom/central_command_areas/hall/tutorial_chamber) || stat == DEAD)
		return

	//gives the player a heart attack lol
	playsound_local(src, 'sound/effects/adminhelp.ogg', 100)
	to_chat(src, span_bolddanger("You are leaving the tutorial chamber, you will be sent to lobby in 5 seconds! Return back to tutorial chamber if you do not wish to do so!"))
	addtimer(CALLBACK(src, PROC_REF(return_to_lobby)), 5 SECONDS)

/mob/living/carbon/human/tutorial/proc/return_to_lobby()
	if(istype(get_area(src), /area/centcom/central_command_areas/hall/tutorial_chamber) || stat == DEAD)
		return

	//returns to lobby and qdel.
	if(mind)
		var/mob/dead/new_player/go_to_hell = new()
		mind.transfer_to(go_to_hell, TRUE)
		qdel(src)
