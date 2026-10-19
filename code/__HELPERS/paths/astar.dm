#define ATURF 1
#define TOTAL_COST_F 2
#define DIST_FROM_START_G 3
#define HEURISTIC_H 4
#define PREV_NODE 5
#define NODE_TURN 6
#define BLOCKED_FROM 7 // despite the name, this is the dirs still left to try from this node
#define SLOWDOWN 8 // cached get_heuristic_slowdown(), so it's only worked out once per turf

#define ALL_DIRS (NORTH|SOUTH|EAST|WEST)

/// The lowest weight A* gives a turf: plain floor in a hallway.
/// A*'s distance guess assumes every step costs at least this on both ends, so anything lighter is raised to it.
#define ASTAR_MIN_TURF_WEIGHT (/turf::astar_weight + /area/station/hallway::astar_weight)

/// A turf's get_heuristic_slowdown() as A* counts it: never under ASTAR_MIN_TURF_WEIGHT, and a whole number,
/// because a node's total cost is its index in the open list.
#define ASTAR_TURF_WEIGHT(turf) (round(max(turf.get_heuristic_slowdown(), ASTAR_MIN_TURF_WEIGHT), 1))

#define ASTAR_NODE(turf, dist_from_start, heuristic, prev_node, node_turn, blocked_from, slowdown) \
	list(turf, (dist_from_start + heuristic), dist_from_start, heuristic, prev_node, node_turn, blocked_from, slowdown)

#define ASTAR_STEP_COST(from, to, from_slowdown, to_slowdown) \
	(abs(from.x - to.x) + abs(from.y - to.y) + from_slowdown + to_slowdown + abs(from.z - to.z) * 5)

/// Lower bound on the cost to get within mintargetdist of the goal: every tile of distance is a step paying at least
/// ASTAR_MIN_TURF_WEIGHT on both ends. Counting the weights here is what stops A* from flooding everything in range.
/// PF_TIEBREAKER is multiplied in here and the result rounded, so total costs stay whole numbers.
#define ASTAR_HEURISTIC(from, to, mintargetdist) \
	(round(max(0, (1 + 2 * ASTAR_MIN_TURF_WEIGHT) * (abs(from.x - to.x) + abs(from.y - to.y) - mintargetdist) + abs(from.z - to.z) * 5) * (1 + PF_TIEBREAKER), 1))

#define ASTAR_OPEN_INSERT(open, cursor, count, node) \
	do { \
		var/__idx = node[TOTAL_COST_F] + 1; \
		if(__idx > length(open)) { \
			open.len = __idx * 2; \
		}; \
		var/list/__bucket = open[__idx]; \
		if(__bucket) { \
			__bucket[++__bucket.len] = node; \
		} else { \
			open[__idx] = list(node); \
		}; \
		if(__idx < cursor) { \
			cursor = __idx; \
		}; \
		count++; \
	} while(FALSE)

#define PF_TIEBREAKER 0.005

/datum/pathfind/astar
	/// The movable we are pathing
	var/atom/movable/requester
	/// The turf we're trying to path to.
	var/turf/end
	/// Minimum distance to the target before path returns,
	/// could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
	var/mintargetdist
	/// Whether we should do multi-z pathing or not.
	var/check_z_levels
	/// Whether to smooth the path by replacing cardinal turns with diagonals
	var/smooth_diagonals = TRUE
	/// Bucket queue of nodes: open[cost + 1] is a list of every queued node with that total cost.
	/// Can hold stale copies of a node that later found a better path; openc points at the live one.
	VAR_PRIVATE/list/open
	/// Index into open. No bucket below it holds a node.
	VAR_PRIVATE/open_cursor = 1
	/// How many nodes are in open, stale copies included.
	VAR_PRIVATE/open_count = 0
	/// Turf -> node mapping for nodes in open list
	VAR_PRIVATE/alist/openc
	/// turf -> bitmask of blocked directions
	VAR_PRIVATE/alist/closed
	VAR_PRIVATE/list/path = null

/datum/pathfind/astar/Destroy(force)
	. = ..()
	requester = null
	end = null
	open = null
	openc = null
	closed = null
	path = null
	pass_info = null

