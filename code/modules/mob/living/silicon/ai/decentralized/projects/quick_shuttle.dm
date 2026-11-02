/datum/ai_project/quick_shuttle
	name = "Supply Shuttle Navigation Optimization"
	description = "By dedicating processing to our supply shuttles navigation to use A*, accounting for each sector's time dilation. We can optimize routing by 20%."
	research_cost = 2500
	ram_required = 4
	category = AI_PROJECT_MISC
	/// Mutiplier to how fast the supply shuttle is while the program is active.
	var/shuttle_speed = 0.8

/datum/ai_project/quick_shuttle/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	SSshuttle.supply.callTime *= shuttle_speed

/datum/ai_project/quick_shuttle/stop()
	SSshuttle.supply.callTime *= (1 / shuttle_speed)
	return ..()
