/**
 * Makes our pawn go into hiding or come out of it. Returns TRUE if the pawn ends up in the requested state.
 * Hiding needs the pawn to be able to move and to stand on a turf from BB_HIDING_CAN_HIDE_ON.
 */
/datum/ai_controller/proc/set_hiding(now_hiding)
	var/mob/living/basic/hiding_pawn = pawn
	if(!istype(hiding_pawn))
		return FALSE

	if(!blackboard[BB_HIDING_AGGRO_RANGE_NOT_HIDING])
		set_blackboard_key(BB_HIDING_AGGRO_RANGE_NOT_HIDING, blackboard[BB_AGGRO_RANGE])

	if(now_hiding)
		// We can't hide if we can't move properly, or if we don't have any valid hiding locations.
		if(!(hiding_pawn.mobility_flags & MOBILITY_MOVE) || !isturf(hiding_pawn.loc) || hiding_pawn.pulledby || !islist(blackboard[BB_HIDING_CAN_HIDE_ON]))
			return FALSE
		// We can't hide if we don't match the proper turf type we need to hide onto.
		if(!blackboard[BB_HIDING_CAN_HIDE_ON][hiding_pawn.loc.type])
			return FALSE

	if(!!blackboard[BB_HIDING_HIDDEN] == !!now_hiding)
		return TRUE

	set_blackboard_key(BB_HIDING_HIDDEN, now_hiding)
	SEND_SIGNAL(hiding_pawn, COMSIG_MOVABLE_TOGGLE_HIDING, now_hiding, TRUE)

	if(!now_hiding)
		reset_hiding_cooldown()

	set_blackboard_key(BB_AGGRO_RANGE, now_hiding ? (blackboard[BB_HIDING_AGGRO_RANGE] || DEFAULT_HIDING_AGGRO_RANGE) : blackboard[BB_HIDING_AGGRO_RANGE_NOT_HIDING])
	return TRUE

/// Sets how long we have to wait before hiding again, scaled by coefficient.
/datum/ai_controller/proc/reset_hiding_cooldown(coefficient = 1)
	var/cooldown_minimum = blackboard[BB_HIDING_COOLDOWN_MINIMUM] || 1 MINUTES
	var/cooldown_maximum = blackboard[BB_HIDING_COOLDOWN_MAXIMUM] || 3 MINUTES
	set_blackboard_key(BB_HIDING_COOLDOWN_BEFORE_HIDING, world.time + rand(cooldown_minimum, cooldown_maximum) * coefficient)

/// Comes out of hiding when something needs our attention, and makes sure we don't go back into hiding right after.
/datum/bt_node/ai_behavior/stop_hiding

/datum/bt_node/ai_behavior/stop_hiding/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_HIDING_HIDDEN])
		controller.set_hiding(FALSE)
	else if(controller.blackboard[BB_HIDING_COOLDOWN_BEFORE_HIDING] - world.time < (controller.blackboard[BB_HIDING_COOLDOWN_MINIMUM] || 1 MINUTES))
		controller.reset_hiding_cooldown()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// While idle, goes into hiding once the cooldown is up, and randomly comes out of it after a while.
/datum/bt_node/ai_behavior/random_hiding

/datum/bt_node/ai_behavior/random_hiding/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_HIDING_HIDDEN])
		// We can't stop hiding randomly until this cooldown is over.
		if(controller.blackboard[BB_HIDING_COOLDOWN_BEFORE_STOP_HIDING] > world.time)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!SPT_PROB(controller.blackboard[BB_HIDING_RANDOM_STOP_HIDING_CHANCE] || DEFAULT_RANDOM_STOP_HIDING_CHANCE, seconds_per_tick))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		controller.set_hiding(FALSE)
		controller.reset_hiding_cooldown(coefficient = 0.1)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(controller.blackboard[BB_HIDING_COOLDOWN_BEFORE_HIDING] > world.time)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.set_hiding(TRUE))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/cooldown_minimum = controller.blackboard[BB_HIDING_COOLDOWN_MINIMUM] || 1 MINUTES
	var/cooldown_maximum = controller.blackboard[BB_HIDING_COOLDOWN_MAXIMUM] || 3 MINUTES
	controller.set_blackboard_key(BB_HIDING_COOLDOWN_BEFORE_STOP_HIDING, world.time + rand(cooldown_minimum, cooldown_maximum))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Comes out of hiding while we have something to fight. Fits the while_attacking slot of the combat subtrees.
/datum/bt_node/subtree/stop_hiding
	behavior_tree_json = "monkestation/code/modules/map_gen_expansions/ai/behaviours/stop_hiding.bt.json"

/// Randomly hides while idle. Fits the cant_attack slot of the combat subtrees.
/datum/bt_node/subtree/random_hiding
	behavior_tree_json = "monkestation/code/modules/map_gen_expansions/ai/behaviours/random_hiding.bt.json"
