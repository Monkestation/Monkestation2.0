#define ATURF 1
#define TOTAL_COST_F 2
#define DIST_FROM_START_G 3
#define HEURISTIC_H 4
#define PREV_NODE 5
#define NODE_TURN 6
#define BLOCKED_FROM 7  // Available directions to explore FROM this node

#define ALL_DIRS (NORTH|SOUTH|EAST|WEST)

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

#define SORT_TOTAL_COST_F(list) (list[TOTAL_COST_F])

#define PF_TIEBREAKER 0.005
#define MASK_ODD 85
#define MASK_EVEN 170

/datum/pathfind/astar
	/// The movable we are pathing
	var/atom/movable/requester
	/// The turf we're trying to path to.
	var/turf/end
	/// The proc used to calculate the distance used in every A* calculation (length of path and heuristic)
	var/dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d)
	/// The maximum number of nodes the returned path can be (0 = infinite)
	var/maxnodes
	/// The maximum number of nodes to search (default: 30, 0 = infinite)
	var/maxnodedepth
	/// Minimum distance to the target before path returns,
	/// could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
	var/mintargetdist
	/// The proc that returns the turfs to consider around the actually processed node.
	var/adjacent = TYPE_PROC_REF(/turf, reachable_turf_test)
	/// Whether we should do multi-z pathing or not.
	var/check_z_levels
	/// Whether to smooth the path by replacing cardinal turns with diagonals
	var/smooth_diagonals = TRUE
	/// Binary sorted list of nodes (lowest weight at end for easy Pop)
	VAR_PRIVATE/list/open
	/// Turf -> node mapping for nodes in open list
	VAR_PRIVATE/list/openc
	/// turf -> bitmask of blocked directions
	VAR_PRIVATE/list/closed
	VAR_PRIVATE/list/cur
	VAR_PRIVATE/list/path = null

/datum/pathfind/astar/Destroy(force)
	. = ..()
	requester = null
	end = null
	open = null
	openc = null
	closed = null
	cur = null
	path = null
	pass_info = null

/datum/pathfind/astar/proc/setup(atom/requester, atom/end, dist = TYPE_PROC_REF(/turf, heuristic_cardinal_3d), maxnodes, maxnodedepth = 30, mintargetdist, adjacent = TYPE_PROC_REF(/turf, reachable_turf_test), list/access = list(), turf/exclude, simulated_only = TRUE, check_z_levels = TRUE, smooth_diagonals = TRUE, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(end)
	src.dist = dist
	src.maxnodes = maxnodes
	src.maxnodedepth = maxnodes || maxnodedepth
	src.mintargetdist = mintargetdist
	src.adjacent = adjacent
	src.avoid = exclude
	src.simulated_only = simulated_only
	src.pass_info = new(requester, access, multiz_checks = check_z_levels)
	src.check_z_levels = check_z_levels
	src.smooth_diagonals = smooth_diagonals
	src.on_finish = on_finish

/datum/pathfind/astar/start()
	start = get_turf(requester)
	. = ..()
	if(!.)
		return .
	if (!start || !end)
		. = FALSE
		CRASH("Invalid A* start or destination")
	if (start == end)
		return FALSE
	if (maxnodes && start.distance_3d(end) > maxnodes)
		return FALSE

	open = list()
	openc = new()
	closed = new()

	cur = ASTAR_NODE(start, 0, start.distance_3d(end), null, 0, ALL_DIRS)
	var/list/insert_item = list(cur)
	BINARY_INSERT_DEFINE_REVERSE(insert_item, open, SORT_VAR_NO_TYPE, cur, SORT_TOTAL_COST_F, COMPARE_KEY)
	openc[start] = cur

	return TRUE

/datum/pathfind/astar/search_step()
	. = ..()
	if(!.)
		return .
	if(QDELETED(requester))
		return FALSE

	var/dist = src.dist
	var/adjacent = src.adjacent
	var/maxnodedepth = src.maxnodedepth
	var/list/open = src.open
	var/list/openc = src.openc
	var/list/closed = src.closed
	var/turf/exclude = src.avoid
	var/datum/can_pass_info/can_pass_info = src.pass_info
	var/check_z_levels = src.check_z_levels
	var/atom/movable/our_movable

	while (requester && length(open) && !path)
		// Pop from end (highest priority in reverse sorted list)
		src.cur = open[length(open)]
		var/list/cur = src.cur
		open.len--

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

		if(maxnodedepth && (cur[NODE_TURN] > maxnodedepth))
			if(TICK_CHECK)
				return TRUE
			continue

		for(var/dir_to_check in GLOB.cardinals)
			if(!(cur[BLOCKED_FROM] & dir_to_check))
				continue

			var/turf/T = get_step(cur_turf, dir_to_check)

			if(isopenspaceturf(cur_turf))
				if(isnull(our_movable))
					our_movable = can_pass_info.caller_ref?.resolve() || FALSE
				if(our_movable && our_movable.can_z_move(DOWN, cur_turf, null, ZMOVE_FALL_FLAGS)) // don't use ?. as this can be false if it fails to resolve for some reason
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

			if(!call(cur_turf, adjacent)(requester, T, can_pass_info))
				closed[T] |= reverse
				continue

			var/list/CN = openc[T]
			var/newg = cur[DIST_FROM_START_G] + call(cur_turf, dist)(T, requester)

			if(CN)
				// Already in open list, check if this is a better path
				if(newg < CN[DIST_FROM_START_G])
					// Remove old instance
					var/list/old_item = list(CN)
					open -= old_item

					// Update node
					ASTAR_UPDATE_NODE(CN, cur, newg, CN[HEURISTIC_H], cur[NODE_TURN] + 1)

					// Re-insert with new priority
					var/list/new_item = list(CN)
					BINARY_INSERT_DEFINE_REVERSE(new_item, open, SORT_VAR_NO_TYPE, CN, SORT_TOTAL_COST_F, COMPARE_KEY)
			else
				// Not in open list, create new node
				CN = ASTAR_NODE(T, newg, call(T, dist)(end, requester), cur, cur[NODE_TURN] + 1, ALL_DIRS^reverse)
				var/list/new_item = list(CN)
				BINARY_INSERT_DEFINE_REVERSE(new_item, open, SORT_VAR_NO_TYPE, CN, SORT_TOTAL_COST_F, COMPARE_KEY)
				openc[T] = CN

		if(TICK_CHECK)
			return TRUE

	return TRUE

/datum/pathfind/astar/finished()
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)

		if(smooth_diagonals)
			path = smooth_path_diagonals(path)

	hand_back(path)
	openc = null
	closed = null
	return ..()

