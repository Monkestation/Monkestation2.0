/mob/dead/new_player
	/// What is our temp assignment, used for round start antag calculation
	var/datum/job/temp_assignment

/mob/dead/new_player/Destroy()
	. = ..()
	if(temp_assignment)
		temp_assignment = null

/mob/dead/new_player/verb/observe()
	set category = "IC"
	set name = "Observe"

	if (!(SSticker.current_state > GAME_STATE_STARTUP) && !check_rights())
		to_chat(src, span_warning("Please wait for the server to finish initializing!"))
		return

	make_me_an_observer()