/datum/pathfind/astar/proc/setup(atom/requester, atom/end, max_distance = 30, mintargetdist, list/access = list(), turf/exclude, check_z_levels = TRUE, smooth_diagonals = TRUE, list/datum/callback/on_finish)
	src.requester = requester
	src.end = get_turf(end)
	src.max_distance = max_distance
	src.mintargetdist = mintargetdist
	src.avoid = exclude
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
	if (max_distance && start.distance_3d(end) > max_distance)
		return FALSE

	open = list()
	openc = alist()
	closed = alist()

	var/list/start_node = ASTAR_NODE(start, 0, ASTAR_HEURISTIC(start, end, mintargetdist), null, 0, ALL_DIRS, ASTAR_TURF_WEIGHT(start))
	open_cursor = start_node[TOTAL_COST_F] + 1
	ASTAR_OPEN_INSERT(open, open_cursor, open_count, start_node)
	openc[start] = start_node

	return TRUE

/datum/pathfind/astar/search_step()
	. = ..()
	if(!.)
		return .
	if(QDELETED(requester))
		return FALSE

	var/max_distance = src.max_distance
	var/mintargetdist = src.mintargetdist
	var/list/open = src.open
	var/open_cursor = src.open_cursor
	var/open_count = src.open_count
	var/alist/openc = src.openc
	var/alist/closed = src.closed
	var/turf/end = src.end
	var/turf/exclude = src.avoid
	var/datum/can_pass_info/can_pass_info = src.pass_info
	var/check_z_levels = src.check_z_levels
	var/list/multiz_levels = SSmapping.multiz_levels
	var/list/cardinals = GLOB.cardinals
	var/atom/movable/our_movable

	while (requester && open_count && !path)
		var/list/bucket = open[open_cursor]
		while(!length(bucket))
			bucket = open[++open_cursor]
		var/list/cur = bucket[length(bucket)]
		bucket.len--
		open_count--

		var/turf/cur_turf = cur[ATURF]
		if(openc[cur_turf] != cur) // stale copy, a better one went in after it
			continue
		openc -= cur_turf
		closed[cur_turf] = ALL_DIRS

		if (cur_turf == end || (mintargetdist && cur_turf.z == end.z && (abs(cur_turf.x - end.x) + abs(cur_turf.y - end.y) <= mintargetdist)))
			path = list(cur_turf)
			var/list/prev = cur[PREV_NODE]
			while (prev)
				path.Add(prev[ATURF])
				prev = prev[PREV_NODE]
			break

		if(max_distance && (cur[NODE_TURN] >= max_distance))
			if(TICK_CHECK)
				break
			continue

		// none of this cares which way we're stepping, so do it once per node, not per neighbor
		var/turf/fall_turf
		var/obj/structure/stairs/stairs
		if(check_z_levels)
			if(isopenspaceturf(cur_turf))
				if(isnull(our_movable))
					our_movable = can_pass_info.caller_ref?.resolve() || FALSE
				if(our_movable && our_movable.can_z_move(DOWN, cur_turf, null, ZMOVE_FALL_FLAGS)) // no ?. here, our_movable is FALSE (not null) when the weakref fails to resolve
					fall_turf = GET_TURF_BELOW(cur_turf)
			else if(multiz_levels[cur_turf.z][Z_LEVEL_UP])
				stairs = locate() in cur_turf

		var/cur_slowdown = cur[SLOWDOWN]
		var/cur_g = cur[DIST_FROM_START_G]
		var/next_turn = cur[NODE_TURN] + 1

		if(fall_turf)
			if(fall_turf != exclude && closed[fall_turf] != ALL_DIRS)
				var/list/landing = openc[fall_turf]
				var/landing_slowdown = landing ? landing[SLOWDOWN] : ASTAR_TURF_WEIGHT(fall_turf)
				var/landing_g = cur_g + ASTAR_STEP_COST(cur_turf, fall_turf, cur_slowdown, landing_slowdown)
				if((!landing || landing_g < landing[DIST_FROM_START_G]) && cur_turf.reachable_turf_test(requester, fall_turf, can_pass_info))
					// a fall isn't a step in any of the four dirs, so the landing turf gets all of them
					landing = ASTAR_NODE(fall_turf, landing_g, ASTAR_HEURISTIC(fall_turf, end, mintargetdist), cur, next_turn, ALL_DIRS, landing_slowdown)
					ASTAR_OPEN_INSERT(open, open_cursor, open_count, landing)
					openc[fall_turf] = landing
			if(TICK_CHECK)
				break
			continue

		var/dirs_left = cur[BLOCKED_FROM]
		for(var/dir_to_check in cardinals)
			if(!(dirs_left & dir_to_check))
				continue

			var/turf/T
			if(stairs?.dir == dir_to_check && stairs.isTerminator())
				T = get_step_multiz(cur_turf, dir_to_check | UP) || get_step(cur_turf, dir_to_check)
			else
				T = get_step(cur_turf, dir_to_check)

			if(!T || T == exclude)
				continue

			var/reverse = REVERSE_DIR(dir_to_check)
			if(closed[T] & reverse)
				continue

			// dense is dense from every side, so mark it done now
			if(T.density)
				closed[T] = ALL_DIRS
				continue

			var/list/CN = openc[T]
			var/newg
			if(CN)
				newg = cur_g + ASTAR_STEP_COST(cur_turf, T, cur_slowdown, CN[SLOWDOWN])
				if(newg >= CN[DIST_FROM_START_G])
					continue

			var/reachable
			if(T.z == cur_turf.z)
				reachable = T.can_cross_safely(requester) && !cur_turf.LinkBlockedWithAccess(T, can_pass_info)
			else
				reachable = cur_turf.reachable_turf_test(requester, T, can_pass_info)
			if(!reachable)
				closed[T] |= reverse
				continue

			if(CN)
				// the old copy stays in open and gets skipped when popped, digging it out of the bucket costs more
				var/list/better = ASTAR_NODE(T, newg, CN[HEURISTIC_H], cur, next_turn, CN[BLOCKED_FROM], CN[SLOWDOWN])
				ASTAR_OPEN_INSERT(open, open_cursor, open_count, better)
				openc[T] = better
				continue

			var/t_slowdown = ASTAR_TURF_WEIGHT(T)
			newg = cur_g + ASTAR_STEP_COST(cur_turf, T, cur_slowdown, t_slowdown)
			CN = ASTAR_NODE(T, newg, ASTAR_HEURISTIC(T, end, mintargetdist), cur, next_turn, ALL_DIRS^reverse, t_slowdown)
			ASTAR_OPEN_INSERT(open, open_cursor, open_count, CN)
			openc[T] = CN

		if(TICK_CHECK)
			break

	src.open_cursor = open_cursor
	src.open_count = open_count
	return TRUE

