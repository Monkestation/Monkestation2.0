SUBSYSTEM_DEF(navmap)
	name = "Navmap"
	flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	/// Baseline movers used to bake static ground and flying edges.
	var/datum/can_pass_info/ground_rep
	var/datum/can_pass_info/flying_rep
	var/list/bake_queue = list()
	var/list/currentrun
	var/currentrun_index = 1
	var/list/border_blocker_cache
	var/list/mask_whitelist_cache
	var/list/force_conditional_cache
	var/list/auto_dirty_ztraits = list(ZTRAIT_STATION, ZTRAIT_MINING)
	var/alist/auto_dirty_zlevels = alist()
	var/list/space_type_cache
	/// Startup dirties keyed by "x,y,z", since turfs can be replaced.
	var/alist/startup_dirty_turfs = alist()
	/// Startup dirties being baked. Kept across subsystem recovery.
	var/alist/startup_dirty_currentrun = alist()
	/// Terrain cost changes collected during startup.
	var/alist/startup_dirty_costs = alist()
	var/alist/startup_dirty_generation = alist()
	var/alist/startup_dirty_turf_refs = alist()
	var/alist/startup_dirty_ref_zlevels = alist()
	var/alist/startup_baked_generation = alist()
	var/alist/startup_baked_turfs = alist()
	/// Native updates waiting to be sent during startup.
	var/list/startup_publication_batch = list()
	/// True until startup changes have been baked.
	var/startup_finalization_pending = TRUE
	/// Layered navigation groups and z-level lookup.
	var/alist/nav_groups = alist()
	var/alist/z_to_nav_layer = alist()
	var/topology_generation = 0
	/// Changes when turf terrain-cost flags or their passability dependencies are invalidated.
	var/nav_cost_generation = 0
	/// Nonzero terrain costs and later changes, keyed by coordinate.
	var/alist/published_nav_cost_flags = alist()
	/// Weighted DM fallback searches that have consumed terrain costs.
	var/list/datum/pathfind/navmap/active_cost_searches = list()
	var/topology_rebuild_in_progress = FALSE
	var/alist/nav_links = alist()
	/// Navigation links indexed by their source turf for the DM fallback search.
	var/alist/nav_links_by_source = alist()
	var/next_nav_link_id = 1

/// Initializes bake representatives, blocker caches, and existing z-level data.
/datum/controller/subsystem/navmap/Initialize()
	ground_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	ground_rep.movement_type = GROUND

	flying_rep = new /datum/can_pass_info(null, null, no_id = TRUE)
	flying_rep.movement_type = FLYING

	border_blocker_cache = typecacheof(list(
		/obj/structure/window,
		/obj/machinery/door/window,
		/obj/structure/railing,
		/obj/machinery/door/firedoor/border_only,
		/obj/structure/slime_pen_barrier,
	))
	mask_whitelist_cache = list()
	for(var/table_type in typesof(/obj/structure/table))
		mask_whitelist_cache[table_type] = PASSTABLE
	for(var/grille_type in typesof(/obj/structure/grille))
		mask_whitelist_cache[grille_type] = PASSGRILLE
	force_conditional_cache = typecacheof(list(
		/obj/structure/girder,
	))

	space_type_cache = typecacheof(/turf/open/space)
	rebuild_topology()
	sync_native_state()
	for(var/z in SSmapping.levels_by_any_trait(auto_dirty_ztraits))
		auto_dirty_zlevels[z] = TRUE
	if(!navmap_pathfinder_available())
		log_world("Navmap pathfinder unavailable, using the DM fallback: [GLOB.navmap_pathfinder_error]")

	for(var/z in 1 to world.maxz)
		if(auto_dirty_zlevels[z])
			prebake_z(z)

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(on_new_zlevel))
	flush_startup_dirty_turfs()
	startup_finalization_pending = FALSE

	return SS_INIT_SUCCESS

