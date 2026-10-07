/datum/ai_project/security_hud
	name = "Advanced Security HUD"
	description = "Using experimental long range passive sensors should allow you to detect various implants such as loyalty implants and tracking implants."
	research_cost = 1250
	ram_required = 2
	category = AI_PROJECT_HUDS

/datum/ai_project/security_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	if(ai.sensors_on)
		ai.toggle_sensors(TRUE)
	ai.sec_hud = DATA_HUD_SECURITY_ADVANCED
	ai.toggle_sensors(TRUE)


/datum/ai_project/security_hud/stop()
	if(ai.sensors_on) //HUDs are weird. This has to be first so we're removed from the "advanced" HUD. It checks the sec_hud variable to see which one we remove from first.
		ai.toggle_sensors(TRUE)
	ai.sec_hud = DATA_HUD_SECURITY_BASIC

	ai.toggle_sensors(TRUE)
	..()

/datum/ai_project/diag_med_hud
	name = "Advanced Medical & Diagnostic HUD"
	description = "Various data processing optimizations should allow you to gain extra knowledge about users when your medical and diagnostic hud is active."
	research_cost = 1000
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/diag_med_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	if(ai.sensors_on)
		ai.toggle_sensors(TRUE)
	ai.d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	ai.med_hud = DATA_HUD_MEDICAL_ADVANCED

	ai.toggle_sensors(TRUE)


/datum/ai_project/diag_med_hud/stop()
	if(ai.sensors_on) //HUDs are weird. This has to be first so we're removed from the "advanced" HUD. It checks the d_hud and med_hud variable to see which one we remove from first.
		ai.toggle_sensors(TRUE)

	ai.d_hud = DATA_HUD_DIAGNOSTIC_BASIC
	ai.med_hud = DATA_HUD_MEDICAL_BASIC

	ai.toggle_sensors(TRUE)
	..()

/datum/ai_project/tray_sensors
	name = "T-Ray Sensors"
	description = "With improved processing of pre-existing optical data and some jury-rigging of components, you'd be able to transmit and process terahertz rays. This allows your pre-existing cameras to have the same functionally as handheld T-ray scanners used in the hands of crewmembers."
	research_cost = 500 //minimal practical usage
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/tray_sensors/process()
	t_ray_scan(ai, 0.5 SECONDS, 9, ai.eyeobj)

/datum/ai_project/tray_sensors/run_project(force_run)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/ai_project/tray_sensors/stop()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/datum/ai_project/engineeringscan
	name = "Advanced Engineering Scan"
	description = "Devote processing time into analyzing powernet harmonics and accurate atmospherics scans derived from tertiary sensors in order to allow scanning of power surging through cables and atmospherics data of a tile."
	research_cost = 500 //if the station is a massive fuckup, in need to a foreman. 1K for trays and this seems a good deal.
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/engineeringscan/run_project(force_run)
	. = ..()
	ai.canEngineeringScan = TRUE

/datum/ai_project/engineeringscan/stop()
	. = ..()
	ai.canEngineeringScan = FALSE

/turf/open/attack_ai(mob/user)
	if(!isAI(user))
		return

	var/mob/living/silicon/ai/ai_scanning = user
	if(!ai_scanning.canEngineeringScan)
		return

	atmos_scan(user, src, TRUE)

	for(var/obj/structure/cable/power_cable in contents)
		to_chat(user, power_cable.get_power_info())