/datum/pathfind/astar/finished()
	if(path)
		reverse_range(path)

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

		if(i + 2 > length(input_path))
			i++
			continue

		var/turf/next = input_path[i + 1]
		var/turf/after_next = input_path[i + 2]

		var/dir1 = get_dir(current, next)
		var/dir2 = get_dir(next, after_next)

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

	if(intermediate1 && !intermediate1.density && from.reachable_turf_test(requester, intermediate1, pass_info))
		if(intermediate1.reachable_turf_test(requester, end, pass_info))
			return TRUE

	if(intermediate2 && !intermediate2.density && from.reachable_turf_test(requester, intermediate2, pass_info))
		if(intermediate2.reachable_turf_test(requester, end, pass_info))
			return TRUE

	return FALSE

/turf/proc/reachable_turf_test(atom/movable/requester, turf/target, datum/can_pass_info/pass_info)
	if(!target || target.density)
		return FALSE
	if(!target.can_cross_safely(requester)) // lava, openspace, etc
		return FALSE
	var/z_distance = abs(target.z - z)
	if(!z_distance)
		return !LinkBlockedWithAccess(target, pass_info)
	if(z_distance != 1) // nothing moves more than one z-level at a time
		return FALSE
	if(target.z > z)
		var/obj/structure/stairs/stairs = locate() in src
		if(stairs?.isTerminator() && target == get_step_multiz(src, stairs.dir | UP))
			// same two checks stair_ascend does before it moves anyone
			return requester.can_z_move(UP, src, null, ZMOVE_ALLOW_BUCKLED) && !requester.can_z_move(DOWN, target, null, ZMOVE_FALL_FLAGS)
	else if(isopenspaceturf(src))
		var/turf/turf_below = GET_TURF_BELOW(src)
		if(!turf_below || target != turf_below)
			return FALSE
		var/obj/structure/stairs/stairs_below = locate() in turf_below
		if(stairs_below?.isTerminator())
			return TRUE
	return FALSE

/turf/proc/distance_3d(turf/T)
	if (!istype(T))
		return 0
	var/dx = abs(x - T.x)
	var/dy = abs(y - T.y)
	var/dz = abs(z - T.z) * 5
	return (dx + dy + dz)

#undef ATURF
#undef TOTAL_COST_F
#undef DIST_FROM_START_G
#undef HEURISTIC_H
#undef PREV_NODE
#undef NODE_TURN
#undef BLOCKED_FROM
#undef SLOWDOWN
#undef ALL_DIRS
#undef ASTAR_MIN_TURF_WEIGHT
#undef ASTAR_TURF_WEIGHT
#undef ASTAR_NODE
#undef ASTAR_STEP_COST
#undef ASTAR_HEURISTIC
#undef ASTAR_OPEN_INSERT
#undef PF_TIEBREAKER