/// Preserves baked navigation-link state when the subsystem is replaced.
/datum/controller/subsystem/navmap/Recover()
	flags |= SS_NO_INIT
	initialized = SSnavmap.initialized
	ground_rep = SSnavmap.ground_rep
	flying_rep = SSnavmap.flying_rep
	bake_queue = SSnavmap.bake_queue
	currentrun = SSnavmap.currentrun
	currentrun_index = SSnavmap.currentrun_index
	border_blocker_cache = SSnavmap.border_blocker_cache
	mask_whitelist_cache = SSnavmap.mask_whitelist_cache
	force_conditional_cache = SSnavmap.force_conditional_cache
	auto_dirty_zlevels = SSnavmap.auto_dirty_zlevels
	space_type_cache = SSnavmap.space_type_cache
	startup_dirty_turfs = SSnavmap.startup_dirty_turfs
	startup_dirty_currentrun = SSnavmap.startup_dirty_currentrun
	startup_dirty_costs = SSnavmap.startup_dirty_costs
	startup_dirty_generation = SSnavmap.startup_dirty_generation
	startup_dirty_turf_refs = SSnavmap.startup_dirty_turf_refs
	startup_dirty_ref_zlevels = SSnavmap.startup_dirty_ref_zlevels
	startup_baked_generation = SSnavmap.startup_baked_generation
	startup_baked_turfs = SSnavmap.startup_baked_turfs
	startup_publication_batch = SSnavmap.startup_publication_batch
	startup_finalization_pending = SSnavmap.startup_finalization_pending
	nav_groups = SSnavmap.nav_groups
	z_to_nav_layer = SSnavmap.z_to_nav_layer
	topology_generation = SSnavmap.topology_generation
	nav_cost_generation = SSnavmap.nav_cost_generation
	published_nav_cost_flags = SSnavmap.published_nav_cost_flags
	active_cost_searches = SSnavmap.active_cost_searches
	nav_links = SSnavmap.nav_links
	nav_links_by_source = SSnavmap.nav_links_by_source
	next_nav_link_id = SSnavmap.next_nav_link_id

/// Enables automatic dirtying for a newly relevant z-level.
/datum/controller/subsystem/navmap/proc/on_new_zlevel(datum/source, datum/space_level/new_level)
	SIGNAL_HANDLER
	for(var/trait in auto_dirty_ztraits)
		if(new_level.traits[trait])
			auto_dirty_zlevels[new_level.z_value] = TRUE
			break
	rebuild_topology()
	if(!topology_rebuild_in_progress)
		sync_native_state()
	// The level still needs its content loaded. Bake turfs as they change or are used.

/// Rebuilds the stable group/layer mapping consumed by native multi-z searches.
/datum/controller/subsystem/navmap/proc/rebuild_topology()
	if(topology_rebuild_in_progress)
		return
	topology_rebuild_in_progress = TRUE
	var/alist/seen_groups = alist()
	nav_groups = alist()
	z_to_nav_layer = alist()
	for(var/z in 1 to world.maxz)
		var/list/stack = SSmapping.get_connected_levels(z)
		if(!length(stack))
			stack = list(z)
		// Sort numerically so native layer order matches z order.
		var/list/ordered = sort_list(stack.Copy(), GLOBAL_PROC_REF(cmp_numeric_asc))
		var/group_id = ordered[1]
		if(seen_groups[group_id])
			continue
		seen_groups[group_id] = TRUE
		var/list/group_levels = list()
		for(var/index in 1 to length(ordered))
			var/level = ordered[index]
			group_levels += level
			z_to_nav_layer[level] = list("group" = group_id, "layer" = index - 1)
		nav_groups[group_id] = group_levels
	topology_generation++
	topology_rebuild_in_progress = FALSE

/// Publishes the current z-level topology to the native cache.
/datum/controller/subsystem/navmap/proc/publish_topology()
	var/list/flat = list()
	for(var/group_id in nav_groups)
		var/list/group_levels = nav_groups[group_id]
		for(var/index in 1 to length(group_levels))
			flat += list(group_id, index - 1, group_levels[index])
	var/success = navmap_pathfinder_topology_update(topology_generation, flat)
	return success

