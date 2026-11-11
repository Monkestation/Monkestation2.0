/*
You yourself fought the decadence of Gotham for years with all your strength, all your resources, all your moral authority.
And the only victory you achieved was a lie. Now you understand Gotham is beyond saving, and must be allowed to die.
*/
/datum/ai_controller/bane
	movement_delay = 0.4 SECONDS
	behavior_tree_json = "code/datums/ai/bane/bane.bt.json"
	blackboard = list(BB_BANE_BATMAN = null)

/datum/ai_controller/bane/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/bane/able_to_run()
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()
