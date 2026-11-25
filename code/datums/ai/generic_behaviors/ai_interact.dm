/// Interacts with the atom at target_key once, with optional combat_mode (default FALSE).
/datum/bt_node/ai_behavior/ai_interact
	/// Blackboard key holding the atom to interact with.
	var/target_key
	/// Whether to interact in combat mode.
	var/combat_mode = FALSE
	var/unarmed = FALSE

/datum/bt_node/ai_behavior/ai_interact/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/ai_interact/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(unarmed)
		var/mob/living/living_pawn = controller.pawn
		if(!controller.ai_can_interact(target))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, UnarmedAttack), target, TRUE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), target, combat_mode)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
