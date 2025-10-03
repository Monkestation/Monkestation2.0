/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, moving atom, distance proc, max nodes, maximum node depth, minimum distance to target, adjacent proc, atom id, turfs to exclude, check only simulated)

Optional extras to add on (in order):
Distance proc : the distance used in every A* calculation (length of path and heuristic)
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Adjacent proc : returns the turfs to consider around the actually processed node
Simulated only : whether to consider unsimulated turfs or not (used by some Adjacent proc)

Also added 'exclude' turf to avoid travelling over; defaults to null

Actual Adjacent procs :

	/turf/proc/reachableAdjacentTurfs : returns reachable turfs in cardinal directions (uses simulated_only)


*/
#define PF_TIEBREAKER 0.005
#define MASK_ODD 85
#define MASK_EVEN 170

/datum/path_node
	var/turf/source
	var/datum/path_node/prev_node
	var/f
	var/g
	var/h
	var/nt
	var/bf

/datum/path_node/New(s,p,pg,ph,pnt,_bf)
	source = s
	setp(p, pg, ph, pnt)
	bf = _bf

/datum/path_node/proc/setp(p,pg,ph,pnt)
	prev_node = p
	g = pg
	h = ph
	calc_f()
	nt = pnt

/datum/path_node/proc/calc_f()
	f = g + h * (1 + PF_TIEBREAKER)

/proc/path_weight_compare_astar(datum/path_node/a, datum/path_node/b)
	return a.f - b.f

/proc/heap_path_weight_compare_astar(datum/path_node/a, datum/path_node/b)
	return b.f - a.f

/proc/get_astar_path_to(requester, end, dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d), maxnodes, maxnodedepth = 30, mintargetdist, adjacent = TYPE_PROC_REF(/turf, reachable_turf_test), access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE)
	var/l = SSastar.mobs.getfree(requester)
	while (!l)
		stoplag(3)
		l = SSastar.mobs.getfree(requester)
	var/list/path = astar(requester, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent, access, exclude, simulated_only, check_z_levels)
	SSastar.mobs.found(l)
	if (!path)
		path = list()
	return path

