SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS

	var/list/processing = list()
	var/list/currentrun = list()
	///only contains living players for some reason
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	var/static/list/cheeserats = list()
	var/static/list/cubecows = list()
	var/static/list/cubepigs = list()

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = FALSE)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	var/seconds_per_tick = wait / (1 SECONDS) // TODO: Make this actually responsive to stuff like pausing and resuming
	while(length(currentrun))
		var/mob/living/mob = currentrun[length(currentrun)]
		currentrun.len--
		if(mob)
			mob.Life(seconds_per_tick, times_fired)
		else
			processing -= mob
		if (MC_TICK_CHECK)
			return
