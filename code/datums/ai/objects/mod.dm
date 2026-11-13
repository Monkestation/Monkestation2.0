/// An AI controller for the MODsuit pathfinder module. It's activated by implant and attaches itself to the user.
/datum/ai_controller/mod
	blackboard = list(
		BB_MOD_TARGET,
		BB_MOD_IMPLANT,
	)
	ai_traits = RUN_WHILE_UNWATCHED | ALWAYS_HIGH_PRIORITY
	behavior_tree_json = "code/datums/ai/objects/mod.bt.json"
	max_target_distance = MOD_AI_RANGE //a little spicy but its one specific item that summons it, and it doesn't run otherwise
	ai_movement = /datum/ai_movement/jps
	///ID card generated from the suit's required access. Used for pathing.
	var/obj/item/card/id/advanced/id_card

/datum/ai_controller/mod/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /obj/item/mod/control))
		return AI_CONTROLLER_INCOMPATIBLE
	var/obj/item/mod/control/mod = new_pawn
	id_card = new /obj/item/card/id/advanced/simple_bot()
	if(length(mod.req_access))
		id_card.set_access(mod.req_access)
	return ..() //Run parent at end

/datum/ai_controller/mod/UnpossessPawn(destroy)
	QDEL_NULL(id_card)
	return ..() //Run parent at end

/datum/ai_controller/mod/get_access()
	return id_card.GetAccess()

/// Puts the suit on its owner once it got next to them.
/datum/bt_node/ai_behavior/mod_attach

/datum/bt_node/ai_behavior/mod_attach/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!controller.pawn.Adjacent(controller.blackboard[BB_MOD_TARGET]))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/obj/item/implant/mod/implant = controller.blackboard[BB_MOD_IMPLANT]
	INVOKE_ASYNC(implant.module, TYPE_PROC_REF(/obj/item/mod/module/pathfinder, attach), controller.blackboard[BB_MOD_TARGET])
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/mod_attach/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		mod_end_recall(controller, TRUE)

/// Ends the recall when the suit couldn't get to its owner.
/datum/bt_node/ai_behavior/mod_give_up

/datum/bt_node/ai_behavior/mod_give_up/perform(seconds_per_tick, datum/ai_controller/controller)
	mod_end_recall(controller, FALSE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Clears the target and ends the recall on the next tick
/proc/mod_end_recall(datum/ai_controller/controller, succeeded)
	controller.clear_blackboard_key(BB_MOD_TARGET)
	var/obj/item/implant/mod/implant = controller.blackboard[BB_MOD_IMPLANT]
	// the recall deletes the controller, so not in the middle of its tick
	addtimer(CALLBACK(implant, TYPE_PROC_REF(/obj/item/implant/mod, end_recall), succeeded), 0)
