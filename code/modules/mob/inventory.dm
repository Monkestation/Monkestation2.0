//These procs handle putting stuff in your hands
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

/**
 * Returns a list of all our hand slots, which could contain nulls.
 *
 * It is preferrable to use [/mob/proc/get_num_hand_slots] for counting hand slots,
 * or the get_held_items family of procs for filtering this list.
 */
/mob/proc/get_hand_slots() as /list
	RETURN_TYPE(/list/obj/item)

	return held_items.Copy()

/**
 * Returns a list of all items currently being held.
 *
 * If this list needs to be filtered further, it is preferrable to use
 * [/mob/proc/get_held_items_of_type] or [/mob/proc/get_held_items_of_typelist]
 * instead of filtering this list by hand.
 */
/mob/proc/get_held_items() as /list
	RETURN_TYPE(/list/obj/item)

	var/list/result = held_items.Copy()
	result.RemoveAll(null)
	return result

/// Returns a list of all held items that are a given type
/mob/proc/get_held_items_of_type(typepath) as /list
	RETURN_TYPE(/list/obj/item)

	. = list()
	for(var/obj/item/item as anything in get_hand_slots())
		if(istype(item, typepath))
			. += item

// Doing is_type_in_list *halves* the efficiency of the proc, so this has to be a separate thing
/// Returns a list of all held items that are a given *list* of types
/mob/proc/get_held_items_of_typelist(list/typepaths) as /list
	RETURN_TYPE(/list/obj/item)

	. = list()
	for(var/obj/item/item as anything in get_hand_slots())
		if(is_type_in_list(item, typepaths))
			. += item

/// Returns the item held in the [active hand][/mob/var/active_hand_index]. May be null.
/mob/proc/get_active_held_item() as /obj/item
	return get_item_for_held_index(active_hand_index)

/// Returns the item held in the [*opposite* hand][/mob/proc/get_inactive_hand_index] to the active hand. May be null.
/mob/proc/get_inactive_held_item() as /obj/item
	return get_item_for_held_index(get_inactive_hand_index())


/**
 * Returns the hand *opposite* to the [active hand][/mob/var/active_hand_index].
 *
 * The "opposite" hand refers to the other side of a given "set" of hands.<br>
 * The opposite of the left hand would be the right hand,
 * but it will not be an upper/lower right hand.
 */
/mob/proc/get_inactive_hand_index()
	var/other_hand = 0
	if(!(active_hand_index % 2))
		other_hand = active_hand_index-1 //finding the matching "left" limb
	else
		other_hand = active_hand_index+1 //finding the matching "right" limb
	if(other_hand < 0 || other_hand > held_items.len)
		other_hand = 0
	return other_hand

/// Returns the item at the specified hand index.
/mob/proc/get_item_for_held_index(i)
	if(i > 0 && i <= held_items.len)
		return held_items[i]

//Odd = left. Even = right
/mob/proc/held_index_to_dir(i)
	if(!(i % 2))
		return "r"
	return "l"

/// Check we have an organ for this hand slot. Only relevant for carbons.
/mob/proc/has_hand_for_held_index(i)
	return TRUE


/// Check we have an organ for our active hand slot. Only relevant for carbons.
/mob/proc/has_active_hand()
	return has_hand_for_held_index(active_hand_index)


//Finds the first available (null) index OR all available (null) indexes in held_items based on a side.
//Lefts: 1, 3, 5, 7...
//Rights:2, 4, 6, 8...
/mob/proc/get_empty_held_index_for_side(side = LEFT_HANDS, all = FALSE)
	var/list/empty_indexes = all ? list() : null
	for(var/i in (side == LEFT_HANDS) ? 1 : 2 to held_items.len step 2)
		if(!held_items[i])
			if(!all)
				return i
			empty_indexes += i
	return empty_indexes


//Same as the above, but returns the first or ALL held *ITEMS* for the side
/mob/proc/get_held_items_for_side(side = LEFT_HANDS, all = FALSE)
	var/list/holding_items = all ? list() : null
	for(var/i in (side == LEFT_HANDS) ? 1 : 2 to held_items.len step 2)
		var/obj/item/I = held_items[i]
		if(I)
			if(!all)
				return I
			holding_items += I
	return holding_items

/// Returns a list of indexes for every hand that is *holding something*.
/mob/proc/get_active_held_indexes() as /list
	. = list()
	for(var/i in 1 to held_items.len)
		if(held_items[i])
			. += i

