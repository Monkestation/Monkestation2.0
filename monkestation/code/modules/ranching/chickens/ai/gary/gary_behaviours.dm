/// Gary picks a random maint turf to set as his home
/datum/bt_node/ai_behavior/gary_pick_hideout

/datum/bt_node/ai_behavior/gary_pick_hideout/perform(seconds_per_tick, datum/ai_controller/chicken/gary/controller)
	var/list/turfs = get_area_turfs(/area/station/maintenance, subtypes = TRUE)
	if(!length(turfs))
		return AI_BEHAVIOR_FAILED
	var/turf/open/target_turf = null
	var/sanity = 0
	var/list/excluded_areas = list(/area/station/maintenance/department/science/xenobiology)// i hate isolated maints
	while(!target_turf && sanity < 100)
		sanity++
		var/turf/turf = pick(turfs)
		var/area/turf_area = get_area(turf)
		if(turf_area.type in excluded_areas)
			continue
		if(is_safe_turf(turf))
			target_turf = turf
	if(isnull(target_turf))
		return AI_BEHAVIOR_FAILED
	controller.set_home(target_turf)
	return AI_BEHAVIOR_SUCCEEDED

/**
 * Walks gary somewhere. If pathing gives up on him he just does a little leap and shows up there anyway,
 * the controller loves to give up on 2 tile paths with 20 path attempts left.
 */
/datum/bt_node/ai_behavior/gary_travel
	/// How close counts as being there
	var/required_distance = 1
	/// Where we're headed
	VAR_PRIVATE/atom/destination
	/// Set when the movement system gives up on the path
	VAR_PRIVATE/movement_failed = FALSE

/datum/bt_node/ai_behavior/gary_travel/setup(datum/ai_controller/controller)
	destination = get_destination(controller)
	if(QDELETED(destination))
		destination = null
		return FALSE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.ai_movement.start_moving_towards(controller, destination, required_distance)
	return TRUE

/// Pathing gave up, gary leaps there instead
/datum/bt_node/ai_behavior/gary_travel/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/gary_travel/perform(seconds_per_tick, datum/ai_controller/controller)
	if(QDELETED(destination))
		return AI_BEHAVIOR_FAILED
	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	if(get_dist(pawn, destination) <= required_distance)
		arrived(controller)
		return AI_BEHAVIOR_SUCCEEDED
	if(movement_failed)
		var/turf/landing = get_turf(destination)
		if(landing)
			INVOKE_ASYNC(pawn, TYPE_PROC_REF(/mob/living/basic/chicken/gary, leap_to), landing)
		arrived(controller)
		return AI_BEHAVIOR_SUCCEEDED
	if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, destination, required_distance)
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/gary_travel/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	controller.ai_movement.stop_moving_towards(controller)
	destination = null
	movement_failed = FALSE
	return ..()

/datum/bt_node/ai_behavior/gary_travel/Destroy()
	destination = null
	return ..()

/// Where we want to go
/datum/bt_node/ai_behavior/gary_travel/proc/get_destination(datum/ai_controller/controller)
	return null

/// We got there, one way or another
/datum/bt_node/ai_behavior/gary_travel/proc/arrived(datum/ai_controller/controller)
	return

/// Heads back to the hideout, dropping off whatever shiny we're carrying
/datum/bt_node/ai_behavior/gary_travel/head_to_hideout
	required_distance = 0

/datum/bt_node/ai_behavior/gary_travel/head_to_hideout/get_destination(datum/ai_controller/chicken/gary/controller)
	return controller.get_hideout()

/datum/bt_node/ai_behavior/gary_travel/head_to_hideout/arrived(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_GARY_COME_HOME, FALSE)
	if(!controller.blackboard[BB_GARY_HAS_SHINY])
		return
	controller.set_blackboard_key(BB_GARY_HAS_SHINY, FALSE)
	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	var/obj/item/shiny = pawn.held_item
	shiny?.forceMove(get_turf(pawn))
	if(!QDELETED(shiny))
		pawn.held_shinies += shiny.type
		shiny.AddComponent(/datum/component/garys_item, pawn)
	pawn.held_item = null

/// Goes to say hi to a random player on the station
/datum/bt_node/ai_behavior/gary_travel/visit_player

/datum/bt_node/ai_behavior/gary_travel/visit_player/get_destination(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_GARY_WANDER_COOLDOWN, world.time + 5 MINUTES)
	var/list/mobs = list()
	for(var/mob/living/mob as anything in GLOB.player_list)
		if(!istype(mob))
			continue
		if(!(mob.z in SSmapping.levels_by_trait(ZTRAIT_STATION)))
			continue
		var/area/mob_area = get_area(mob)
		if(istype(mob_area, /area/station/engineering/supermatter))
			continue
		mobs += mob
	return length(mobs) ? pick(mobs) : null

/// Unpacks everything gary saved last round into the new hideout
/datum/bt_node/ai_behavior/gary_setup_hideout

/datum/bt_node/ai_behavior/gary_setup_hideout/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	var/list/stored_items = pawn.return_stored_items()

	if(!pawn.hideout)
		pawn.hideout = new()

	var/turf/current_home = get_turf(pawn)
	for(var/shiny_object in stored_items)
		if(!shiny_object)
			continue
		var/obj/item/spawned = new shiny_object(current_home)
		pawn.hideout.add_item(spawned)
		spawned.AddComponent(/datum/component/garys_item, pawn)
	controller.set_blackboard_key(BB_GARY_HIDEOUT_SETTING_UP, FALSE)
	return AI_BEHAVIOR_SUCCEEDED

