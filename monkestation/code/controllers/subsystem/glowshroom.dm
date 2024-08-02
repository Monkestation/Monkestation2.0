PROCESSING_SUBSYSTEM_DEF(glowshrooms)
	name = "Glowshroom Processing"
	priority = 10
	runlevels = RUNLEVEL_GAME
	stat_tag = "GSP"

/datum/controller/subsystem/processing/glowshrooms/fire(resumed = FALSE)
	if(!resumed)
		sort_processing()
	return ..()

/datum/controller/subsystem/processing/glowshrooms/proc/sort_processing()
	list_clear_nulls(processing)
	sortTim(processing, GLOBAL_PROC_REF(cmp_glowshroom_spread))

/proc/cmp_glowshroom_spread(obj/structure/glowshroom/a, obj/structure/glowshroom/b)
	return a.last_successful_spread - b.last_successful_spread
