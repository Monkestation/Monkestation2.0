/datum/ai_project/view_range
	name = "Expanded Camera Network"
	description = "The default range of our camera network's visibility can be expanded to comprehend more imagery at once, expanding our view radius by 3."
	research_cost = 3000
	ram_required = 6
	research_requirements = list(/datum/ai_project/camera_speed)
	category = AI_PROJECT_CAMERAS
	/// How many tiles the viewing range of the ai is increased by.
	var/boost_to = 3

/datum/ai_project/view_range/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	ai.client?.view_size.setTo(boost_to)

/datum/ai_project/view_range/stop()
	ai.client?.view_size.resetToDefault()
	return ..()
