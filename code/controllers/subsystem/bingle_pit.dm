SUBSYSTEM_DEF(bingle_pit)
	name = "Bingle Pit Processing"
	priority = FIRE_PRIORITY_PROCESS
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT | SS_HIBERNATE
	wait = 0.2 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/obj/structure/bingle_hole/bingle_holes = list()
	var/list/currentrun = list()

/datum/controller/subsystem/bingle_pit/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, bingle_holes),
		NAMEOF(src, currentrun),
	)

/datum/controller/subsystem/bingle_pit/stat_entry(msg)
	msg = "BP:[length(bingle_holes)]"
	return ..()

/datum/controller/subsystem/bingle_pit/fire(resumed = FALSE)
	if (!resumed)
		currentrun = bingle_holes.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(length(current_run))
		var/obj/structure/bingle_hole/hole = current_run[length(current_run)]
		current_run.len--
		hole.process(wait * 0.1)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/bingle_pit/proc/add_bingle_hole(obj/structure/bingle_hole/hole)
	bingle_holes += hole

/datum/controller/subsystem/bingle_pit/proc/remove_bingle_hole(obj/structure/bingle_hole/hole)
	bingle_holes -= hole
	currentrun -= hole
