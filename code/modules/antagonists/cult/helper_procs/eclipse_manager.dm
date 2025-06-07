GLOBAL_DATUM_INIT(eclipse, /datum/eclipse_manager, new)

/datum/eclipse_manager
	var/eclipse_start_time = 0
	var/eclipse_end_time = 0
	var/eclipse_duration = 0
	var/eclipse_problem_announcement //set on eclipse_start()

	//light dimming
	var/light_reduction = 0.5

	var/timestopped	//sigh

	var/delay_first_announcement = 10 SECONDS	//time after the eclipse starts before it gets announced
	var/delay_end_announcement = 5 SECONDS		//time after the eclipse end before an announcement confirms it has ended
	var/delay_problem_announcement = 3 MINUTES	//how long after the eclipse's supposed end will the crew be warned (in case the cult is extending the eclipse's duration)

	var/problem_announcement = FALSE
	var/eclipse_finished = FALSE

/proc/eclipse_trigger_cult()
	if (!GLOB.eclipse)
		return
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		return
	GLOB.eclipse.eclipse_start(cult.eclipse_window)

/proc/eclipse_trigger_random()
	if (!GLOB.eclipse)
		return
	GLOB.eclipse.eclipse_start(rand(12 MINUTES, 20 MINUTES))

/datum/eclipse_manager/proc/eclipse_start(duration)
	eclipse_start_time = world.time
	eclipse_duration = duration
	eclipse_end_time = eclipse_start_time + eclipse_duration
	eclipse_problem_announcement = eclipse_end_time + delay_problem_announcement
	SSshuttle.registerHostileEnvironment(src)
	SShell_universe.start_hell()

	START_PROCESSING(SSobj, src)
	update_station_lights()

	/*
	for (var/mob/M in GLOB.player_list)
		M.playsound_local(get_turf(M), 'sound/effects/wind/wind_5_1.ogg', 100, 0)

	spawn (delay_first_announcement)
		command_alert(/datum/command_alert/eclipse_start)
	*/

/datum/eclipse_manager/process()
	if (world.time >= eclipse_end_time)

		var/datum/team/cult/cult = locate_team(/datum/team/cult)
		if (!cult || (!cult.tear_ritual && !cult.bloodstone))
			eclipse_end()
		else if (!cult.overtime_announcement)
			cult.overtime_announcement = TRUE
			for (var/datum/mind/mind in cult.members)
				var/mob/M = mind.current
				to_chat(M, span_cult("The Eclipse is entering overtime. Even though its time as run out, Nar-Sie won't let it end as long as the Tear Reality rune is still active, or the Blood Stone is still standing.") )
		else if (!problem_announcement && (world.time >= eclipse_problem_announcement))
			problem_announcement = TRUE
			//command_alert(/datum/command_alert/eclipse_too_long)

/datum/eclipse_manager/proc/eclipse_end()
	STOP_PROCESSING(SSobj, src)

	update_station_lights()
	eclipse_finished = TRUE
	SSshuttle.clearHostileEnvironment(src)

	/*
	spawn(delay_end_announcement)
		command_alert(/datum/command_alert/eclipse_end)
	*/

/datum/eclipse_manager/proc/update_station_lights()
	return
	/*
	var/list/station_zs = levels_by_trait(ZTRAIT_STATION)
	for (var/datum/light_source/LS in locate())
		if (LS.top_atom.z )
			LS.force_update()
			CHECK_TICK
	*/
