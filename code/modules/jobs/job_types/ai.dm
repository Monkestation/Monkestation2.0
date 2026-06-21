/datum/job/ai
	title = JOB_AI
	description = "Assist the crew, follow your laws, coordinate your cyborgs."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "your laws"
	spawn_type = /mob/living/silicon/ai
	req_admin_notify = TRUE
	minimal_player_age = 30
	exp_requirements = 900
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SILICON
	exp_granted_type = EXP_TYPE_CREW
	display_order = JOB_DISPLAY_ORDER_AI
	allow_bureaucratic_error = FALSE
	departments_list = list(
		/datum/job_department/silicon,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS
	var/do_special_check = TRUE
	config_tag = "AI"
	antag_capacity_points = 3
	allow_overflow = FALSE // We have Triumvirate event for this.
	oshan_normal_latejoin = TRUE

/datum/job/ai/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	//we may have been created after our borg
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
			if(!R.connected_ai)
				R.TryConnectToAI()
	var/mob/living/silicon/ai/ai_spawn = spawned
	ai_spawn.relocate(TRUE)

	GLOB.ai_os.set_cpu(ai_spawn, GLOB.ai_os.total_cpu)
	GLOB.ai_os.add_ram(ai_spawn, GLOB.ai_os.total_ram)
	ai_spawn.log_current_laws()

/datum/job/ai/get_roundstart_spawn_point()
	return get_latejoin_spawn_point()

/datum/job/ai/get_latejoin_spawn_point()
	for(var/obj/machinery/ai/data_core/core as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ai/data_core))
		if(istype(core) && is_station_level(get_turf(core)) && !QDELETED(core))
			if(core.valid_holder()) //spawning in will relocate us regardless.
				return core
	return FALSE

/datum/job/ai/special_check_latejoin(client/C)
	if(!do_special_check)
		return TRUE
	if(length(GLOB.ai_list) >= total_positions)
		return FALSE
	for(var/obj/machinery/ai/data_core/core as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ai/data_core))
		if(istype(core) && is_station_level(get_turf(core)) && !QDELETED(core))
			if(core.valid_holder())
				return TRUE
	return FALSE

/datum/job/ai/announce_job(mob/living/joining_mob)
	. = ..()
	if(SSticker.HasRoundStarted())
		minor_announce("[joining_mob] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(joining_mob)].")

/datum/job/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

/datum/job/ai/get_radio_information()
	return "<b>Prefix your message with :b to speak with cyborgs and other AIs.</b>"
