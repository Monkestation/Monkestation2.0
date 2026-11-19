/**
 * This movement datum follows paths produced by navmap A*.
 */
/datum/ai_movement/navmap_astar
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH
	var/allow_multiz = FALSE
	///how we deal with diagonal movement, whether we try to avoid them or follow through with them
	var/diagonal_flags = DIAGONAL_REMOVE_CLUNKY
	/// Replan whenever the target leaves the turf we planned to, instead of only once the old path runs out
	var/update_movement_for_moving_target = FALSE
	/// Terrain cost multipliers for every path this plans, see NAV_COST_* in code/__DEFINES/navmap.dm
	var/alist/nav_cost_modifiers

/datum/ai_movement/navmap_astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/loop = setup_moveloop(controller, current_movement_target, moving, delay, min_distance)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_NAVMAP_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/navmap_astar/proc/setup_moveloop(datum/ai_controller/controller, atom/current_movement_target, atom/movable/moving, delay, min_distance)
	var/list/found_path = controller.blackboard[BB_PATH_TO_USE]
	var/list/found_actions = controller.blackboard[BB_PATH_ACTIONS_TO_USE]
	controller.clear_blackboard_key(BB_PATH_TO_USE)
	controller.clear_blackboard_key(BB_PATH_ACTIONS_TO_USE)
	if(LAZYACCESS(found_path, length(found_path)) != get_turf(current_movement_target))
		found_path = null
		found_actions = null
	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.navmap_astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		simulated_only = !HAS_TRAIT(controller.pawn, TRAIT_SPACEWALK),
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		subsystem = SSai_movement,
		skip_first = TRUE,
		diagonal_handling = diagonal_flags,
		allow_multiz = allow_multiz,
		max_path_cost = allow_multiz ? maximum_length * 10 : 0,
		extra_info = controller,
		initial_path = found_path,
		initial_actions = found_actions,
		nav_cost_modifiers = nav_cost_modifiers,
	)
	return loop

/datum/ai_movement/navmap_astar/pre_move(datum/move_loop/has_target/navmap_astar/source)
	. = ..()
	if(. || !update_movement_for_moving_target)
		return
	if(!source.is_pathing && !source.is_link_traversing && get_turf(source.target) != source.pathed_to)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/datum/move_loop/has_target/navmap_astar, recalculate_path))

// get_dist() calls a tile one floor up 1 away, so without this we'd "arrive" on the top step and never climb
/datum/ai_movement/navmap_astar/close_enough(atom/pawn, atom/target, distance)
	if(!allow_multiz)
		return ..()
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	return pawn_turf?.z == target_turf?.z && ..()

/datum/ai_movement/navmap_astar/proc/repath_incoming(datum/move_loop/has_target/navmap_astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

/datum/ai_movement/navmap_astar/bot
	max_pathing_attempts = 8
	maximum_length = 25
	diagonal_flags = DIAGONAL_REMOVE_ALL
	allow_multiz = TRUE

/datum/ai_movement/navmap_astar/bot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	if(isnull(our_pawn))
		return null
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_NAVMAP_FINISHED_PATHING, TYPE_PROC_REF(/mob/living/basic/bot, generate_bot_path))
	return loop

/datum/ai_movement/navmap_astar/bot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH
