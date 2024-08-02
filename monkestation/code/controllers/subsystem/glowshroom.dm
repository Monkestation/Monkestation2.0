PROCESSING_SUBSYSTEM_DEF(glowshrooms)
	name = "Glowshroom Processing"
	priority = 10
	runlevels = RUNLEVEL_GAME
	stat_tag = "GSP"

/datum/controller/subsystem/processing/glowshrooms/fire(resumed = FALSE)
	if(!resumed)
		sort_processing()
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/processing/glowshrooms/proc/sort_processing()
	list_clear_nulls(processing)
	sortTim(processing, GLOBAL_PROC_REF(cmp_glowshroom_spread))

/proc/cmp_glowshroom_spread(obj/structure/glowshroom/a, obj/structure/glowshroom/b)
	return a.last_successful_spread - b.last_successful_spread