/// Re-publishes native topology and navigation links when state is stale.
/datum/controller/subsystem/navmap/proc/sync_native_state()
	if(!topology_rebuild_in_progress && world.maxz > 0 && (!topology_generation || !length(z_to_nav_layer)))
		rebuild_topology()
	if(!navmap_pathfinder_available())
		return FALSE
	var/list/native_state = navmap_pathfinder_state()
	var/valid_nav_link_count = 0
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		if(!QDELETED(nav_link) && nav_link.source && nav_link.destination)
			valid_nav_link_count++
	if(native_state \
		&& (topology_generation || !world.maxz) \
		&& native_state["generation"] == topology_generation \
		&& native_state["links_generation"] == topology_generation \
		&& native_state["z_count"] == length(z_to_nav_layer) \
		&& native_state["layer_count"] == length(z_to_nav_layer) \
		&& native_state["nav_link_count"] == valid_nav_link_count)
		return TRUE
	var/topology_success = publish_topology()
	var/nav_links_success = topology_success && sync_nav_links(topology_generation)
	if(!topology_success || !nav_links_success)
		return FALSE
	return TRUE

/// Registers a reusable transition and publishes its endpoints to the native cache.
/datum/controller/subsystem/navmap/proc/register_nav_link(datum/nav_link/nav_link)
	if(!nav_link.id)
		nav_link.id = next_nav_link_id++
	nav_links[nav_link.id] = nav_link
	if(!nav_links_by_source[nav_link.source])
		nav_links_by_source[nav_link.source] = alist()
	nav_links_by_source[nav_link.source][nav_link.id] = nav_link
	topology_generation++
	sync_native_state()
	return nav_link.id

/// Removes a transition and republishes the native navigation-link cache.
/datum/controller/subsystem/navmap/proc/unregister_nav_link(datum/nav_link/nav_link)
	if(nav_link.id && nav_links[nav_link.id] == nav_link)
		nav_links[nav_link.id] = null
		nav_links.Remove(nav_link.id)
		var/alist/source_links = nav_links_by_source[nav_link.source]
		if(source_links)
			source_links[nav_link.id] = null
			if(!length(source_links))
				nav_links_by_source[nav_link.source] = null
		topology_generation++
		sync_native_state()

/// Publishes all currently valid navigation links.
/datum/controller/subsystem/navmap/proc/sync_nav_links(generation)
	var/list/flat = list()
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		if(QDELETED(nav_link) || !nav_link.source || !nav_link.destination)
			continue
		flat += list(nav_link.id, nav_link.source.x, nav_link.source.y, nav_link.source.z, nav_link.destination.x, nav_link.destination.y, nav_link.destination.z, nav_link.cost)
	var/success = navmap_pathfinder_links_update(generation, flat)
	return success

/// Publishes effective turf cost flags and notifies fallback searches using changed groups.
/datum/controller/subsystem/navmap/proc/publish_nav_cost_flags(turf/tile, effective_flags)
	var/alist/z_flags = published_nav_cost_flags[tile.z]
	if(!z_flags)
		if(!effective_flags)
			return
		z_flags = alist()
		published_nav_cost_flags[tile.z] = z_flags
	var/alist/y_flags = z_flags[tile.y]
	if(!y_flags)
		if(!effective_flags)
			return
		y_flags = alist()
		z_flags[tile.y] = y_flags
	var/previous_flags = y_flags[tile.x]
	if(isnull(previous_flags) && !effective_flags)
		return
	var/old_flags = isnull(previous_flags) ? 0 : previous_flags
	if(old_flags != effective_flags)
		var/changed_flags = old_flags ^ effective_flags
		nav_cost_generation++
		for(var/datum/pathfind/navmap/search as anything in active_cost_searches)
			search.nav_cost_flags_changed(tile, changed_flags)
	y_flags[tile.x] = effective_flags

/// Native callback for side-effect-free, mover-specific link eligibility.
/proc/navmap_pathfinder_link_can_plan(id, datum/can_pass_info/pass_info)
	var/datum/nav_link/nav_link = SSnavmap.nav_links[id]
	return nav_link && !QDELETED(nav_link) && nav_link.can_plan(pass_info)

