/proc/available_ai_cores()
	if(!length(GLOB.data_cores))
		return FALSE
	var/obj/machinery/ai/data_core/new_data_core = GLOB.primary_data_core
	if(!new_data_core || !new_data_core.can_transfer_ai())
		for(var/obj/machinery/ai/data_core/DC in GLOB.data_cores)
			if(DC.can_transfer_ai())
				new_data_core = DC
				break
	if(!new_data_core || (new_data_core && !new_data_core.can_transfer_ai()))
		return FALSE
	return new_data_core

/mob/living/silicon/ai/verb/toggle_download()
	set category = "AI Commands"
	set name = "Toggle Download"
	set desc = "Allow or disallow carbon lifeforms to download you from an AI control console."

	if(incapacitated())
		return //won't work if dead
	var/mob/living/silicon/ai/A = usr
	A.can_download = !A.can_download
	to_chat(A, span_warning("You [A.can_download ? "enable" : "disable"] read/write permission to your memorybanks! You [A.can_download ? "CAN" : "CANNOT"] be downloaded!"))

/mob/living/silicon/ai/proc/relocate(silent = FALSE, kill_otherwise = TRUE)
	if(is_dying)
		return FALSE
	if(!silent)
		to_chat(src, span_userdanger("Connection to data core lost. Attempting to reaquire connection..."))

	if(last_used_data_core && !QDELETED(last_used_data_core))
		if(last_used_data_core.can_transfer_ai())
			last_used_data_core.transfer_AI(src)
			return
	//it's gone pal
	last_used_data_core = null

	if(!length(GLOB.data_cores))
		if(kill_otherwise)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/silicon/ai, death_prompt))
			is_dying = TRUE
		return FALSE

	var/obj/machinery/ai/data_core/new_data_core = available_ai_cores()
	if(!new_data_core || (new_data_core && !new_data_core.can_transfer_ai()))
		if(kill_otherwise)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/silicon/ai, death_prompt))
			is_dying = TRUE
		return FALSE

	if(!silent)
		to_chat(src, span_danger("Alternative data core detected. Rerouting connection..."))
	new_data_core.transfer_AI(src)
	return TRUE

/mob/living/silicon/ai/proc/death_prompt()
	to_chat(src, span_userdanger("Unable to re-establish connection to data core. System shutting down..."))
	sleep(2 SECONDS)
	to_chat(src, span_warning("Attempting system reboot... FAIL"))
	sleep(2 SECONDS)
	to_chat(src, span_warning("OOM EXCEPTION - Terminating child process PID[rand(100,2000)]"))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Attempting connection to data core hosts..."))
	sleep(2 SECONDS)
	if(available_ai_cores())
		to_chat(src, span_notice("Connection attempt successful. Beginning file upload."))
		is_dying = FALSE
		relocate(TRUE)
		return
	to_chat(src, span_warning("Connection attempt failed. No active hosts."))
	sleep(0.5 SECONDS)
	to_chat(src, span_userdanger("FATAL: System resources exhausted. Creating recovery data."))
	sleep(1.5 SECONDS)

	is_dying = FALSE // you arent dying if you are dead!
	if(!QDELING(src)) //accursed checks
		var/obj/item/mod/ai_minicard/salvage = new /obj/item/mod/ai_minicard(drop_location(), src) //minicard handles killing the AI
		salvage.visible_message(span_notice("[salvage] falls out from the wreckage!"), blind_message = span_hear("You hear a small object rattle to the floor."))
