SUBSYSTEM_DEF(ping_logging)
	name = "Ping Logging"
	wait = 0.5 SECONDS
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_TICKER
	runlevels = ALL
	var/last_overall_avg = 0
	var/active_spike = FALSE
	var/next_spike_threshold = 0

/datum/controller/subsystem/ping_logging/Initialize()
	fire()
	WRITE_LOG("[GLOB.log_directory]/ping.log", "average ping at init: [last_overall_avg]ms")
	return SS_INIT_NO_NEED

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
		if(overall_avg >= 1000)
			WRITE_LOG("[GLOB.log_directory]/ping.log", "ping spike detected (avg >=1000ms): [overall_avg]ms")
			active_spike = TRUE
			next_spike_threshold = FLOOR(overall_avg + 750, 500)
	else
		if(overall_avg < 500)
			WRITE_LOG("[GLOB.log_directory]/ping.log", "spike possibly ended ([overall_avg]ms)")
			active_spike = FALSE
			next_spike_threshold = 0
		else if(overall_avg > next_spike_threshold)
			WRITE_LOG("[GLOB.log_directory]/ping.log", "spike worsening ([overall_avg]ms)")
			next_spike_threshold = FLOOR(overall_avg + 750, 500)
	last_overall_avg = overall_avg

/datum/controller/subsystem/ping_logging/stat_entry(msg)
	msg = "LAST:[last_overall_avg]ms"
	return ..()
