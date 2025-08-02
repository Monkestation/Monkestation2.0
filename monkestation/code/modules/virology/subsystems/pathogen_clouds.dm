#define RUN_TYPE_CLOUDS 1
#define RUN_TYPE_CORES 2

SUBSYSTEM_DEF(pathogen_clouds)
	name = "Pathogen Clouds"
	init_order = INIT_ORDER_PATHOGEN
	priority = FIRE_PRIORITY_PATHOGEN
	wait = 1 SECONDS
	flags = SS_BACKGROUND | SS_NO_INIT | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/current_run_cores = list()
	var/list/current_run_clouds = list()
	var/list/cores = list()
	var/list/clouds = list()
	var/current_run_level = RUN_TYPE_CLOUDS

/datum/controller/subsystem/pathogen_clouds/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, current_run_cores),
		NAMEOF(src, current_run_clouds),
		NAMEOF(src, cores),
		NAMEOF(src, clouds),
	)

/datum/controller/subsystem/pathogen_clouds/stat_entry(msg)
	msg += "Run Cores:[length(current_run_cores)]"
	msg += "Cores:[length(cores)]"
	msg += "Run Clouds:[length(current_run_clouds)]"
	msg += "Clouds:[length(clouds)]"
	return ..()

/datum/controller/subsystem/pathogen_clouds/Recover()
	cores = SSpathogen_clouds.cores.Copy()
	clouds = SSpathogen_clouds.clouds.Copy()

/datum/controller/subsystem/pathogen_clouds/fire(resumed = FALSE)
	if(!resumed)
		current_run_cores = cores.Copy()
		current_run_clouds = clouds.Copy()

	var/list/currentrun
	if(current_run_level == RUN_TYPE_CLOUDS)
		currentrun = current_run_clouds
		while(length(currentrun))
			var/obj/effect/pathogen_cloud/cloud = currentrun[length(currentrun)]
			currentrun.len--
			if(QDELETED(cloud))
				clouds -= cloud
				continue
			//If we exist ontop of a core transfer viruses and die unless parent this means something moved back.
			//This should prevent mobs breathing in hundreds of clouds at once
			for(var/obj/effect/pathogen_cloud/core/core in cloud.loc)
				for(var/datum/disease/acute/virus in cloud.viruses)
					if("[virus.uniqueID]-[virus.subID]" in core.id_list)
						continue
					core.viruses |= virus.Copy()
					core.modified = TRUE
				qdel(cloud)
			if(MC_TICK_CHECK)
				return
		current_run_level = RUN_TYPE_CORES

	if(current_run_level == RUN_TYPE_CORES)
		currentrun = current_run_cores
		while(length(currentrun))
			var/obj/effect/pathogen_cloud/core = currentrun[length(currentrun)]
			currentrun.len--
			if(QDELETED(core))
				cores -= core
				continue

			if(!core.moving || core.target == get_turf(core))
				for(var/obj/effect/pathogen_cloud/core/other_core in core.loc)
					if(other_core == core || other_core.moving)
						continue
					for(var/datum/disease/acute/virus in other_core.viruses)
						if("[virus.uniqueID]-[virus.subID]" in core.id_list)
							continue
						core.viruses |= virus.Copy()
						core.modified = TRUE
					qdel(other_core)
				core.moving = FALSE
			if(MC_TICK_CHECK)
				return
		current_run_level = RUN_TYPE_CLOUDS

#undef RUN_TYPE_CORES
#undef RUN_TYPE_CLOUDS
