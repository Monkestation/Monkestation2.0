ADMIN_VERB(fix_sm, R_ADMIN, FALSE, "Fix Supermatter", "Resets the supermatter crystal's damage, optionally pausing it for a given time.", ADMIN_CATEGORY_GAME)
	var/obj/machinery/power/supermatter_crystal/sm = GLOB.main_supermatter_engine
	if(QDELETED(sm))
		to_chat(user, span_danger("No main supermatter engine found!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
		return
	var/pause_time = tgui_input_number(user, "How many minutes should the supermatter be \"paused\" for?", "Engineering Moment", max_value = 10)
	if(isnull(pause_time))
		return
	pause_time *= 1 MINUTES
	sm.damage = 0
	sm.set_delam(SM_DELAM_PRIO_NONE, SM_DELAM_STRATEGY_PURGE)
	// reset gas mix of all SM turfs
	var/area/sm_area = get_area(sm)
	for(var/turf/open/sm_turf in sm_area?.get_turfs_from_all_zlevels())
		if(sm_turf.blocks_air)
			continue
		var/datum/gas_mixture/initial_gas_mix = SSair.parse_gas_string(sm_turf.initial_gas_mix, /datum/gas_mixture/turf)
		sm_turf.copy_air(initial_gas_mix)
		sm_turf.update_visuals()
	if(pause_time > 0)
		sm.set_hugbox(TRUE)
		addtimer(CALLBACK(sm, TYPE_PROC_REF(/obj/machinery/power/supermatter_crystal, set_hugbox), FALSE), pause_time, TIMER_UNIQUE | TIMER_OVERRIDE)
		priority_announce("Emergency supermatter repair and stasis systems have been activated. You have [DisplayTimeText(pause_time)] until supermatter stasis is disabled.", "Emergency Supermatter Protocols", ANNOUNCER_POWERON)
		log_admin("[key_name(user)] force-fixed the supermatter crystal at [AREACOORD(sm)], and paused it for [DisplayTimeText(pause_time)].")
		message_admins("[key_name_admin(user)] force-fixed the supermatter crystal at [ADMIN_COORDJMP(sm)], and paused it for [DisplayTimeText(pause_time)].")
	else
		priority_announce("Emergency supermatter systems have been activated, please ensure immediate action to prevent repeat incidents.", "Emergency Supermatter Protocols", ANNOUNCER_POWERON)
		log_admin("[key_name(user)] force-fixed the supermatter crystal at [AREACOORD(sm)].")
		message_admins("[key_name_admin(user)] force-fixed the supermatter crystal at [ADMIN_COORDJMP(sm)].")
	BLACKBOX_LOG_ADMIN_VERB("Fix Supermatter")
