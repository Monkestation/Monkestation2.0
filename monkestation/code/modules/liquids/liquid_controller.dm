SUBSYSTEM_DEF(liquids)
	name = "Liquid Turfs"
	wait = 0.5 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_LIQUID_TURFS
	var/list/active_groups = list()

	var/list/evaporation_queue = list()
	var/evaporation_counter = 0 //Only process evaporation on intervals
	///groups left to disperse in the current evaporation run
	var/list/currentrun_disperse_groups = list()
	///turfs left to evaporate in the current evaporation run
	var/list/currentrun_evaporation = list()

	var/list/temperature_queue = list()

	var/list/active_ocean_turfs = list()
	var/list/ocean_turfs = list()
	var/list/currentrun_active_ocean_turfs = list()
	var/list/unvalidated_oceans = list()
	var/ocean_counter = 0

	var/run_type = SSLIQUIDS_RUN_TYPE_GROUPS

	///debug variable to toggle evaporation from running
	var/debug_evaporation = FALSE

	var/list/burning_turfs = list()
	var/fire_counter = 0
	///burning turfs left to spread fire from in the current fire run
	var/list/currentrun_fire_spread = list()
	///groups left to burn in the current fire run
	var/list/currentrun_fire_groups = list()

	var/member_counter = 0

	var/list/arrayed_groups = list()

	///list of groups to work on for cached edges
	var/list/cached_edge_work_queue = list()
	///list of groups we are going to work on in group process
	var/list/group_process_work_queue = list()
	///list of all work queue for turf processing
	var/list/active_turf_group_queue = list()
	///list of cached exposures we are working with
	var/list/cached_exposures = list()


/datum/controller/subsystem/liquids/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, active_groups),
		NAMEOF(src, evaporation_queue),
		NAMEOF(src, burning_turfs),
		NAMEOF(src, active_ocean_turfs),
		NAMEOF(src, unvalidated_oceans),
		NAMEOF(src, arrayed_groups),
		NAMEOF(src, cached_exposures),
		NAMEOF(src, currentrun_disperse_groups),
		NAMEOF(src, currentrun_evaporation),
		NAMEOF(src, currentrun_fire_spread),
		NAMEOF(src, currentrun_fire_groups),
		NAMEOF(src, currentrun_active_ocean_turfs),
	)

/datum/controller/subsystem/liquids/stat_entry(msg)
	msg += "AG:[length(active_groups)]|BT:[length(burning_turfs)]|EQ:[length(evaporation_queue)]|AO:[length(active_ocean_turfs)]|UO:[length(unvalidated_oceans)]"
	return ..()