/// Checks whether two turfs are connected by z-levels and navigation links.
/datum/controller/subsystem/navmap/proc/groups_reachable(turf/start, turf/goal)
	var/list/start_layer = z_to_nav_layer[start?.z]
	var/list/goal_layer = z_to_nav_layer[goal?.z]
	if(!start_layer || !goal_layer)
		return FALSE
	if(start_layer["group"] == goal_layer["group"])
		return TRUE
	var/alist/adjacency = alist()
	for(var/id in nav_links)
		var/datum/nav_link/nav_link = nav_links[id]
		var/list/source_layer = z_to_nav_layer[nav_link.source?.z]
		var/list/destination_layer = z_to_nav_layer[nav_link.destination?.z]
		if(!source_layer || !destination_layer)
			continue
		if(!adjacency[source_layer["group"]])
			adjacency[source_layer["group"]] = list()
		adjacency[source_layer["group"]] += destination_layer["group"]
	var/list/visited = list(start_layer["group"])
	var/list/frontier = list(start_layer["group"])
	while(length(frontier))
		var/group = frontier[1]
		frontier.Cut(1, 2)
		for(var/neighbor in adjacency[group])
			if(neighbor == goal_layer["group"])
				return TRUE
			if(!(neighbor in visited))
				visited += neighbor
				frontier += neighbor
	return FALSE

/// Reports the number of turfs waiting to bake.
/datum/controller/subsystem/navmap/stat_entry(msg)
	var/pending = length(bake_queue) + max(length(currentrun) - currentrun_index + 1, 0)
	msg = "Dirty:[pending] | using "
	if(navmap_pathfinder_available())
		msg += "native DLL v[GLOB.navmap_pathfinder_version]"
	else
		msg += "DM fallback: [GLOB.navmap_pathfinder_error]"
	return ..()

/// Bakes queued turfs until the tick budget is exhausted.
/datum/controller/subsystem/navmap/fire(resumed)
	if(currentrun_index > length(currentrun))
		if(!length(bake_queue))
			can_fire = FALSE
			return
		currentrun = bake_queue
		bake_queue = list()
		currentrun_index = 1

	while(currentrun_index <= length(currentrun))
		var/turf/baking_turf = currentrun[currentrun_index]
		currentrun_index++
		if(!QDELETED(baking_turf))
			baking_turf.turf_flags &= ~NAV_QUEUED
			baking_turf.nav_bake()
		if(MC_TICK_CHECK)
			return

/// Queues a dirty turf once for asynchronous baking.
/datum/controller/subsystem/navmap/proc/queue_turf_bake(turf/queued_turf)
	if(queued_turf.turf_flags & NAV_QUEUED)
		return
	queued_turf.turf_flags |= NAV_QUEUED
	bake_queue += queued_turf
	if(!can_fire)
		can_fire = TRUE

/// Bakes and bulk-publishes every non-space turf on a z-level.
/datum/controller/subsystem/navmap/proc/prebake_z(z_level)
	var/list/navmap_batch = list()
	var/count = 0
	for(var/turf/baking_turf as anything in Z_TURFS(z_level))
		var/effective_cost_flags = baking_turf.nav_bake(skip_navmap_push = TRUE)
		if(startup_dirty_ref_zlevels[z_level])
			mark_startup_turf_baked(baking_turf)
		navmap_batch += list(baking_turf.x, baking_turf.y, baking_turf.z, baking_turf.nav_pass, effective_cost_flags)
		count++
		if(length(navmap_batch) >= 5000)
			publish_startup_navmap_batch(navmap_batch)
			navmap_batch.Cut()
			CHECK_TICK
	if(length(navmap_batch))
		publish_startup_navmap_batch(navmap_batch)
	return count

/// Sends a batch to the native cache.
/datum/controller/subsystem/navmap/proc/publish_startup_navmap_batch(list/navmap_batch)
	navmap_pathfinder_bulk_update(navmap_batch)

/// Queues a turf and affected neighbours by their coordinates.
/datum/controller/subsystem/navmap/proc/record_startup_dirty_turf(turf/tile)
	if(!tile || !is_auto_dirty_zlevel(tile.z))
		return
	record_startup_dirty_coordinate(tile)
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(tile, dir)
		if(neighbor)
			record_startup_dirty_coordinate(neighbor)
	for(var/dir in GLOB.verticals)
		var/turf/neighbor = get_step_multiz(tile, dir)
		if(!neighbor)
			continue
		record_startup_dirty_coordinate(neighbor)
		if(neighbor.pathing_pass_method == TURF_PATHING_PASS_PROC)
			neighbor.nav_dirty_vertical_dependents()

