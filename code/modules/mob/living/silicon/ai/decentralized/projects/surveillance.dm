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

/datum/ai_project/camera_tracker/stop()
	ai.canCameraMemoryTrack = FALSE
	return ..()

/mob/living/silicon/ai/verb/choose_camera_target()
	set name = "Choose Camera Memory Target"
	set category = "AI Commands"
	set desc = "Select a target for the camera memory tracker. Case sensitive."

	if(stat == DEAD)
		return
	if(!canCameraMemoryTrack)
		to_chat(src, span_warning("Unable to set memory targets without Memory Tracker active."))
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

#define MAXIMUM_TARGET_TRACKING 2

/datum/ai_project/advanced_tracking
	name = "Advanced Tracking"
	description = "Sets aside processing power to asychronously track multiple targets at once off the central view. Requires Camera Memory Tracker to research."
	research_cost = 1000 //very strong, but the research requirements is already a mountainload. 7k of total research to get, total zenith of upgrade.
	ram_required = 5
	category = AI_PROJECT_SURVEILLANCE
	research_requirements = list(/datum/ai_project/camera_tracker)
	///List of mobs that we check on each tick if it's on camnet or not and whether or not to spawn an arrow to it.
	var/list/mobs_to_track = list()

/datum/ai_project/advanced_tracking/process()
	//check if any of the targets are in camera net observable view.
	var/list/trackable_mobs = ai.ai_tracking_tool.find_trackable_mobs()
	var/list/hit_mobs = list()

	for(var/weakref_mob in trackable_mobs)
		var/datum/weakref/ref = trackable_mobs[weakref_mob]
		var/mob/living/trackable_mob = ref.resolve()
		if(trackable_mob.can_track())
			if(trackable_mob in mobs_to_track)
				hit_mobs += trackable_mob

	if(!hit_mobs)
		return

	//send bingo hit mobs to AI, and spawns arrows to them
	ai.target_list = hit_mobs

	for(var/mob/tracked_mob in hit_mobs)
		var/area/their_turf = get_turf(tracked_mob)
		var/area/our_turf =  get_turf(ai)

		//skip if not on same z-level
		if(their_turf?.z != our_turf?.z)
			continue

		//try to get dept colors
		var/arrow_color = COLOR_WHITE

		if(ishuman(tracked_mob))
			var/mob/living/carbon/human/tracked_human = tracked_mob
			var/obj/item/card/id/used_id = tracked_human.get_idcard()
			arrow_color = used_id?.trim.department_color

		if(ai.hud_used)
			new /atom/movable/screen/navigate_arrow(null, ai.hud_used, their_turf, arrow_color, ai.eyeobj)

/datum/ai_project/advanced_tracking/stop()
	. = ..()
	remove_ability(/datum/action/innate/ai/advanced_tracking)
	ai.target_list = null
	mobs_to_track = list()
	STOP_PROCESSING(SSprocessing, src)

/datum/ai_project/advanced_tracking/run_project(force_run)
	. = ..()
	mobs_to_track = list()
	var/datum/action/innate/ai/advanced_tracking/tracking = add_ability(/datum/action/innate/ai/advanced_tracking)
	tracking.tracker = src

	START_PROCESSING(SSprocessing, src)

//actual thing that procs to add and remove tracking
/datum/ai_project/advanced_tracking/proc/add_target()
	if(mobs_to_track.len >= MAXIMUM_TARGET_TRACKING)
		to_chat(ai, span_warning("Maximum target to track reached! Removing stored targets!"))
		mobs_to_track = list()
		return

	var/trackable_list = ai.ai_tracking_tool.find_trackable_mobs()
	var/target_name = tgui_input_list(ai, "Select a target", "Tracking", trackable_list)
	if(!target_name || isnull(target_name))
		return
	var/datum/weakref/mob_ref = trackable_list[target_name]

	if(isnull(mob_ref))
		to_chat(ai, span_notice("Target is not on or near any active cameras. Tracking failed."))
		return

	mobs_to_track += mob_ref.resolve()

//button to activate these
/datum/action/innate/ai/advanced_tracking
	name = "Advanced Tracking Button"
	desc = "Controls the tracking subsystem."
	button_icon_state = "reactivate_cameras"
	max_uses = 999
	auto_use_uses = FALSE
	/// the ai project we are referencing, everything but the button itself is put there.
	var/datum/ai_project/advanced_tracking/tracker

/datum/action/innate/ai/advanced_tracking/Activate()
	if(!tracker)
		to_chat(owner, span_warning("No datum connected! Something's fucked up! Call the coders!"))
		return

	tracker.add_target()

#undef MAXIMUM_TARGET_TRACKING
