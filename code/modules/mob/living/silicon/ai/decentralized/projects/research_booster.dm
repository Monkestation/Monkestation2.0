/datum/ai_project/research_booster
	name = "Research Acceleration"
	description = "Using fast RAM instead of slow SSD and HDD storage allows for the production of approximately 20% more research points."
	research_cost = 2500
	ram_required = 8
	category = AI_PROJECT_MISC
	///Reference to the techweb we're boosting.
	var/datum/techweb/techweb_boosting

/datum/ai_project/research_booster/Destroy(force)
	techweb_boosting = null
	return ..()

/datum/ai_project/research_booster/canRun()
	. = ..()
	var/turf/ai_turf = get_turf(ai)
	var/obj/machinery/rnd/server/selected_server = pick(SSresearch.get_available_servers(ai_turf))
	if(isnull(selected_server))
		return FALSE
	techweb_boosting = selected_server.stored_research
	return ..()

/datum/ai_project/research_booster/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	techweb_boosting.ai_boosted = TRUE

/datum/ai_project/research_booster/stop()
	techweb_boosting.ai_boosted = FALSE
	techweb_boosting = null
	return ..()