/// Queues a turf and clears its old navigation data.
/datum/controller/subsystem/navmap/proc/record_startup_dirty_coordinate(turf/tile)
	if(!is_auto_dirty_zlevel(tile.z))
		return
	var/key = "[tile.x],[tile.y],[tile.z]"
	queue_startup_dirty_coordinate(tile.x, tile.y, tile.z)
	startup_dirty_generation[key] = (startup_dirty_generation[key] || 0) + 1
	startup_dirty_turf_refs[tile] = key
	startup_dirty_ref_zlevels[tile.z] = TRUE
	if(!initialized)
		return
	tile.nav_pass = null
	tile.nav_blockers = null
	navmap_pathfinder_update(tile.x, tile.y, tile.z, 0, tile.get_nav_cost_flags())

/// Queues terrain cost changes made during startup.
/datum/controller/subsystem/navmap/proc/record_startup_cost_dirty(turf/tile)
	if(tile && is_auto_dirty_zlevel(tile.z))
		var/key = "[tile.x],[tile.y],[tile.z]"
		queue_startup_dirty_coordinate(tile.x, tile.y, tile.z)
		startup_dirty_costs[key] = TRUE
		startup_dirty_generation[key] = (startup_dirty_generation[key] || 0) + 1
		startup_dirty_turf_refs[tile] = key
		startup_dirty_ref_zlevels[tile.z] = TRUE

/// Queues startup work only on the auto spots
/datum/controller/subsystem/navmap/proc/queue_startup_dirty_coordinate(x, y, z_level)
	if(!is_auto_dirty_zlevel(z_level))
		return
	startup_dirty_turfs["[x],[y],[z_level]"] = TRUE

/// Checks whether a level uses the automatic bake policy.
/datum/controller/subsystem/navmap/proc/is_auto_dirty_zlevel(z_level)
	return auto_dirty_zlevels[z_level] || SSmapping.level_trait(z_level, ZTRAIT_STATION) || SSmapping.level_trait(z_level, ZTRAIT_MINING)

/// Remembers a bake only when this coordinate is already dirty.
/datum/controller/subsystem/navmap/proc/mark_startup_turf_baked(turf/tile)
	var/key = startup_dirty_turf_refs[tile]
	if(!key)
		return
	var/generation = startup_dirty_generation[key]
	if(isnull(generation))
		return
	startup_baked_generation[key] = generation
	startup_baked_turfs[key] = tile

/// Bakes turfs changed during startup.
/datum/controller/subsystem/navmap/proc/flush_startup_dirty_turfs()
	while(length(startup_dirty_turfs) || length(startup_dirty_currentrun) || length(startup_dirty_costs))
		for(var/cost_key in startup_dirty_costs)
			startup_dirty_turfs[cost_key] = TRUE
		startup_dirty_costs.Cut()
		if(!length(startup_dirty_currentrun))
			for(var/turf_key in startup_dirty_turfs.Copy())
				startup_dirty_currentrun[turf_key] = TRUE
				startup_dirty_turfs.Remove(turf_key)
		for(var/turf_key in startup_dirty_currentrun.Copy())
			startup_dirty_currentrun.Remove(turf_key)
			var/list/coordinates = splittext(turf_key, ",")
			if(length(coordinates) != 3)
				continue
			var/turf/tile = locate(text2num(coordinates[1]), text2num(coordinates[2]), text2num(coordinates[3]))
			if(!tile)
				continue
			if(!is_auto_dirty_zlevel(tile.z))
				continue
			var/generation = startup_dirty_generation[turf_key]
			if(!isnull(generation) && startup_baked_generation[turf_key] == generation && startup_baked_turfs[turf_key] == tile)
				continue
			tile.turf_flags &= ~NAV_QUEUED
			var/effective_cost_flags = tile.nav_bake(skip_navmap_push = TRUE)
			mark_startup_turf_baked(tile)
			startup_publication_batch += list(tile.x, tile.y, tile.z, tile.nav_pass, effective_cost_flags)
			if(length(startup_publication_batch) >= 5000)
				publish_startup_navmap_batch(startup_publication_batch)
				startup_publication_batch.Cut()
			CHECK_TICK
		if(length(startup_publication_batch))
			publish_startup_navmap_batch(startup_publication_batch)
			startup_publication_batch.Cut()
	startup_dirty_generation.Cut()
	startup_dirty_turf_refs.Cut()
	startup_dirty_ref_zlevels.Cut()
	startup_baked_generation.Cut()
	startup_baked_turfs.Cut()

