/datum/ai_project/camera_tracker
	name = "Camera Memory Tracker"
	description = "Using complex LSTM nodes it is possible to automatically detect when a tagged individual enters camera visibility."
	research_cost = 2500
	ram_required = 3
	research_requirements = list(/datum/ai_project/examine_humans)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/camera_tracker/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.canCameraMemoryTrack = TRUE
	ai.add_verb_ai(/mob/living/silicon/ai/proc/choose_camera_target)

/datum/ai_project/camera_tracker/stop()
	ai.canCameraMemoryTrack = FALSE
	remove_verb(ai, /mob/living/silicon/ai/proc/choose_camera_target)
	return ..()

/mob/living/silicon/ai/proc/choose_camera_target()
	set name = "Choose Camera Memory Target"
	set category = "AI Commands"
	set desc = "Select a target for the camera memory tracker. Case sensitive."

	if(incapacitated())
		return
	var/target = tgui_input_text(usr, "Please enter the target's full name:", "Camera Tracker", "", MAX_NAME_LEN)
	if(!target)
		to_chat(usr, span_warning("Cancelled all targets."))
		cameraMemoryTarget = null
		return

	cameraMemoryTarget = findname(target)
	if(isnull(cameraMemoryTarget))
		to_chat(usr, span_warning("Failed to find anyone named [target]."))
	else
		to_chat(usr, span_notice("Now tracking [target]."))

	cameraMemoryTickCount = 0
	return