/datum/controller/subsystem/liquids/fire(resumed)
	if(!length(active_groups) && !length(evaporation_queue) && !length(active_ocean_turfs) && !length(burning_turfs) && !length(unvalidated_oceans))
		return

	list_clear_nulls(active_groups)

	if(length(unvalidated_oceans))
		for(var/turf/open/floor/plating/ocean/unvalidated_turf in unvalidated_oceans)
			if(MC_TICK_CHECK)
				return
			unvalidated_turf.assume_self()

	if(length(arrayed_groups))
		list_clear_nulls(arrayed_groups)
		for(var/datum/liquid_group/liquid_group as anything in arrayed_groups)
			if(QDELETED(liquid_group))
				arrayed_groups -= liquid_group
				continue
			while(length(liquid_group.splitting_array)) // three at a time until we either finish or over-run, this should be done before anything else
				liquid_group.work_on_split_queue()
				if(!QDELETED(liquid_group))
					liquid_group.cleanse_members()
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					break

	if(run_type == SSLIQUIDS_RUN_TYPE_GROUPS)
		if(!length(group_process_work_queue))
			group_process_work_queue |= active_groups
		list_clear_nulls(group_process_work_queue)
		if(length(group_process_work_queue))
			var/populate_evaporation = FALSE
			if(!length(evaporation_queue))
				populate_evaporation = TRUE
			for(var/datum/liquid_group/liquid_group as anything in group_process_work_queue)
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					group_process_work_queue -= liquid_group
					continue
				liquid_group.process_group(TRUE)
				if(populate_evaporation && (liquid_group.always_evaporates || liquid_group.expected_turf_height < LIQUID_STATE_ANKLES) && liquid_group.evaporates)
					for(var/turf/listed_turf as anything in liquid_group.members)
						if(!listed_turf || isoceanturf(listed_turf))
							continue
						evaporation_queue |= listed_turf
				group_process_work_queue -= liquid_group

		run_type = SSLIQUIDS_RUN_TYPE_EVAPORATION

	// these phases only set up a new run when the last one finished, so a pause picks up where it left off
	if(run_type == SSLIQUIDS_RUN_TYPE_EVAPORATION)
		if(!debug_evaporation && !length(currentrun_disperse_groups) && !length(currentrun_evaporation))
			evaporation_counter++
			if(evaporation_counter >= REQUIRED_EVAPORATION_PROCESSES)
				evaporation_counter = 0
				currentrun_disperse_groups = active_groups.Copy()
				currentrun_evaporation = evaporation_queue.Copy()
		while(length(currentrun_disperse_groups))
			var/datum/liquid_group/liquid_group = currentrun_disperse_groups[length(currentrun_disperse_groups)]
			currentrun_disperse_groups.len--
			if(QDELETED(liquid_group))
				continue
			liquid_group.check_dead()
			if(!QDELETED(liquid_group) && !length(liquid_group.splitting_array))
				liquid_group.process_turf_disperse()
			if(MC_TICK_CHECK)
				return
		while(length(currentrun_evaporation))
			var/turf/liquid_turf = currentrun_evaporation[length(currentrun_evaporation)]
			currentrun_evaporation.len--
			if(!prob(EVAPORATION_CHANCE) || !liquid_turf || isoceanturf(liquid_turf))
				evaporation_queue -= liquid_turf
			else
				liquid_turf.liquids?.process_evaporation()
			if(MC_TICK_CHECK)
				return
		run_type = SSLIQUIDS_RUN_TYPE_FIRE

	if(run_type == SSLIQUIDS_RUN_TYPE_FIRE)
		if(!length(currentrun_fire_spread) && !length(currentrun_fire_groups))
			fire_counter++
			for(var/datum/liquid_group/liquid_group as anything in active_groups)
				if(length(liquid_group?.burning_members))
					currentrun_fire_spread += liquid_group.burning_members
			if(fire_counter > REQUIRED_FIRE_PROCESSES)
				fire_counter = 0
				currentrun_fire_groups = active_groups.Copy()
		while(length(currentrun_fire_spread))
			var/turf/burning_turf = currentrun_fire_spread[length(currentrun_fire_spread)]
			currentrun_fire_spread.len--
			var/datum/liquid_group/liquid_group = burning_turf?.liquids?.liquid_group
			if(!QDELETED(liquid_group))
				liquid_group.process_spread(burning_turf)
			if(MC_TICK_CHECK)
				return
		while(length(currentrun_fire_groups))
			var/datum/liquid_group/liquid_group = currentrun_fire_groups[length(currentrun_fire_groups)]
			currentrun_fire_groups.len--
			if(QDELETED(liquid_group) || !length(liquid_group.burning_members))
				continue
			liquid_group.process_fire()
			if(MC_TICK_CHECK)
				return
		run_type = SSLIQUIDS_RUN_TYPE_OCEAN

	if(run_type == SSLIQUIDS_RUN_TYPE_OCEAN)
		if(!length(currentrun_active_ocean_turfs))
			ocean_counter++
			if(ocean_counter >= REQUIRED_OCEAN_PROCESSES)
				ocean_counter = 0
				currentrun_active_ocean_turfs = active_ocean_turfs.Copy()
		while(length(currentrun_active_ocean_turfs))
			var/turf/open/floor/plating/ocean/active_ocean = currentrun_active_ocean_turfs[length(currentrun_active_ocean_turfs)]
			currentrun_active_ocean_turfs.len--
			if(isoceanturf(active_ocean))
				active_ocean.process_turf()
			if(MC_TICK_CHECK)
				return
		run_type = SSLIQUIDS_RUN_TYPE_TURFS

	if(run_type == SSLIQUIDS_RUN_TYPE_TURFS)
		member_counter++
		if(!length(active_turf_group_queue))
			active_turf_group_queue += active_groups
		list_clear_nulls(active_turf_group_queue)

		if(member_counter > REQUIRED_MEMBER_PROCESSES)
			list_clear_nulls(cached_exposures)
			if(!length(cached_exposures))
				for(var/datum/liquid_group/liquid_group as anything in active_turf_group_queue)
					if(MC_TICK_CHECK)
						return
					if(QDELETED(liquid_group))
						active_turf_group_queue -= liquid_group
						continue
					liquid_group.build_turf_reagent()
					active_turf_group_queue -= liquid_group
					if(!liquid_group.exposure)
						continue
					cached_exposures |= liquid_group.members

			var/process_count = 0
			var/list/groups_we_rebuilt = list()
			while((process_count <= 500) && length(cached_exposures))
				process_count++
				var/turf/member = pick_n_take(cached_exposures)
				if(!member || QDELETED(member.liquids) || QDELETED(member.liquids.liquid_group))
					continue
				var/datum/liquid_group/liquid_group = member.liquids.liquid_group
				if(!(liquid_group in groups_we_rebuilt))
					groups_we_rebuilt |= liquid_group
					liquid_group.build_turf_reagent()

				if(!istype(member))
					liquid_group.members -= member
					continue
				liquid_group.process_member(member)
				if(MC_TICK_CHECK)
					return
			member_counter = 0
		run_type = SSLIQUIDS_RUN_TYPE_CACHED_EDGES

	if(run_type == SSLIQUIDS_RUN_TYPE_CACHED_EDGES)
		if(!length(cached_edge_work_queue))
			cached_edge_work_queue |= active_groups
		list_clear_nulls(cached_edge_work_queue)

		if(length(cached_edge_work_queue))
			for(var/datum/liquid_group/liquid_group as anything in cached_edge_work_queue)
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					cached_edge_work_queue -= liquid_group
					continue

				liquid_group.build_turf_reagent()
				// a big flood can have more edges than one tick can spread, so it stays queued and carries on next fire
				if(liquid_group.reagents_per_turf > LIQUID_HEIGHT_DIVISOR && liquid_group.process_cached_edges())
					pause()
					return
				cached_edge_work_queue -= liquid_group

		run_type = SSLIQUIDS_RUN_TYPE_GROUPS


ADMIN_VERB(toggle_liquid_debug, R_DEBUG, FALSE, "Liquid Groups Color Debug", "SLiquid Groups Color Debug.", ADMIN_CATEGORY_DEBUG)
	GLOB.liquid_debug_colors = !GLOB.liquid_debug_colors
