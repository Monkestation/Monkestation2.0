/datum/ai_project/camera_speed
	name = "Optimised Camera Acceleration"
	description = "Using advanced deep learning algorithms you could boost your camera traverse speed."
	research_cost = 250
	ram_required = 1
	category = AI_PROJECT_CAMERAS

/datum/ai_project/camera_speed/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.acceleration = TRUE

/datum/ai_project/camera_speed/stop()
	ai.acceleration = initial(ai.acceleration)
	return ..()
