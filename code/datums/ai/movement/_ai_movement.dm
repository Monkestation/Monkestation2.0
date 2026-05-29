///This datum is an abstract class that can be overriden for different types of movement
/datum/ai_movement
	///Assoc list ist of controllers that are currently moving as key, and what they are moving to as value
	var/list/moving_controllers = list()
	///How many times a given controller can fail on their route before they just give up
	var/max_pathing_attempts

//Override this to setup the moveloop you want to use
/datum/ai_movement/proc/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)

/datum/ai_movement/proc/stop_moving_towards(datum/ai_controller/controller)
	// We got deleted as we finished an action

/datum/ai_movement/proc/increment_pathing_failures(datum/ai_controller/controller)

/datum/ai_movement/proc/reset_pathing_failures(datum/ai_controller/controller)

///Should the movement be allowed to happen? As of writing this, MOVELOOP_SKIP_STEP is defined as (1<<0) so be careful on using (return TRUE) or (can_move = TRUE; return can_move)
/datum/ai_movement/proc/allowed_to_move(datum/move_loop/source)



	// Check if this controller can actually run, so we don't chase people with corpses

	//Why doesn't this return TRUE or can_move?
	//MOVELOOP_SKIP_STEP is defined as (1<<0) and TRUE are defined as the same "1", returning TRUE would be the equivalent of skipping the move

///Anything to do before moving; any checks if the pawn should be able to move should be placed in allowed_to_move() and called by this proc
/datum/ai_movement/proc/pre_move(datum/move_loop/source)

//Anything to do post movement
/datum/ai_movement/proc/post_move(datum/move_loop/source, succeeded)
