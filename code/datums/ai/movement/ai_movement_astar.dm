/**
 * Smart-pathing that can change z-levels, by stairs and by dropping through open space
 */
/datum/ai_movement/astar
	max_pathing_attempts = 20
	/// Longest path we'll search for, in steps
	var/maximum_length = AI_MAX_PATH_LENGTH

/datum/ai_movement/astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay
	var/list/found_path = controller.blackboard[BB_PATH_TO_USE]
	controller.clear_blackboard_key(BB_PATH_TO_USE)
	if(LAZYACCESS(found_path, length(found_path)) != get_turf(current_movement_target))
		found_path = null

	var/datum/move_loop/has_target/jps/astar/loop = GLOB.move_manager.astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		initial_path = found_path,
		subsystem = SSai_movement,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_REPATH, PROC_REF(repath_incoming))

	return loop

// get_dist() calls a tile one floor up 1 away, so without this we'd "arrive" on the top step and never climb
/datum/ai_movement/astar/close_enough(atom/pawn, atom/target, distance)
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	return pawn_turf?.z == target_turf?.z && ..()

/datum/ai_movement/astar/proc/repath_incoming(datum/move_loop/has_target/jps/astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()
