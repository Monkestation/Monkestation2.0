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
#define ATURF 1
#define TOTAL_COST_F 2
#define DIST_FROM_START_G 3
#define HEURISTIC_H 4
#define PREV_NODE 5
#define NODE_TURN 6
#define BLOCKED_FROM 7  // Available directions to explore FROM this node

#define ASTAR_NODE(turf, dist_from_start, heuristic, prev_node, node_turn, blocked_from) \
	list(turf, (dist_from_start + heuristic * (1 + PF_TIEBREAKER)), dist_from_start, heuristic, prev_node, node_turn, blocked_from)

#define ASTAR_UPDATE_NODE(node, new_prev, new_g, new_h, new_nt) \
	node[PREV_NODE] = new_prev; \
	node[DIST_FROM_START_G] = new_g; \
	node[HEURISTIC_H] = new_h; \
	node[TOTAL_COST_F] = new_g + new_h * (1 + PF_TIEBREAKER); \
	node[NODE_TURN] = new_nt

#define ASTAR_CLOSE_ENOUGH_TO_END(end, checking_turf, mintargetdist) \
	(checking_turf == end || (mintargetdist && (get_dist_3d(checking_turf, end) <= mintargetdist)))

#define PF_TIEBREAKER 0.005
#define MASK_ODD 85
#define MASK_EVEN 170

/proc/path_weight_compare_astar(list/a, list/b)
	return a[TOTAL_COST_F] - b[TOTAL_COST_F]

/proc/heap_path_weight_compare_astar(list/a, list/b)
	return b[TOTAL_COST_F] - a[TOTAL_COST_F]

/proc/get_astar_path_to(requester, end, dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d), maxnodes, maxnodedepth = 30, mintargetdist, adjacent = TYPE_PROC_REF(/turf, reachable_turf_test), list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE)
	var/l = SSastar.mobs.getfree(requester)
	while (!l)
		stoplag(3)
		l = SSastar.mobs.getfree(requester)
	var/list/path = astar(requester, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent, access, exclude, simulated_only, check_z_levels)
	SSastar.mobs.found(l)
	if (!path)
		path = list()
	return path

/proc/astar(requester, _end, dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d), maxnodes, maxnodedepth = 30, mintargetdist, adjacent = TYPE_PROC_REF(/turf, reachable_turf_test), list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE)
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

	var/datum/can_pass_info/can_pass_info = new(requester, access, multiz_checks = check_z_levels)
	var/datum/heap/open = new /datum/heap(GLOBAL_PROC_REF(heap_path_weight_compare_astar))
	var/list/openc = new()  // turf -> node mapping for nodes in open list
	var/list/closed = new()  // turf -> bitmask of blocked directions
	var/list/path = null
	var/const/ALL_DIRS = NORTH|SOUTH|EAST|WEST

	// Create initial node using macro
	var/list/cur = ASTAR_NODE(start, 0, start.distance_3d(end), null, 0, ALL_DIRS)
	open.insert(cur)
	openc[start] = cur

	while (requester && !open.is_empty() && !path)
		cur = open.pop()
		var/turf/cur_turf = cur[ATURF]
		openc -= cur_turf
		closed[cur_turf] = ALL_DIRS

		// Destination check - must be exact match or valid closeenough on same Z-level
		var/is_destination = (cur_turf == end)
		// Only consider "close enough" if on the same Z-level
		var/closeenough = FALSE
		if (!check_z_levels || cur_turf.z == end.z)
			if (mintargetdist)
				closeenough = cur_turf.distance_3d(end) <= mintargetdist
			else
				closeenough = cur_turf.distance_3d(end) < 1

		if (is_destination || closeenough)
			path = list(cur_turf)
			var/list/prev = cur[PREV_NODE]
			while (prev)
				path.Add(prev[ATURF])
				prev = prev[PREV_NODE]
			break

		if(maxnodedepth && (cur[NODE_TURN] > maxnodedepth))  // if too many steps, don't process that path
			CHECK_TICK
			continue

		for(var/dir_to_check in GLOB.cardinals)
			if(!(cur[BLOCKED_FROM] & dir_to_check))  // we can't proceed in this direction
				continue

			// get the turf we end up at if we move in dir_to_check; this may have special handling for multiz moves
			var/turf/T = get_step(cur_turf, dir_to_check)

			if(isopenspaceturf(cur_turf))
				var/turf/turf_below = GET_TURF_BELOW(cur_turf)
				if(turf_below)
					T = turf_below
			else
				var/obj/structure/stairs/stairs = locate() in cur_turf
				if(stairs?.isTerminator() && stairs.dir == dir_to_check)
					var/turf/stairs_destination = get_step_multiz(cur_turf, dir_to_check | UP)
					if(stairs_destination)
						T = stairs_destination

			if(!T || T == exclude)
				continue

			var/reverse = REVERSE_DIR(dir_to_check)

			if(closed[T] & reverse)
				continue

			// check if not valid
			if(!call(cur_turf, adjacent)(requester, T, can_pass_info))
				closed[T] |= reverse
				continue

			var/list/CN = openc[T]  // current checking node
			var/newg = cur[DIST_FROM_START_G] + call(cur_turf, dist)(T, requester)  // add the travel distance between these two tiles to the distance so far

			if(CN)
				// is already in open list, check if it's a better way from the current turf
				if(newg < CN[DIST_FROM_START_G])
					ASTAR_UPDATE_NODE(CN, cur, newg, CN[HEURISTIC_H], cur[NODE_TURN] + 1)
					open.resort(CN)  // reorder the changed element in the list
			else
				// is not already in open list, so add it
				CN = ASTAR_NODE(T, newg, call(T, dist)(end, requester), cur, cur[NODE_TURN] + 1, ALL_DIRS^reverse)
				open.insert(CN)
				openc[T] = CN

		CHECK_TICK

	if (path)
		for (var/i = 1 to round(0.5 * path.len))
			path.Swap(i, path.len - i + 1)

	openc = null
	closed = null
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
	if(target.z > z) // going up stairs
		var/obj/structure/stairs/stairs = locate() in src
		if(stairs?.isTerminator() && target == get_step_multiz(src, stairs.dir | UP))
			return TRUE
	else if(isopenspaceturf(src)) // going down stairs
		var/turf/turf_below = GET_TURF_BELOW(src)
		if(!turf_below || target != turf_below)
			return FALSE
		var/obj/structure/stairs/stairs_below = locate() in turf_below
		if(stairs_below?.isTerminator())
			return TRUE
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


#undef ATURF
#undef TOTAL_COST_F
#undef DIST_FROM_START_G
#undef HEURISTIC_H
#undef PREV_NODE
#undef NODE_TURN
#undef BLOCKED_FROM
#undef ASTAR_NODE
#undef ASTAR_UPDATE_NODE
#undef ASTAR_CLOSE_ENOUGH_TO_END