/datum/pathfind/astar/proc/smooth_path_diagonals(list/input_path)
	if(!input_path || length(input_path) < 3)
		return input_path

	var/list/smoothed = list()
	var/i = 1

	while(i <= length(input_path))
		var/turf/current = input_path[i]
		smoothed += current

		// need at least 2 more turfs to check for smoothing
		if(i + 2 > length(input_path))
			i++
			continue

		var/turf/next = input_path[i + 1]
		var/turf/after_next = input_path[i + 2]

		var/dir1 = get_dir(current, next)
		var/dir2 = get_dir(next, after_next)

		//if card and perp hen attempt to see if diagonal possible
		if(!ISDIAGONALDIR(dir1) && !ISDIAGONALDIR(dir2) && dir1 != dir2 && dir1 != REVERSE_DIR(dir2))
			var/diagonal_dir = dir1 | dir2
			var/turf/diagonal_target = get_step(current, diagonal_dir)
			if(diagonal_target == after_next)
				if(can_move_diagonal(current, after_next, pass_info))
					i += 2
					continue

		i++

	return smoothed

/datum/pathfind/astar/proc/can_move_diagonal(turf/from, turf/end, datum/can_pass_info/pass_info)
	if(!from || !end)
		return FALSE

	var/diagonal_dir = get_dir(from, end)
	if(!ISDIAGONALDIR(diagonal_dir))
		return FALSE

	var/dir1 = diagonal_dir & 3
	var/dir2 = diagonal_dir & 12

	var/turf/intermediate1 = get_step(from, dir1)
	var/turf/intermediate2 = get_step(from, dir2)

	if(intermediate1 && !intermediate1.density && call(from, adjacent)(requester, intermediate1, pass_info))
		if(call(intermediate1, adjacent)(requester, end, pass_info))
			return TRUE

	if(intermediate2 && !intermediate2.density && call(from, adjacent)(requester, intermediate2, pass_info))
		if(call(intermediate2, adjacent)(requester, end, pass_info))
			return TRUE

	return FALSE

/proc/heap_path_weight_compare_astar(list/a, list/b)
	return b[TOTAL_COST_F] - a[TOTAL_COST_F]

/turf/proc/reachable_turf_test(requester, turf/target, datum/can_pass_info/pass_info)
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
#undef ALL_DIRS
#undef ASTAR_NODE
#undef ASTAR_UPDATE_NODE
#undef ASTAR_CLOSE_ENOUGH_TO_END
#undef SORT_TOTAL_COST_F