/// Clears out everything about the trade we were doing
/datum/ai_controller/chicken/gary/proc/stop_bartering()
	set_blackboard_key(BB_GARY_BARTER_STEP, 0)
	clear_blackboard_key(BB_GARY_BARTER_ITEM)
	clear_blackboard_key(BB_GARY_BARTER_TARGET)
	set_blackboard_key(BB_GARY_BARTERING, FALSE)

/// Fetches the item someone traded for out of the hideout
/datum/bt_node/ai_behavior/gary_travel/retrieve_item

/datum/bt_node/ai_behavior/gary_travel/retrieve_item/setup(datum/ai_controller/chicken/gary/controller)
	. = ..()
	if(!.)
		controller.stop_bartering()

/datum/bt_node/ai_behavior/gary_travel/retrieve_item/get_destination(datum/ai_controller/controller)
	return controller.blackboard[BB_GARY_BARTER_ITEM]

/datum/bt_node/ai_behavior/gary_travel/retrieve_item/arrived(datum/ai_controller/controller)
	var/mob/living/basic/chicken/gary/gary = controller.pawn
	var/obj/item/item = controller.blackboard[BB_GARY_BARTER_ITEM]
	if(QDELETED(item))
		return
	gary.held_item = item
	gary.hideout.remove_item(item)
	qdel(item.GetComponent(/datum/component/garys_item))
	item.forceMove(gary)
	controller.set_blackboard_key(BB_GARY_BARTER_STEP, 2)

/// Brings the traded item over to whoever asked for it
/datum/bt_node/ai_behavior/gary_give_item
	/// Who we're giving it to, kept for the async part
	VAR_PRIVATE/mob/living/receiver

/datum/bt_node/ai_behavior/gary_give_item/setup(datum/ai_controller/chicken/gary/controller)
	var/mob/living/target = controller.blackboard[BB_GARY_BARTER_TARGET]
	if(!isliving(target))
		controller.stop_bartering()
		return FALSE
	controller.ai_movement.start_moving_towards(controller, target, 1)
	return TRUE

/datum/bt_node/ai_behavior/gary_give_item/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	if(!pawn.held_item) //if held_item is null, we pretend that action was succesful
		return AI_BEHAVIOR_SUCCEEDED
	var/mob/living/target = controller.blackboard[BB_GARY_BARTER_TARGET]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(get_dist(pawn, target) > 1)
		if(!controller.ai_movement.moving_controllers[controller])
			controller.ai_movement.start_moving_towards(controller, target, 1)
		return AI_BEHAVIOR_INSTANT
	if(!pawn.CanReach(target))
		return AI_BEHAVIOR_FAILED
	receiver = target
	return start_async()

/datum/bt_node/ai_behavior/gary_give_item/perform_async(datum/ai_controller/controller)
	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	var/obj/item/held_item = pawn.held_item
	if(!try_to_give_item(pawn, receiver, held_item))
		finish_async(AI_BEHAVIOR_FAILED)
		return
	receiver.visible_message(
		span_info("[pawn] starts trying to give [held_item] to [receiver]!"),
		span_warning("[pawn] tries to give you [held_item]!")
	)
	if(!do_after(pawn, 1 SECONDS, receiver) || !async_still_valid())
		finish_async(AI_BEHAVIOR_FAILED)
		return
	finish_async(try_to_give_item(pawn, receiver, held_item, actually_give = TRUE) ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/// Checks if the item fits on them anywhere, and hands it over if actually_give is set. Drops it at their feet if it doesn't fit.
/datum/bt_node/ai_behavior/gary_give_item/proc/try_to_give_item(mob/living/basic/chicken/gary/pawn, mob/living/target, obj/item/held_item, actually_give)
	if(QDELETED(held_item) || QDELETED(target))
		return FALSE

	var/has_left_pocket = target.can_equip(held_item, ITEM_SLOT_LPOCKET)
	var/has_right_pocket = target.can_equip(held_item, ITEM_SLOT_RPOCKET)
	var/has_valid_hand

	pawn.held_item = null
	for(var/hand_index in target.get_empty_held_indexes())
		if(target.can_put_in_hand(held_item, hand_index))
			has_valid_hand = TRUE
			break

	if(!has_left_pocket && !has_right_pocket && !has_valid_hand)
		held_item.forceMove(get_turf(target))
		SEND_SIGNAL(held_item, COMSIG_ITEM_GARY_LOOTED, pawn)
		return FALSE

	if(!actually_give)
		return TRUE

	if(!has_valid_hand || prob(50))
		target.equip_to_slot_if_possible(held_item, (!has_left_pocket ? ITEM_SLOT_RPOCKET : (prob(50) ? ITEM_SLOT_LPOCKET : ITEM_SLOT_RPOCKET)))
	else
		target.put_in_hands(held_item)
	SEND_SIGNAL(held_item, COMSIG_ITEM_GARY_LOOTED, pawn)
	return TRUE

/datum/bt_node/ai_behavior/gary_give_item/finish_action(datum/ai_controller/chicken/gary/controller, succeeded)
	controller.ai_movement.stop_moving_towards(controller)
	receiver = null
	controller.stop_bartering()
	return ..()

/datum/bt_node/ai_behavior/gary_give_item/Destroy()
	receiver = null
	return ..()

/// Jumps out of view and lands on the turf, for when pathing gives up
/mob/living/basic/chicken/gary/proc/leap_to(turf/landing)
	if(!fading_leap_up())
		return
	forceMove(landing)
	fading_leap_down()
