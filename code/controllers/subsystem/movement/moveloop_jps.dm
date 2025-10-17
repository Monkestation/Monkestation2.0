/**
 * Used for following jps defined paths. The proc signature here's a bit long, I'm sorry
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * access - A list representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check _DEFINES/movement.dm
 *
**/
/datum/controller/subsystem/move_manager/proc/jps_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	list/access,
	simulated_only,
	turf/avoid,
	skip_first,
	subsystem,
	diagonal_handling,
	priority,
	flags,
	datum/extra_info,
	initial_path)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		access,
		simulated_only,
		avoid,
		skip_first,
		diagonal_handling,
		initial_path)

/datum/move_loop/has_target/jps
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Max amount of steps to search
	var/max_path_length
	///Minimum distance to the target before path returns
	var/minimum_distance
	///A list representing what access we have and what doors we can open.
	var/list/access
	///Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
	var/simulated_only
	///A perticular turf to avoid
	var/turf/avoid
	///Should we skip the first step? This is the tile we're currently on, which breaks some things
	var/skip_first
	///Whether we replace diagonal movements with cardinal movements or follow through with them
	var/diagonal_handling
	///A list for the path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	///Bool used to determine if we're already making a path in JPS. this prevents us from re-pathing while we're already busy.
	var/is_pathing = FALSE
	///Callbacks to invoke once we make a path
	var/list/datum/callback/on_finish_callbacks = list()

/datum/move_loop/has_target/jps/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	. = ..()
	on_finish_callbacks += CALLBACK(src, PROC_REF(on_finish_pathing))

/datum/move_loop/has_target/jps/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/initial_path)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.minimum_distance = minimum_distance
	src.access = access
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	movement_path = initial_path?.Copy()

/datum/move_loop/has_target/jps/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, initial_path)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && access ~= src.access && simulated_only == src.simulated_only && avoid == src.avoid)
		return TRUE
	return FALSE

/datum/move_loop/has_target/jps/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/jps/loop_stopped()
	. = ..()
	movement_path = null

/datum/move_loop/has_target/jps/Destroy()
	avoid = null
	on_finish_callbacks.Cut()
	return ..()

///Tries to calculate a new path for this moveloop.
/datum/move_loop/has_target/jps/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	if(SSpathfinder.pathfind(moving, target, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, on_finish = on_finish_callbacks))
		is_pathing = TRUE
		SEND_SIGNAL(src, COMSIG_MOVELOOP_REPATH)

///Called when a path has finished being created
/datum/move_loop/has_target/jps/proc/on_finish_pathing(list/path)
	movement_path = path
	is_pathing = FALSE
	SEND_SIGNAL(src, COMSIG_MOVELOOP_FINISHED_PATHING, path)

/datum/move_loop/has_target/jps/move()
	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		else
			INVOKE_ASYNC(src, PROC_REF(recalculate_path))
			return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	moving.Move(next_step, get_dir(moving, next_step))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	if(get_turf(moving) == next_step)
		if(length(movement_path))
			movement_path.Cut(1,2)
	else
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE
