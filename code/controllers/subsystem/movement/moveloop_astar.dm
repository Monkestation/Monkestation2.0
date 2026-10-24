/**
 * Like jps_move(), but follows A* paths, which go up stairs and down open space
 *
 * Returns TRUE if the loop successfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * minimum_distance -Minimum distance to the target before path returns
 * access - A list representing what access we have and what doors we can open
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/move_manager/proc/astar_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	list/access,
	subsystem,
	priority,
	flags,
	datum/extra_info)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps/astar,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		access)

/// Reuses all of the JPS loop's path bookkeeping, only the pathfinder and the stepping are different.
/datum/move_loop/has_target/jps/astar
	/// Where the target was when we last asked for a path, so we notice when it wanders off
	var/turf/pathed_to
	/// Failed steps in a row on the same path node
	var/blocked_steps = 0

/datum/move_loop/has_target/jps/astar/Destroy()
	pathed_to = null
	return ..()

/// Asks for a new path. avoid_turf is left out of it, for getting around whatever's blocking us.
/datum/move_loop/has_target/jps/astar/recalculate_path(turf/avoid_turf)
	if(is_pathing || !COOLDOWN_FINISHED(src, repath_cooldown))
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	avoid = avoid_turf
	if(SSpathfinder.astar_pathfind(moving, target, max_path_length, minimum_distance, access, avoid, on_finish = on_finish_callbacks))
		is_pathing = TRUE
		pathed_to = get_turf(target)
		SEND_SIGNAL(src, COMSIG_MOVELOOP_REPATH)

/datum/move_loop/has_target/jps/astar/on_finish_pathing(list/path)
	// the path starts where we asked from, and we kept walking the old one while A* thought about it
	if(length(path) && moving)
		var/current_index = path.Find(get_turf(moving))
		if(!current_index)
			return ..(null)
		path.Cut(1, current_index + 1)
	return ..()

/datum/move_loop/has_target/jps/astar/move()
	if(!is_pathing && get_turf(target) != pathed_to)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/turf/old_turf = get_turf(moving)
	// stairs only lift you when you walk off the top step, so a step up is a flat step that way
	var/turf/flat_step = next_step.z == old_turf.z ? next_step : locate(next_step.x, next_step.y, old_turf.z)
	if(get_dist(old_turf, flat_step) > 1)
		movement_path = null
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE
	moving.Move(flat_step, get_dir(moving, flat_step))
	if(QDELETED(moving))
		return MOVELOOP_FAILURE

	// don't trust Move()'s return: climbing stairs "fails" the move and lifts you anyway,
	// and walking onto open space drops you straight onto the node after it
	var/turf/new_turf = get_turf(moving)
	var/reached_index = movement_path.Find(new_turf, 1, min(length(movement_path), 2) + 1)
	if(reached_index)
		movement_path.Cut(1, reached_index + 1)
		blocked_steps = 0
		return MOVELOOP_SUCCESS

	if(new_turf != old_turf)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE

	// whoever's in the way usually moves on their own, so give them a step before pathing around them
	blocked_steps++
	if(blocked_steps >= 2)
		blocked_steps = 0
		INVOKE_ASYNC(src, PROC_REF(recalculate_path), next_step)
	return MOVELOOP_FAILURE