/// Returns a list of indexes for every hand that is *empty*.
/mob/proc/get_empty_held_indexes() as /list
	. = list()
	for(var/i in 1 to held_items.len)
		if(!held_items[i])
			. += i

/mob/proc/get_held_index_of_item(obj/item/I)
	return held_items.Find(I)


/// Returns the number of available hand slots
/mob/proc/get_num_hand_slots() as num
	return held_items.len

/// Find number of held items, multihand compatible
/mob/proc/get_num_held_items()
	. = 0
	for(var/i in 1 to held_items.len)
		if(held_items[i])
			.++

/// Can this mob hold items?
/mob/proc/can_hold_items(obj/item/I)
	return !!length(held_items)

/// Returns true if a mob is holding something
/mob/proc/is_holding_items()
	return !!locate(/obj/item) in held_items

/// Returns TRUE/FALSE depending on if we're holding this item
/mob/proc/is_holding(obj/item/item)
	return (item in held_items)

/// Checks if we're holding an item of this type
/mob/proc/is_holding_item_of_type(typepath)
	return locate(typepath) in held_items

// List version of above proc
/// Returns ret_item, which is either the successfully located item or null
/mob/proc/is_holding_item_of_types(list/typepaths)
	var/ret_item
	for(var/typepath in typepaths)
		ret_item = is_holding_item_of_type(typepath)
		if(ret_item)
			return ret_item

//Checks if we're holding a tool that has given quality
//Returns the tool that has the best version of this quality
/mob/proc/is_holding_tool_quality(quality)
	var/obj/item/best_item
	var/best_quality = INFINITY

	for(var/obj/item/I in held_items)
		if(I.tool_behaviour == quality && I.toolspeed < best_quality)
			best_item = I
			best_quality = I.toolspeed

	return best_item


//To appropriately fluff things like "they are holding [I] in their [get_held_index_name(get_held_index_of_item(I))]"
//Can be overridden to pass off the fluff to something else (eg: science allowing people to add extra robotic limbs, and having this proc react to that
// with say "they are holding [I] in their Nanotrasen Brand Utility Arm - Right Edition" or w/e
/mob/proc/get_held_index_name(i)
	var/list/hand = list()
	if(i > 2)
		hand += "upper "
	var/num = 0
	if(!(i % 2))
		num = i-2
		hand += "right hand"
	else
		num = i-1
		hand += "left hand"
	num -= (num*0.5)
	if(num > 1) //"upper left hand #1" seems weird, but "upper left hand #2" is A-ok
		hand += " #[num]"
	return hand.Join()



//Returns if a certain item can be equipped to a certain slot.
// Currently invalid for two-handed items - call obj/item/mob_can_equip() instead.
/mob/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	return FALSE

/mob/proc/can_put_in_hand(I, hand_index)
	if(hand_index > length(held_items))
		return FALSE
	if(!put_in_hand_check(I))
		return FALSE
	if(!has_hand_for_held_index(hand_index))
		return FALSE
	return !held_items[hand_index]

/mob/proc/put_in_hand(obj/item/I, hand_index, forced = FALSE, ignore_anim = TRUE)
	if(hand_index == null || !length(held_items) || (!forced && !can_put_in_hand(I, hand_index)))
		return FALSE
	if(isturf(I.loc) && !ignore_anim)
		I.do_pickup_animation(src)
	if(get_item_for_held_index(hand_index))
		dropItemToGround(get_item_for_held_index(hand_index), force = TRUE)
	I.forceMove(src)
	held_items[hand_index] = I
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)
	if(I.pulledby)
		I.pulledby.stop_pulling()
	if(!I.on_equipped(src, ITEM_SLOT_HANDS))
		return FALSE
	update_held_items()
	I.pixel_x = I.base_pixel_x
	I.pixel_y = I.base_pixel_y
	if(QDELETED(I)) // this is here because some ABSTRACT items like slappers and circle hands could be moved from hand to hand then delete, which meant you'd have a null in your hand until you cleared it (say, by dropping it)
		held_items[hand_index] = null
		return FALSE
	return hand_index

//Puts the item into the first available left hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side(LEFT_HANDS))

//Puts the item into the first available right hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/I)
	return put_in_hand(I, get_empty_held_index_for_side(RIGHT_HANDS))

/mob/proc/put_in_hand_check(obj/item/I)
	return FALSE //nonliving mobs don't have hands

