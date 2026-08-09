/datum/ai_project/nanites
	name = "Nanite Control"
	description = "Connecting to the Nanite Cloud grants you the ability to see and control Nanites."
	research_cost = 2000
	ram_required = 1
	category = AI_PROJECT_SURVEILLANCE
//	research_requirements = list(/datum/ai_project/examine_humans)

/datum/ai_project/nanites/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	if(ai.sensors_on)
		ai.toggle_sensors(TRUE)
	ai.d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	ai.toggle_sensors(TRUE)
	add_ability(/datum/action/innate/internal_nanite_menu)


/datum/ai_project/nanites/stop()
	if(ai.sensors_on) //HUDs are weird. This has to be first so we're removed from the "advanced" HUD. It checks the d_hud and med_hud variable to see which one we remove from first.
		ai.toggle_sensors(TRUE)

	ai.d_hud = DATA_HUD_DIAGNOSTIC_BASIC
	ai.toggle_sensors(TRUE)
	remove_ability(/datum/action/innate/internal_nanite_menu)
	return ..()
