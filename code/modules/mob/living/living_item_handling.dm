//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(throw_mode)
		throw_mode_off(THROW_MODE_TOGGLE)
	else
		throw_mode_on(THROW_MODE_TOGGLE)


/mob/living/carbon/proc/throw_mode_off(method)
	if(throw_mode > method) //A toggle doesnt affect a hold
		return
	throw_mode = THROW_MODE_DISABLED
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on(mode = THROW_MODE_TOGGLE)
	throw_mode = mode
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CARBON_THROW_THING, src, target)
	return TRUE

/mob/living/carbon/throw_item(atom/target)
	. = ..()
	throw_mode_off(THROW_MODE_TOGGLE)
	if(!target || !isturf(loc))
		return FALSE
	if(istype(target, /atom/movable/screen))
		return FALSE
	var/atom/movable/thrown_thing
	var/obj/item/held_item = get_active_held_item()
	var/verb_text = pick("throw", "toss", "hurl", "chuck", "fling")
	if(prob(0.5))
		verb_text = "yeet"
	var/neckgrab_throw = FALSE // we can't check for if it's a neckgrab throw when totaling up power_throw since we've already stopped pulling them by then, so get it early
	if(!held_item)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				if(grab_state >= GRAB_NECK)
					neckgrab_throw = TRUE
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM))
					to_chat(src, span_notice("You gently let go of [throwable_mob]."))
					return FALSE
	else
		thrown_thing = held_item.on_thrown(src, target)
	if(!thrown_thing)
		return FALSE
	if(isliving(thrown_thing))
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			log_combat(src, thrown_thing, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
	//MONKESTATION EDIT START
	var/feeble = HAS_TRAIT(src, TRAIT_FEEBLE)
	var/leg_aid = HAS_TRAIT(src, TRAIT_NO_LEG_AID)
	if (feeble && !leg_aid && prob(buckled ? 45 : 15))
		return fumble_throw_item(target, thrown_thing)
	//MONKESTATION EDIT START
	var/power_throw = 0
	if(HAS_TRAIT(src, TRAIT_HULK))
		power_throw++
//	if(HAS_TRAIT(src, TRAIT_DWARF)) // MONKESTATION EDIT OLD
	if(HAS_TRAIT(src, TRAIT_DWARF) && !HAS_TRAIT(src, TRAIT_STABLE_DWARF)) // MONKESTATION EDIT NEW
		power_throw--
	if(HAS_TRAIT(thrown_thing, TRAIT_DWARF))
		power_throw++
	if(neckgrab_throw)
		power_throw++
	//MONKESTATION EDIT START
	if (feeble)
		power_throw = 0
	//MONKESTATION EDIT END
	if(isitem(thrown_thing))
		var/obj/item/thrown_item = thrown_thing
		if(thrown_item.throw_verb)
			verb_text = thrown_item.throw_verb
	visible_message(span_danger("[src] [verb_text][plural_s(verb_text)] [thrown_thing][power_throw ? " really hard!" : "."]"), \
					span_danger("You [verb_text] [thrown_thing][power_throw ? " really hard!" : "."]"))
	log_message("has thrown [thrown_thing] [power_throw > 0 ? "really hard" : ""]", LOG_ATTACK)
	var/extra_throw_range = HAS_TRAIT(src, TRAIT_THROWINGARM) ? 2 : 0
	newtonian_move(get_dir(target, src))
	//MONKESTATION EDIT START
	var/total_throw_range = thrown_thing.throw_range + extra_throw_range
	if (feeble)
		total_throw_range = ceil(total_throw_range / (buckled ? 3 : 2))
	// thrown_thing.safe_throw_at(target, thrown_thing.throw_range + extra_throw_range, max(1,thrown_thing.throw_speed + power_throw), src, null, null, null, move_force) - MONKESTATION EDIT ORIGINAL
	thrown_thing.safe_throw_at(target, total_throw_range, max(1,thrown_thing.throw_speed + power_throw), src, null, null, null, move_force)
	if (!feeble || body_position == LYING_DOWN || buckled)
		return
	var/bulky = FALSE
	var/obj/item/I = thrown_thing
	if (istype(I))
		if (I.w_class > WEIGHT_CLASS_NORMAL || (thrown_thing.throwforce && !leg_aid))
			bulky = I.w_class > WEIGHT_CLASS_NORMAL
		else
			return
	if (!bulky && prob(50))
		return
	visible_message(span_danger("[src] looses [src.p_their()] balance."), \
		span_danger("You lose your balance."))
	Knockdown(2 SECONDS)

	//MONKESTATION EDIT END

// Giving stuff
/**
 * Proc called when offering an item to another player
 *
 * This handles creating an alert and adding an overlay to it
 */
/mob/living/proc/give(mob/living/offered)
	if(has_status_effect(/datum/status_effect/offering))
		to_chat(src, span_warning("You're already offering something!"))
		return

	if(IS_DEAD_OR_INCAP(src))
		to_chat(src, span_warning("You're unable to offer anything in your current state!"))
		return

	var/obj/item/offered_item = get_active_held_item()
	// if it's an abstract item, should consider it to be non-existent (unless it's a HAND_ITEM, which means it's an obj/item that is just a representation of our hand)
	if(!offered_item || ((offered_item.item_flags & ABSTRACT) && !(offered_item.item_flags & HAND_ITEM)))
		to_chat(src, span_warning("You're not holding anything to offer!"))
		return

	if(offered)
		if(offered == src)
			if(!swap_hand(get_inactive_hand_index())) //have to swap hands first to take something
				to_chat(src, span_warning("You try to take [offered_item] from yourself, but fail."))
				return
			if(!put_in_active_hand(offered_item))
				to_chat(src, span_warning("You try to take [offered_item] from yourself, but fail."))
				return
			else
				to_chat(src, span_notice("You take [offered_item] from yourself."))
				return

		if(IS_DEAD_OR_INCAP(offered))
			to_chat(src, span_warning("[offered.p_theyre(TRUE)] unable to take anything in [offered.p_their()] current state!"))
			return

		if(!CanReach(offered))
			to_chat(src, span_warning("You have to be beside [offered.p_them()]!"))
			return
	else
		if(!(locate(/mob/living) in orange(1, src)))
			to_chat(src, span_warning("There's nobody beside you to take it!"))
			return

	if(offered_item.on_offered(src)) // see if the item interrupts with its own behavior
		return

	visible_message(span_notice("[src] is offering [offered ? "[offered] " : ""][offered_item]."), \
					span_notice("You offer [offered ? "[offered] " : ""][offered_item]."), null, 2)

	apply_status_effect(/datum/status_effect/offering, offered_item, null, offered)

/**
 * Proc called when the player clicks the give alert
 *
 * Handles checking if the player taking the item has open slots and is in range of the offerer
 * Also deals with the actual transferring of the item to the players hands
 * Arguments:
 * * offerer - The person giving the original item
 * * I - The item being given by the offerer
 */
/mob/living/proc/take(mob/living/carbon/offerer, obj/item/I, visible_message = TRUE)
	clear_alert("[REF(offerer)]_offer")
	if(IS_DEAD_OR_INCAP(src))
		to_chat(src, span_warning("You're unable to take anything in your current state!"))
		return
	if(get_dist(src, offerer) > 1)
		to_chat(src, span_warning("[offerer] is out of range!"))
		return
	if(!I || offerer.get_active_held_item() != I)
		to_chat(src, span_warning("[offerer] is no longer holding the item they were offering!"))
		return
	if(!get_empty_held_indexes())
		to_chat(src, span_warning("You have no empty hands!"))
		return

	if(I.on_offer_taken(offerer, src)) // see if the item has special behavior for being accepted
		return

	if(!offerer.temporarilyRemoveItemFromInventory(I))
		visible_message(span_notice("[offerer] tries to hand over [I] but it's stuck to them...."))
		return

	if(visible_message)
		visible_message(span_notice("[src] takes [I] from [offerer]."), \
						span_notice("You take [I] from [offerer]."))
	else
		to_chat(src, span_notice("You take [I] from [offerer]."))
	put_in_hands(I)
	return TRUE

/mob/living/click_ctrl_shift(mob/user)
	if(HAS_TRAIT(src, TRAIT_CAN_HOLD_ITEMS))
		var/mob/living/living_user = user
		living_user.give(src)
