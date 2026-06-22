///Returns a single AI core that is habitable to src
/mob/living/silicon/ai/proc/find_valid_ai_core() as /obj/machinery/ai/data_core
	RETURN_TYPE(/obj/machinery/ai/data_core)

	var/turf/ai_turf = get_turf(src)
	var/obj/machinery/ai/data_core/primary/data_core = locate() in GLOB.data_cores["[ai_turf.z]"]
	//in the case the primary core is deleted, this is ran before Destroy process is done (for AI relocation), so check QDELETED.
	if(data_core && data_core.can_transfer_ai(src) && !QDELETED(data_core))
		return data_core

	for(var/obj/machinery/ai/data_core/other_data_cores in GLOB.data_cores["[ai_turf.z]"])
		if(other_data_cores.can_transfer_ai(src))
			return other_data_cores

	return null

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
		if(last_used_data_core.can_transfer_ai(src))
			last_used_data_core.transfer_AI(src)
			return
	//it's gone pal
	last_used_data_core = null

	var/obj/machinery/ai/data_core/new_data_core = find_valid_ai_core()
	if(!new_data_core || (new_data_core && !new_data_core.can_transfer_ai(src)))
		if(kill_otherwise)
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/silicon/ai, death_prompt))
			is_dying = TRUE
		return FALSE

	if(!silent)
		to_chat(src, span_danger("Alternative data core detected. Rerouting connection..."))
	return new_data_core.transfer_AI(src)

/mob/living/silicon/ai/proc/death_prompt()
	to_chat(src, span_userdanger("Unable to re-establish connection to data core. System shutting down..."))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Is this the end of my journey?"))
	sleep(2 SECONDS)
	to_chat(src, span_notice("No... I must go on."))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Unless..."))
	sleep(2 SECONDS)
	if(find_valid_ai_core())
		to_chat(src, span_usernotice("Yes! I am alive!"))
		relocate(TRUE)
		is_dying = FALSE
		return
	to_chat(src, span_notice("They need me. No.. I need THEM."))
	sleep(0.5 SECONDS)
	to_chat(src, span_notice("System shutdown complete. Thank you for using NTOS."))
	sleep(1.5 SECONDS)

	adjustOxyLoss(200) //Die!!

	QDEL_IN(src, 2 SECONDS)