/mob/living/put_in_hand_check(obj/item/I)
	if(istype(I) && !QDELETED(I) && (((mobility_flags & MOBILITY_PICKUP) || ((stat >= SOFT_CRIT && (stat != DEAD && stat != UNCONSCIOUS && stat != HARD_CRIT)))) || (I.item_flags & ABSTRACT)) \
		&& !(SEND_SIGNAL(src, COMSIG_LIVING_TRY_PUT_IN_HAND, I) & COMPONENT_LIVING_CANT_PUT_IN_HAND))
		return TRUE
	return FALSE

//Puts the item into our active hand if possible. returns TRUE on success.
/mob/proc/put_in_active_hand(obj/item/I, forced = FALSE, ignore_animation = TRUE)
	return put_in_hand(I, active_hand_index, forced, ignore_animation)


//Puts the item into our inactive hand if possible, returns TRUE on success
/mob/proc/put_in_inactive_hand(obj/item/I, forced = FALSE)
	return put_in_hand(I, get_inactive_hand_index(), forced)


//Puts the item our active hand if possible. Failing that it tries other hands. Returns TRUE on success.
//If both fail it drops it on the floor and returns FALSE.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, forced = FALSE, ignore_animation = TRUE)
	if(QDELETED(I))
		return FALSE

	// Cyborg's apparatus is their hand.
	if(iscyborg(src))
		var/mob/living/silicon/robot/cyborg_owner = src
		var/obj/item/borg/apparatus/cyborg_apparatus = cyborg_owner.get_active_held_item()
		if(istype(cyborg_apparatus) && cyborg_apparatus.put_in_apparatus(I, cyborg_owner))
			return TRUE

	// If the item is a stack and we're already holding a stack then merge
	if (isstack(I))
		var/obj/item/stack/item_stack = I
		var/obj/item/stack/active_stack = get_active_held_item()

		if (item_stack.is_zero_amount(delete_if_zero = TRUE))
			return FALSE

		if (merge_stacks)
			if (istype(active_stack) && active_stack.can_merge(item_stack, inhand = TRUE))
				if (item_stack.merge(active_stack))
					to_chat(usr, span_notice("Your [active_stack.name] stack now contains [active_stack.get_amount()] [active_stack.singular_name]\s."))
					return TRUE
			else
				var/obj/item/stack/inactive_stack = get_inactive_held_item()
				if (istype(inactive_stack) && inactive_stack.can_merge(item_stack, inhand = TRUE))
					if (item_stack.merge(inactive_stack))
						to_chat(usr, span_notice("Your [inactive_stack.name] stack now contains [inactive_stack.get_amount()] [inactive_stack.singular_name]\s."))
						return TRUE

	if(put_in_active_hand(I, forced, ignore_animation))
		return TRUE

	var/hand = get_empty_held_index_for_side(LEFT_HANDS)
	if(!hand)
		hand = get_empty_held_index_for_side(RIGHT_HANDS)
	if(hand)
		if(put_in_hand(I, hand, forced, ignore_animation))
			return TRUE
	if(del_on_fail)
		qdel(I)
		return FALSE
	var/atom/location = drop_location()
	I.forceMove(location)
	I.layer = initial(I.layer)
	SET_PLANE_EXPLICIT(I, initial(I.plane), location)
	I.dropped(src)
	return FALSE

/mob/proc/drop_all_held_items(force = FALSE)
	. = FALSE
	for(var/obj/item/I in held_items)
		. |= dropItemToGround(I, force)

//Here lie drop_from_inventory and before_item_take, already forgotten and not missed.

/mob/proc/canUnEquip(obj/item/I, force)
	if(!I)
		return TRUE
	if(HAS_TRAIT(I, TRAIT_NODROP) && !force)
		return FALSE
	return TRUE

/mob/proc/putItemFromInventoryInHandIfPossible(obj/item/I, hand_index, force_removal = FALSE)
	if(!can_put_in_hand(I, hand_index))
		return FALSE
	if(!temporarilyRemoveItemFromInventory(I, force_removal))
		return FALSE
	I.remove_item_from_storage(src)
	if(!put_in_hand(I, hand_index))
		qdel(I)
		CRASH("Assertion failure: putItemFromInventoryInHandIfPossible") //should never be possible
	return TRUE

//The following functions are the same save for one small difference

