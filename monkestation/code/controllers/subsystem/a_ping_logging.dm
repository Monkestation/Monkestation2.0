SUBSYSTEM_DEF(ping_logging)
	name = "Ping Logging"
	wait = 10 // ticks, not seconds
#ifndef UNIT_TESTS
	flags = SS_TICKER | SS_KEEP_TIMING
#else
	flags = SS_NO_INIT | SS_NO_FIRE // literally no reason for this to run during unit tests
#endif
	runlevels = ALL
	var/last_overall_avg = 0
	var/active_spike = FALSE
	var/next_spike_threshold = 0

/datum/controller/subsystem/ping_logging/Initialize()
	fire()
	log_ping("average ping at init: [last_overall_avg]ms", list(
		"state" = "init",
		"average_ping" = last_overall_avg,
	))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ping_logging/Recover()
	flags |= SS_NO_INIT
	last_overall_avg = SSping_logging.last_overall_avg
	active_spike = SSping_logging.active_spike
	next_spike_threshold = SSping_logging.next_spike_threshold

/datum/controller/subsystem/ping_logging/fire(resumed = FALSE)
	var/overall_avg = 0
	var/clients = 0
	for(var/client/client as anything in GLOB.clients)
		var/avgping = client?.avgping
		if(avgping > 10)
			overall_avg += avgping
			clients++
	if(!clients)
		last_overall_avg = 0
		return
	overall_avg = round(overall_avg / clients, 1)
	if(!active_spike)
		if(overall_avg > 500)
			log_ping("ping spike detected (avg >500ms): [overall_avg]ms", list(
				"state" = "starting",
				"average_ping" = overall_avg,
				"last_average_ping" = last_overall_avg,
			))
			active_spike = TRUE
			next_spike_threshold = CEILING(overall_avg, 200) + 200
	else
		if(overall_avg < 250)
			log_ping("spike possibly ended ([overall_avg]ms)", list(
				"state" = "ending",
				"average_ping" = overall_avg,
				"last_average_ping" = last_overall_avg,
			))
			active_spike = FALSE
			next_spike_threshold = 0
		else if(overall_avg > next_spike_threshold)
			log_ping("spike worsening [overall_avg]ms", list(
				"state" = "worsening",
				"average_ping" = overall_avg,
				"last_average_ping" = last_overall_avg,
			))
			next_spike_threshold = CEILING(overall_avg, 200) + 200
	last_overall_avg = overall_avg

/datum/controller/subsystem/ping_logging/stat_entry(msg)
	if(active_spike)
		msg = "ACTIVE SPIKE | LAST:[last_overall_avg]ms | NEXT THRESHOLD:[next_spike_threshold]ms"
	else
		msg = "LAST:[last_overall_avg]ms"
	return ..()

/datum/controller/subsystem/ping_logging/get_metrics()
	. = ..()
	.["custom"] = list("average_ping" = last_overall_avg)
