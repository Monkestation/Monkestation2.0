/datum/ai_controller/robot_customer
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.8 SECONDS
	blackboard = list(
		BB_CUSTOMER_ATTENDING_VENUE = null,
		BB_CUSTOMER_CURRENT_ORDER = null,
		BB_CUSTOMER_CUSTOMERINFO = null,
		BB_CUSTOMER_EATING = FALSE,
		BB_CUSTOMER_LEAVING = FALSE,
		BB_CUSTOMER_MY_SEAT = null,
		BB_CUSTOMER_PATIENCE = 999 SECONDS,
		BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE = FALSE,
	)
	planning_subtrees = list(/datum/ai_planning_subtree/robot_customer)

/datum/ai_controller/robot_customer/Destroy()
	// clear possible datum refs
	clear_blackboard_key(BB_CUSTOMER_CURRENT_ORDER)
	clear_blackboard_key(BB_CUSTOMER_CUSTOMERINFO)
	return ..()

/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/basic/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	new_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_LIVING_GET_PULLED, PROC_REF(on_get_pulled))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_get_punched))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	if(isnull(pawn))
#ifndef UNIT_TESTS
		stack_trace("Robot Customer AI Controller UnpossessPawn called with null pawn! This shouldn't happen in normal circumstances.") // and unit tests are abnormal circumstances
#endif
		return

	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_WAS_ATTACKED, COMSIG_LIVING_GET_PULLED, COMSIG_ATOM_ATTACK_HAND))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/proc/on_attackby(datum/source, obj/item/I, mob/living/user)

/datum/ai_controller/robot_customer/proc/on_attacked(datum/source, mob/living/attacker)

/datum/ai_controller/robot_customer/proc/eat_order(obj/item/order_item, datum/venue/attending_venue)



///Called when
/datum/ai_controller/robot_customer/proc/on_get_pulled(datum/source, mob/living/puller)



/datum/ai_controller/robot_customer/proc/async_on_get_pulled(datum/source, mob/living/puller)




/datum/ai_controller/robot_customer/proc/dont_want_that(mob/living/chef, obj/item/thing)

/datum/ai_controller/robot_customer/proc/warn_greytider(mob/living/greytider)
	//Living mobs are tagged, so these will always be valid



/datum/ai_controller/robot_customer/proc/on_get_punched(datum/source, mob/living/living_hitter)