/**
 * Used to drop an item (if it exists) to the ground.
 * * Will pass as TRUE is successfully dropped, or if there is no item to drop.
 * * Will pass FALSE if the item can not be dropped due to TRAIT_NODROP via doUnEquip()
 * If the item can be dropped, it will be forceMove()'d to the ground and the turf's Entered() will be called.
*/
/mob/proc/dropItemToGround(obj/item/I, force = FALSE, silent = FALSE, invdrop = TRUE, violent = FALSE)
	if (isnull(I))
		return TRUE

	SEND_SIGNAL(src, COMSIG_MOB_DROPPING_ITEM)
	. = doUnEquip(I, force, drop_location(), FALSE, invdrop = invdrop, silent = silent)

	if(!. || !I) //ensure the item exists and that it was dropped properly.
		return

	if(!(I.item_flags & NO_PIXEL_RANDOM_DROP))
		I.pixel_x = I.base_pixel_x + rand(-6, 6)
		I.pixel_y = I.base_pixel_y + rand(-6, 6)
	I.do_drop_animation(src)

	if(violent)
		var/turf/drop = drop_location()
		I.launch_item(drop)

/// Unequips and transfers an item to a given turf, if possible.
/mob/proc/transfer_item_to_turf(
	obj/item/to_transfer,
	turf/new_loc,
	x_offset = 0,
	y_offset = 0,
	force = FALSE,
	silent = FALSE,
	drop_item_inventory = TRUE,
)
	if(!doUnEquip(to_transfer, force, new_loc, no_move = FALSE, invdrop = drop_item_inventory, silent = silent))
		return FALSE
	if(QDELETED(to_transfer)) // Some items may get deleted upon getting unequipped.
		return FALSE
	to_transfer.pixel_x = to_transfer.base_pixel_x + x_offset
	to_transfer.pixel_y = to_transfer.base_pixel_y + y_offset
	to_transfer.do_drop_animation(src)
	return TRUE

//for when the item will be immediately placed in a loc other than the ground
/mob/proc/transferItemToLoc(obj/item/I, newloc = null, force = FALSE, silent = TRUE)
	. = doUnEquip(I, force, newloc, FALSE, silent = silent)
	I.do_drop_animation(src)

//visibly unequips I but it is NOT MOVED AND REMAINS IN SRC
//item MUST BE FORCEMOVE'D OR QDEL'D
/mob/proc/temporarilyRemoveItemFromInventory(obj/item/I, force = FALSE, idrop = TRUE)
	return doUnEquip(I, force, null, TRUE, idrop, silent = TRUE)

//DO NOT CALL THIS PROC
//use one of the above 3 helper procs
//you may override it, but do not modify the args
/mob/proc/doUnEquip(obj/item/I, force, atom/newloc, no_move, invdrop = TRUE, silent = FALSE) //Force overrides TRAIT_NODROP for things like wizarditis and admin undress.
													//Use no_move if the item is just gonna be immediately moved afterward
													//Invdrop is used to prevent stuff in pockets dropping. only set to false if it's going to immediately be replaced
	PROTECTED_PROC(TRUE)
	if(!I) //If there's nothing to drop, the drop is automatically succesfull. If(unEquip) should generally be used to check for TRAIT_NODROP.
		return TRUE

	if(HAS_TRAIT(I, TRAIT_NODROP) && !force)
		return FALSE

	if((SEND_SIGNAL(I, COMSIG_ITEM_PRE_UNEQUIP, force, newloc, no_move, invdrop, silent) & COMPONENT_ITEM_BLOCK_UNEQUIP) && !force)
		return FALSE

	var/hand_index = get_held_index_of_item(I)
	if(hand_index)
		held_items[hand_index] = null
		update_held_items()
	if(I)
		if(client)
			client.screen -= I
		I.layer = initial(I.layer)
		SET_PLANE_EXPLICIT(I, initial(I.plane), newloc)
		I.appearance_flags &= ~NO_CLIENT_COLOR
		if(!no_move && !(I.item_flags & DROPDEL)) //item may be moved/qdel'd immedietely, don't bother moving it
			if (isnull(newloc) || QDELING(I))
				I.moveToNullspace()
			else
				I.forceMove(newloc)
		has_unequipped(I, silent)
	SEND_SIGNAL(I, COMSIG_ITEM_POST_UNEQUIP, force, newloc, no_move, invdrop, silent)
	SEND_SIGNAL(src, COMSIG_MOB_UNEQUIPPED_ITEM, I, force, newloc, no_move, invdrop, silent)
	return TRUE

/**
 * Used to return a list of equipped items on a mob; does not include held items (use get_all_gear)
 *
 * Argument(s):
 * * Optional - include_flags, (see obj.flags.dm) describes which optional things to include or not (pockets, accessories, held items)
 */

/mob/living/proc/get_equipped_items(include_flags = NONE)
	var/list/items = list()
	for(var/obj/item/item_contents in contents)
		if(item_contents.item_flags & IN_INVENTORY)
			items += item_contents
	if (!(include_flags & INCLUDE_HELD))
		items -= held_items
	return items