/proc/astar(requester, _end, dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d), maxnodes, maxnodedepth = 30, mintargetdist, adjacent = TYPE_PROC_REF(/turf, reachable_turf_test), access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE)
	var/turf/end = get_turf(_end)
	var/turf/start = get_turf(requester)
	if (!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if (start == end)
		return FALSE
	if (maxnodes && start.distance_3d(end) > maxnodes)
		return FALSE
	if(maxnodes)
		maxnodedepth = maxnodes

	var/datum/can_pass_info/can_pass_info = new(requester, access)
	var/datum/heap/open = new /datum/heap(GLOBAL_PROC_REF(heap_path_weight_compare_astar))
	var/list/openc = new()
	var/list/path = null

	var/const/ALL_DIRS = NORTH|SOUTH|EAST|WEST
	var/datum/path_node/cur = new /datum/path_node(start, null, 0, start.distance_3d(end), 0, ALL_DIRS, 1)
	open.insert(cur)
	openc[start] = cur

	while (requester && !open.is_empty() && !path)
		cur = open.pop()

		// Destination check - must be exact match or valid closeenough on same Z-level
		var/is_destination = (cur.source == end)

		// Only consider "close enough" if on the same Z-level
		var/closeenough = FALSE
		if (!check_z_levels || cur.source.z == end.z)
			if (mintargetdist)
				closeenough = cur.source.distance_3d(end) <= mintargetdist
			else
				closeenough = cur.source.distance_3d(end) < 1

		if (is_destination || closeenough)
			path = list(cur.source)
			while (cur.prev_node)
				cur = cur.prev_node
				path.Add(cur.source)
			break

		if(maxnodedepth && (cur.nt > maxnodedepth)) //if too many steps, don't process that path
			cur.bf = 0
			CHECK_TICK
			continue

		for(var/dir_to_check in GLOB.cardinals)
			if(!(cur.bf & dir_to_check)) // we can't proceed in this direction
				continue
			// get the turf we end up at if we move in dir_to_check; this may have special handling for multiz moves
			var/turf_to_check = get_step(cur.source, dir_to_check)
			// when leaving a turf with stairs on it, we can change Z, so take that into account
			// this handles both upwards and downwards moves depending on the dir
/*
			var/obj/structure/stairs/source_stairs = locate(/obj/structure/stairs) in cur.source
			if(source_stairs)
				turf_to_check = source_stairs.get_transit_destination(dir_to_check)
*/
			if(turf_to_check != exclude)
				var/datum/path_node/checked_node = openc[turf_to_check]  //current checking turf
				var/reverse = REVERSE_DIR(dir_to_check)
				var/newg = cur.g + call(cur.source, dist)(turf_to_check, requester) // add the travel distance between these two tiles to the distance so far
				if(checked_node)
				//is already in open list, check if it's a better way from the current turf
					checked_node.bf &= ALL_DIRS^reverse //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
					if((newg < checked_node.g))
						if(call(cur.source, adjacent)(requester, turf_to_check, can_pass_info))
							checked_node.setp(cur, newg, checked_node.h, cur.nt + 1)
							open.resort(checked_node)//reorder the changed element in the list
				else
				//is not already in open list, so add it
					if(call(cur.source, adjacent)(requester, turf_to_check, can_pass_info))
						checked_node = new(turf_to_check, cur, newg, call(turf_to_check, dist)(end, requester), cur.nt + 1, ALL_DIRS^reverse)
						open.insert(checked_node)
						openc[turf_to_check] = checked_node

		cur.bf = 0 // Mark as processed
		CHECK_TICK

	if (path)
		for (var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)

	openc = null
	return path

/turf/proc/reachable_turf_test(requester, turf/target, datum/can_pass_info/pass_info, simulated_only = TRUE, check_z_levels = TRUE)
	if(!target || target.density)
		return FALSE
	if(!target.can_cross_safely(requester)) // dangerous turf! lava or openspace (or others in the future)
		return FALSE
	var/z_distance = abs(target.z - z)
	if(!z_distance) // standard check for same-z pathing
		return !LinkBlockedWithAccess(target, pass_info)
	if(z_distance != 1) // no single movement lets you move more than one z-level at a time (currently; update if this changes)
		return FALSE
/*
	var/obj/structure/stairs/source_stairs = locate(/obj/structure/stairs) in src
	if(T.z < z) // going down
		if(source_stairs?.get_target_loc(REVERSE_DIR(source_stairs.dir)) == T)
			return TRUE
	else // heading DOWN stairs was handled earlier, so now handle going UP stairs
		if(source_stairs?.get_target_loc(source_stairs.dir) == T)
			return TRUE
*/
	return FALSE

/proc/get_dist_3d(atom/source, atom/target)
	var/turf/source_turf = get_turf(source)
	return source_turf.distance_3d(get_turf(target))

// Add a helper function to compute 3D Manhattan distance
/turf/proc/distance_3d(turf/T)
	if (!istype(T))
		return 0
	var/dx = abs(x - T.x)
	var/dy = abs(y - T.y)
	var/dz = abs(z - T.z) * 5 // Weight z-level differences higher
	return (dx + dy + dz)

/*
/turf/proc/LinkBlockedWithAccess(turf/T, requester, ID)
	var/adir = get_dir(src, T)
	var/rdir = ((adir & MASK_ODD)<<1)|((adir & MASK_EVEN)>>1)
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, requester))
			return TRUE
	for(var/obj/O in src)
		if(!O.CanAStarPass(ID, adir, requester))
			return TRUE

	for(var/mob/living/M in T)
		if(!M.CanPass(requester, src))
			return TRUE
	for(var/obj/structure/M in T)
		if(!M.CanPass(requester, src))
			return TRUE
	return FALSE
*/
