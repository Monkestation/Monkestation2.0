/datum/control
	var/name = "controlling something else"
	var/mob/controller
	var/atom/movable/controlled
	var/control_flags = 0
	var/is_controlled = FALSE //Whether we're in strict control

/datum/control/New(mob/new_controller, atom/new_controlled)
	..()
	controller = new_controller
	RegisterSignal(new_controller, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(user_damaged))
	controlled = new_controlled

/datum/control/Destroy()
	break_control()
	if(controller)
		controller.control_object = null
		controller = null
	controlled = null
	..()

/datum/control/proc/user_damaged(datum/soruce, amount, kind)
	if(amount > 0 && control_flags & REVERT_ON_CONTROLLER_DAMAGED)
		break_control()

/datum/control/proc/break_control()
	if(controller && controller.client)
		controller.client.eye = controller.client.mob
		controller.client.perspective = MOB_PERSPECTIVE
		is_controlled = FALSE
		if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
			REMOVE_TRAIT(controller, TRAIT_IMMOBILIZED, REF(src))

/datum/control/proc/take_control()
	if(!is_valid(0))
		return
	if(control_flags & LOCK_EYE_TO_CONTROLLED)
		controller.client.perspective = EYE_PERSPECTIVE
		controller.client.eye = controlled
	is_controlled = TRUE
	if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
		ADD_TRAIT(controller, TRAIT_IMMOBILIZED, REF(src))

/datum/control/proc/is_valid(check_control = FALSE)
	if(!controller || !controller.client || !controlled || QDELETED(controller) || QDELETED(controlled))
		qdel(src)
		return 0
	if(check_control && !(control_flags & REQUIRES_CONTROL && is_controlled))
		return 0
	return 1

/datum/control/proc/Move_object(direction)
	if(!is_valid())
		return
	if(controlled)
		if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
			ADD_TRAIT(controller, TRAIT_IMMOBILIZED, REF(src))
		if(controlled.density)
			step(controlled, direction)
			if(!controlled)
				return
			controlled.dir = direction
		else
			controlled.forceMove(get_step(controlled, direction))

/datum/control/proc/Orient_object(direction)
	if(!is_valid())
		return
	if(control_flags & LOCK_MOVEMENT_OF_CONTROLLER)
		ADD_TRAIT(controller, TRAIT_IMMOBILIZED, REF(src))
	controlled.dir = direction

/////////////////////////////LOCK MOVE//////////////////////////////

/datum/control/lock_move
	control_flags = LOCK_MOVEMENT_OF_CONTROLLER | LOCK_EYE_TO_CONTROLLED