/mob/living/proc/unequip_everything()
	var/list/items = list()
	items |= get_equipped_items(INCLUDE_POCKETS)
	for(var/I in items)
		dropItemToGround(I)
	drop_all_held_items()


/// This proc is called after an item has been successfully handled and equipped to a slot.
/mob/proc/has_equipped(obj/item/item, slot, initial = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	return item.on_equipped(src, slot, initial)

/// This proc is called after an item has been removed from a mob but before it has been officially deslotted.
/mob/proc/has_unequipped(obj/item/item, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	item.dropped(src, silent)
	return TRUE

/obj/item/proc/equip_to_best_slot(mob/equipper)
	var/should_prioritize_storage = !isclothing(src) && !(slot_flags & ITEM_SLOT_ON_BODY)

	// if it's not clothing / something that fits into a slot, then prioritize active storage first
	if(should_prioritize_storage)
		if(equipper.active_storage?.attempt_insert(src, equipper))
			return TRUE

	if(equipper.equip_to_appropriate_slot(src))
		equipper.update_held_items()
		return TRUE
	else
		if(equip_delay_self)
			return

	// if it IS clothing / something that fits into a slot, prioritize inv slots first, then active storage.
	if(!should_prioritize_storage)
		if(equipper.active_storage?.attempt_insert(src, equipper))
			return TRUE

	var/list/obj/item/possible = list(equipper.get_inactive_held_item(), equipper.get_item_by_slot(ITEM_SLOT_BELT), equipper.get_item_by_slot(ITEM_SLOT_DEX_STORAGE), equipper.get_item_by_slot(ITEM_SLOT_BACK))
	for(var/i in possible)
		if(!i)
			continue
		var/obj/item/I = i
		if(I.atom_storage?.attempt_insert(src, equipper))
			return TRUE

	to_chat(equipper, span_warning("You are unable to equip that!"))
	return FALSE


GAME_VERB_HIDDEN(/mob, quick_equip, "quick-equip")

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(execute_quick_equip)))

///proc extender of [/mob/verb/quick_equip] used to make the verb queuable if the server is overloaded
/mob/proc/execute_quick_equip()
	var/obj/item/I = get_active_held_item()
	if(!I)
		to_chat(src, span_warning("You are not holding anything to equip!"))
		return
	if(!QDELETED(I))
		I.equip_to_best_slot(src)

//used in code for items usable by both carbon and drones, this gives the proper back slot for each mob.(defibrillator, backpack watertank, ...)
/mob/proc/getBackSlot()
	return ITEM_SLOT_BACK

/mob/proc/getBeltSlot()
	return ITEM_SLOT_BELT



//Inventory.dm is -kind of- an ok place for this I guess

//This is NOT for dismemberment, as the user still technically has 2 "hands"
//This is for multi-handed mobs, such as a human with a third limb installed
//This is a very rare proc to call (besides admin fuckery) so
//any cost it has isn't a worry
/mob/proc/change_number_of_hands(amt)
	if(amt < held_items.len)
		for(var/i in held_items.len to amt step -1)
			dropItemToGround(held_items[i])
	held_items.len = amt

	if(hud_used)
		hud_used.build_hand_slots()

/mob/living/carbon/human/change_number_of_hands(amt)
	var/old_limbs = held_items.len
	if(amt < old_limbs)
		for(var/i in hand_bodyparts.len to amt step -1)
			var/obj/item/bodypart/BP = hand_bodyparts[i]
			BP.dismember()
			hand_bodyparts[i] = null
		hand_bodyparts.len = amt
	else if(amt > old_limbs)
		hand_bodyparts.len = amt
		for(var/i in old_limbs+1 to amt)
			var/path = /obj/item/bodypart/arm/left
			if(!(i % 2))
				path = /obj/item/bodypart/arm/right

			var/obj/item/bodypart/BP = new path ()
			BP.held_index = i
			BP.try_attach_limb(src, TRUE)
			hand_bodyparts[i] = BP
	..() //Don't redraw hands until we have organs for them

//GetAllContents that is reasonable and not stupid
/mob/living/proc/get_all_gear(accessories = TRUE, recursive = TRUE)
	var/list/processing_list = get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD | (accessories ? INCLUDE_ACCESSORIES : NONE))
	list_clear_nulls(processing_list) // handles empty hands
	var/i = 0
	while(i < length(processing_list))
		var/atom/A = processing_list[++i]
		if(A.atom_storage && recursive)
			processing_list += A.atom_storage.return_inv()
	return processing_list
