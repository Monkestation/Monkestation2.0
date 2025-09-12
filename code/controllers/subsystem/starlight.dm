#define STARLIGHT_RUN_TYPE_UPDATE 1
#define STARLIGHT_RUN_TYPE_ENABLE 2

SUBSYSTEM_DEF(starlight)
	name = "Starlight"
	init_order = INIT_ORDER_STARLIGHT
	priority = FIRE_PRIORITY_STARLIGHT
	flags = SS_BACKGROUND | SS_NO_INIT | SS_HIBERNATE
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT // running in the lobby allows us to handle the queue during pre-game

	var/list/turfs_to_update = list()
	var/list/turfs_to_enable = list()
	var/list/currentrun_update
	var/list/currentrun_enable
	var/run_type = STARLIGHT_RUN_TYPE_UPDATE

/datum/controller/subsystem/starlight/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, turfs_to_update),
		NAMEOF(src, turfs_to_enable),
		NAMEOF(src, currentrun_update),
		NAMEOF(src, currentrun_enable),
	)

/datum/controller/subsystem/starlight/Recover()
	turfs_to_update = SSstarlight.turfs_to_update
	turfs_to_enable = SSstarlight.turfs_to_enable

/datum/controller/subsystem/starlight/stat_entry(msg)
	msg = "U:[length(turfs_to_update)]|E:[length(turfs_to_enable)]"
	return ..()

/datum/controller/subsystem/starlight/fire(resumed)
	if(!resumed)
		run_type = STARLIGHT_RUN_TYPE_UPDATE
		currentrun_update = turfs_to_update.Copy()
		currentrun_enable = turfs_to_enable.Copy()

	var/list/current_run
	var/list/current_queue
	if(run_type == STARLIGHT_RUN_TYPE_UPDATE)
		current_run = currentrun_update
		current_queue = turfs_to_update
		while(length(current_run))
			var/turf/open/space/turf = current_run[length(current_run)]
			current_run.len--
			if(isspaceturf(turf))
				turf.immediate_update_starlight()
			current_queue -= turf
			if(MC_TICK_CHECK)
				return
		run_type = STARLIGHT_RUN_TYPE_ENABLE

	if(run_type == STARLIGHT_RUN_TYPE_ENABLE)
		current_run = currentrun_enable
		current_queue = turfs_to_enable
		while(length(current_run))
			var/turf/open/space/turf = current_run[length(current_run)]
			current_run.len--
			if(isspaceturf(turf))
				turf.immediate_enable_starlight()
			current_queue -= turf
			if(MC_TICK_CHECK)
				return
		run_type = STARLIGHT_RUN_TYPE_UPDATE

#undef STARLIGHT_RUN_TYPE_ENABLE
#undef STARLIGHT_RUN_TYPE_UPDATE
