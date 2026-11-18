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

/datum/ai_controller/bane/get_able_to_run()
	var/mob/living/living_pawn = pawn
	if(living_pawn.stat)
		return AI_UNABLE_TO_RUN
	return ..()

/// There's no signal for incapacitation changes, so it gets checked every tick instead
/datum/ai_controller/bane/SelectBehaviors(seconds_per_tick)
	var/mob/living/living_pawn = pawn
	if(living_pawn.incapacitated())
		return
	return ..()
