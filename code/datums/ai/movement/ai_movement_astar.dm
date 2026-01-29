// Currently disabled until I can get this working in a less janky way
/*
/**
 * This movement datum represents smarter-pathing
 */
/datum/ai_movement/astar
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH
	var/check_z_levels = TRUE
	var/smooth_diagonals = TRUE

/datum/ai_movement/astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/has_target/astar/loop = SSmove_manager.astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_nodes = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		check_z_levels = check_z_levels,
		smooth_diagonals = smooth_diagonals,
		subsystem = SSai_movement,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/astar/proc/repath_incoming(datum/move_loop/has_target/astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

/datum/ai_movement/astar/bot
	max_pathing_attempts = 25
	maximum_length = 25
	smooth_diagonals = FALSE

/datum/ai_movement/astar/bot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	if(isnull(our_pawn))
		return
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_FINISHED_PATHING, TYPE_PROC_REF(/mob/living/basic/bot, generate_bot_path))

/datum/ai_movement/astar/bot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH
*/
