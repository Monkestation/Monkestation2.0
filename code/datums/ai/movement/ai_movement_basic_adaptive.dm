/datum/ai_movement/basic_avoidance/adaptive
	/// What we swap to when walking straight gets us stuck
	var/datum/ai_movement/astar/adaptive/fallback_type = /datum/ai_movement/astar/adaptive

// walking straight never gets anyone up the stairs, it just parks us under them, so another floor means A* right away
/datum/ai_movement/basic_avoidance/adaptive/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/atom/old_target = moving_controllers[controller]
	if(!on_same_floor(controller.pawn, current_movement_target))
		forget_target(old_target, controller)
		swap_to_astar(controller)
		controller.ai_movement.start_moving_towards(controller, current_movement_target, min_distance)
		return
	. = ..()
	forget_target(old_target, controller)
	watch_target(current_movement_target)

/datum/ai_movement/basic_avoidance/adaptive/stop_moving_towards(datum/ai_controller/controller)
	var/atom/old_target = moving_controllers[controller]
	. = ..()
	forget_target(old_target)

// get_dist() calls a tile one floor up 1 away, so without this we'd "arrive" right under them
/datum/ai_movement/basic_avoidance/adaptive/close_enough(atom/pawn, atom/target, distance)
	return on_same_floor(pawn, target) && ..()

/datum/ai_movement/basic_avoidance/adaptive/post_move(datum/move_loop/source, succeeded)
	. = ..()
	var/datum/move_loop/has_target/dist_bound/loop = source
	var/datum/ai_controller/controller = source.extra_info
	// the target's covered by on_target_z_changed, this is for us falling down a hole or whatever
	if (!on_same_floor(loop.moving, loop.target))
		swap_to_astar(controller)
		return
	if (succeeded != MOVELOOP_FAILURE)
		return
	if (get_dist(loop.moving, loop.target) <= loop.distance)
		return
	swap_to_astar(controller) // we failed? it's A* time

/datum/ai_movement/basic_avoidance/adaptive/proc/on_same_floor(atom/pawn, atom/target)
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	return pawn_turf?.z == target_turf?.z

/// Hands this controller over to the A* half. The controller starts it moving again on its next tick.
/datum/ai_movement/basic_avoidance/adaptive/proc/swap_to_astar(datum/ai_controller/controller)
	if(moving_controllers[controller])
		stop_moving_towards(controller)
	controller.change_ai_movement_type(fallback_type)

// we're one datum shared by every slime, so one registration covers everyone walking at this target
/datum/ai_movement/basic_avoidance/adaptive/proc/watch_target(atom/target)
	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_z_changed), override = TRUE)

/// Stops watching target, unless someone other than leaving_controller is still headed there.
/datum/ai_movement/basic_avoidance/adaptive/proc/forget_target(atom/target, datum/ai_controller/leaving_controller)
	if(!ismovable(target))
		return
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(controller != leaving_controller && moving_controllers[controller] == target)
			return
	UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)

/datum/ai_movement/basic_avoidance/adaptive/proc/on_target_z_changed(atom/movable/source)
	SIGNAL_HANDLER
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(moving_controllers[controller] == source && !on_same_floor(controller.pawn, source))
			swap_to_astar(controller)

/datum/ai_movement/astar/adaptive
	/// What we swap back to once we've caught up
	var/datum/ai_movement/basic_avoidance/adaptive/walk_type = /datum/ai_movement/basic_avoidance/adaptive

/datum/ai_movement/astar/adaptive/post_move(datum/move_loop/source, succeeded)
	. = ..()
	if (succeeded != MOVELOOP_SUCCESS)
		return
	var/datum/move_loop/has_target/jps/astar/loop = source
	if(length(loop.movement_path))
		return
	var/datum/ai_controller/controller = source.extra_info
	if (QDELETED(controller) || QDELETED(controller.pawn))
		return
	if (loop.target in view(6, controller.pawn))
		stop_moving_towards(controller)
		controller.change_ai_movement_type(walk_type) // we succeeded? it's basic time

/// Following a friend can mean a long trip across floors, so the A* half gets a much longer leash than a chase does
/datum/ai_movement/basic_avoidance/adaptive/follow
	fallback_type = /datum/ai_movement/astar/adaptive/follow

/datum/ai_movement/astar/adaptive/follow
	maximum_length = SLIME_SEEK_PATH_LENGTH
	walk_type = /datum/ai_movement/basic_avoidance/adaptive/follow
