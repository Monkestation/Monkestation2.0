/datum/ai_project/nightvision
	name = "Nightvision Camera Upgrade"
	description = "By referencing previous imagery of the area and adjusting contrast of camera footage, we can approximate imagery in otherwise pitch-black areas."
	research_cost = 2000
	ram_required = 3
	category = AI_PROJECT_CAMERAS

/datum/ai_project/nightvision/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	if(ai.lighting_cutoff >= LIGHTING_CUTOFF_REAL_LOW) // If the ai has equal better vision than this for some ungodly reason then dont run it.
		to_chat(ai, span_warning("Camera network night vision imagery is already running more efficiently than project; preventing redundant processing."))
		return .
	ai.lighting_cutoff = LIGHTING_CUTOFF_REAL_LOW
	ai.update_sight()

/datum/ai_project/nightvision/stop()
	if(!(ai.lighting_cutoff > LIGHTING_CUTOFF_REAL_LOW))
		ai.lighting_cutoff = LIGHTING_CUTOFF_VISIBLE
		ai.update_sight()
	return ..()
