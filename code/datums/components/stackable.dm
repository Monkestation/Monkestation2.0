///A component that allows an item to with stackable(pretty much just a simlfied version of the behavior from /obj/item/stack)
/datum/component/stackable
	/// What's the name of just 1 of this stack. You have a stack of leather, but one piece of leather
	var/singular_name
	/// How much is in this stack?
	var/amount = 1
	/// How much is allowed in this stack?
	var/max_amount
	/// This path and its children should merge with this stack, defaults to parent.type
	var/merge_type = null
	/// The weight class the stack has at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	/// Determines whether the item should update it's sprites based on amount.
	var/novariants = TRUE

/**
 * _singular_name - What's the name of just 1 of this stack. You have a stack of leather, but one piece of leather
 * starting_amount - How many does this stack start within itself
 * _max_amount - How much is allowed in this stack?
 * _merge_type - This path and its children should merge with this stack, defaults to parent.type
 * _full_w_class - The weight class the stack has at amount > 2/3rds max_amount
 * _novariants - Determines whether the item should update it's sprites based on amount.
 */
/datum/component/stackable/Initialize(_singular_name, starting_amount, _max_amount = 50, _merge_type, _full_w_class = WEIGHT_CLASS_NORMAL, _novariants = TRUE, merge = TRUE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/typed_parent = parent
	singular_name = _singular_name || typed_parent.name
	max_amount = _max_amount
	merge_type = _merge_type || parent.type
	full_w_class = _full_w_class
	novariants = _novariants
	if(starting_amount != null && isnum(starting_amount))
		amount = starting_amount
	while(amount > max_amount)
		amount -= max_amount
		var/obj/item/created_item = new parent.type(typed_parent.loc)
		var/datum/component/stackable/new_stackable = created_item.GetComponent(/datum/component/stackable)
		if(new_stackable)
			new_stackable.add(max_amount - new_stackable.amount)
		else
			created_item.AddComponent(/datum/component/stackable, _singular_name, max_amount, max_amount, merge_type, full_w_class, novariants, FALSE)

	update_parent()
	if(merge)
		merge_with_loc()

/datum/component/stackable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ITEM_ON_GRIND, PROC_REF(on_grind))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_USED, PROC_REF(on_use))
	RegisterSignal(parent, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

///Call update_weight() and update_appearance() on our parent
/datum/component/stackable/proc/update_parent()
	update_weight()
	var/obj/item/typed_parent = parent
	typed_parent.update_appearance()

///Called when our parent is moved
/datum/component/stackable/proc/on_moved(obj/item/moved, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	if((!moved.throwing || moved.throwing.target_turf == moved.loc) && old_loc != moved.loc && (moved.flags_1 & INITIALIZED_1))
		merge_with_loc()

/datum/component/stackable/proc/find_other_stack(alist/already_found)
	var/obj/item/typed_parent = parent
	if(QDELETED(parent) || isnull(typed_parent.loc))
		return

	for(var/obj/item/item_stack in typed_parent.loc)
		if(item_stack == parent || QDELING(item_stack) || !(item_stack.flags_1 & INITIALIZED_1) || !istype(item_stack, merge_type))
			continue

		var/stack_ref = REF(item_stack)
		if(already_found[stack_ref])
			continue

		var/datum/component/stackable/stack_component = item_stack.GetComponent(/datum/component/stackable)
		if(stack_component.amount >= stack_component.max_amount)
			continue

		if(can_merge(item_stack, checked_type = TRUE))
			already_found[stack_ref] = TRUE
			return item_stack

/// Tries to merge the stack with everything on the same tile.
/datum/component/stackable/proc/merge_with_loc()
	var/alist/already_found = alist()
	var/obj/item/other_stack = find_other_stack(already_found)
	var/sanity = max_amount // just in case
	while(other_stack && sanity > 0)
		sanity--
		if(merge(other_stack))
			return FALSE
		other_stack = find_other_stack(already_found)
	return TRUE

/datum/component/stackable/proc/on_grind(obj/item/ground_item)
	SIGNAL_HANDLER
	for(var/i in 1 to length(ground_item.grind_results)) //This should only call if it's ground, so no need to check if grind_results exists
		ground_item.grind_results[ground_item.grind_results[i]] *= get_amount() //Gets the key at position i, then the reagent amount of that key, then multiplies it by stack size

/datum/component/stackable/proc/update_weight()
	var/obj/item/typed_parent = parent
	if(amount <= (max_amount * (1/3)))
		typed_parent.w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		typed_parent.w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		typed_parent.w_class = full_w_class

/datum/component/stackable/proc/on_update_icon_state()
	SIGNAL_HANDLER
	var/obj/item/typed_parent = parent
	if(novariants)
		return
	if(amount <= (max_amount * (1/3)))
		typed_parent.icon_state = initial(typed_parent.icon_state)
		return
	if (amount <= (max_amount * (2/3)))
		typed_parent.icon_state = "[initial(typed_parent.icon_state)]_2"
		return
	typed_parent.icon_state = "[initial(typed_parent.icon_state)]_3"

/datum/component/stackable/proc/on_examine(obj/item/examined, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(singular_name)
		if(get_amount()>1)
			examine_text += "There are [get_amount()] [singular_name]\s in the stack."
		else
			examine_text += "There is [get_amount()] [singular_name] in the stack."
	else if(get_amount()>1)
		examine_text += "There are [get_amount()] in the stack."
	else
		examine_text += "There is [get_amount()] in the stack."
	examine_text += span_notice("<b>Right-click</b> with an empty hand to take a custom amount.")

/datum/component/stackable/proc/get_amount()
	return amount

/datum/component/stackable/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, amount))
		add(clamp(vval, 1-amount, max_amount - amount)) //there must always be one.
		return TRUE
	else if(vname == NAMEOF(src, max_amount))
		max_amount = max(vval, 1)
		add((max_amount < amount) ? (max_amount - amount) : 0) //update icon, weight, ect
		return TRUE
	return ..()

/datum/component/stackable/proc/on_use(used, transfer = FALSE, check = TRUE) // return 0 = borked; return 1 = had enough
	SIGNAL_HANDLER
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return BLOCK_ITEM_USE
	if(amount < used)
		return BLOCK_ITEM_USE
	amount -= used
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return
	update_parent()

//I dont know how this actually gets used so im just taking it out for now
/*/datum/component/stackable/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		// general balloon alert that says they don't have enough
		to_chat(user, span_warning("not enough material!"))
		// then a more specific message about how much they need and what they need specifically
		if(singular_name)
			if(amount > 1)
				to_chat(user, span_warning("You need at least [amount] [singular_name]\s to do this!"))
			else
				to_chat(user, span_warning("You need at least [amount] [singular_name] to do this!"))
		else
			to_chat(user, span_warning("You need at least [amount] to do this!"))

		return FALSE

	return TRUE*/

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/datum/component/stackable/proc/is_zero_amount(delete_if_zero = TRUE)
	if(amount < 1)
		if(delete_if_zero)
			qdel(parent)
		return TRUE
	return FALSE

/** Adds some number of units to this stack.
 *
 * Arguments:
 * - _amount: The number of units to add to this stack.
 */
/datum/component/stackable/proc/add(_amount)
	amount += _amount
	update_parent()

/** Checks whether this stack can merge itself into another stack, will return the stackable component of checked if able to
 *
 * Arguments:
 * - [check][/obj/item/stackable]: The item to check for mergeability.
 * - [inhand][boolean]: Whether or not the stack to check should act like it's in a mob's hand.
 * - [checked_type][bool]: Has the istype() check already been run
 */
/datum/component/stackable/proc/can_merge(obj/item/check, inhand = FALSE, checked_type = FALSE)
	if(!checked_type && !istype(check, merge_type))
		return FALSE
	var/obj/item/typed_parent = parent
	if(ismob(typed_parent.loc) && !inhand) // no merging with items that are on the mob
		return FALSE
	if(istype(typed_parent.loc, /obj/machinery)) // no merging items in machines that aren't both in componentparts
		var/obj/machinery/machine = typed_parent.loc
		if(!(parent in machine.component_parts) || !(check in machine.component_parts))
			return FALSE
	if(SEND_SIGNAL(parent, COMSIG_STACK_CAN_MERGE, check, inhand) & CANCEL_STACK_MERGE)
		return FALSE
	return check.GetComponent(/datum/component/stackable)

/**
 * Merges as much of parent into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls on_use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/datum/component/stackable/proc/merge_without_del(obj/item/target_stack, limit, datum/component/stackable/target_component = target_stack.GetComponent())
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(target_stack))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(parent))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == parent)
		CRASH("Stack attempted to merge into itself.")
	if(!target_component)
		CRASH("Stack merge attempted on something without a stackable component.")

	var/transfer = get_amount()
	transfer = min(transfer, (limit ? limit : target_component.max_amount) - target_component.amount)
	ASYNC //non ideal way of handling this
		if(target_stack.pulledby)
			target_stack.pulledby.start_pulling(target_stack)
	target_component.copy_evidences(src)
	on_use(transfer, transfer = TRUE, check = FALSE)
	target_component.add(transfer)
	return transfer

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/datum/component/stackable/proc/merge(obj/item/target_stack, limit, datum/component/stackable/passed_component)
	. = merge_without_del(target_stack, limit, passed_component)
	is_zero_amount(delete_if_zero = TRUE)

/datum/component/stackable/proc/on_hitby(obj/item/hit, atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/datum/component/stackable/component = can_merge(hitting, inhand = TRUE)
	if(component)
		merge(hitting, passed_component = component)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/datum/component/stackable/proc/on_attack_hand(obj/item/attacked, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(user.get_inactive_held_item() == attacked)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		return split_stack(user, 1)

/datum/component/stackable/proc/on_attack_hand_secondary(obj/item/attacked, mob/user, modifiers)
	SIGNAL_HANDLER

	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(is_zero_amount(delete_if_zero = TRUE))
		return

	ASYNC
		var/split_amount = tgui_input_number(user, "How many sheets do you wish to take out of this stack?", "Stack Split", max_value = get_amount())
		if(!split_amount || QDELETED(user) || QDELETED(src) || !user.can_perform_action(attacked, FORBID_TELEKINESIS_REACH))
			return
		split_amount = min(max(split_amount, 1), get_amount())
		split_stack(user, split_amount)
		to_chat(user, span_notice("You take [split_amount] sheets out of the stack."))
		parent._AddComponent()

/** Splits the stack into two stacks.
 *
 * Arguments:
 * - [user][/mob]: The mob splitting the stack.
 * - split_amount: The number of units to split from this stack.
 */
/datum/component/stackable/proc/split_stack(mob/user, split_amount)
	if(!on_use(split_amount, TRUE, FALSE))
		return null
	var/obj/item/typed_parent = parent
	var/obj/item/new_stack = new type(user? user : typed_parent.drop_location())
	var/datum/component/stackable/component = new_stack.GetComponent(/datum/component/stackable) || \
											new_stack.AddComponent(/datum/component/stackable, singular_name, split_amount, max_amount, merge_type, full_w_class, novariants, FALSE)
	if(component.amount != split_amount)
		component.amount = split_amount
		component.update_parent()

	component.copy_evidences(src)
	if(user)
		ASYNC //pain
			if(!user.put_in_hands(new_stack, merge_stacks = FALSE))
				new_stack.forceMove(user.drop_location())
		typed_parent.add_fingerprint(user)
		new_stack.add_fingerprint(user)

	is_zero_amount(delete_if_zero = TRUE)
	return component

/datum/component/stackable/proc/on_attackby(obj/item/attacked, obj/item/attacking_item, mob/user, list/modifiers)
	SIGNAL_HANDLER
	var/datum/component/stackable/stack_component = can_merge(attacking_item, inhand = TRUE)
	if(stack_component)
		if(merge(attacking_item))
			to_chat(user, span_notice("Your [attacking_item.name] stack now contains [stack_component.get_amount()] [stack_component.singular_name]\s."))

/datum/component/stackable/proc/copy_evidences(obj/item/from)
	var/obj/item/typed_parent = parent
	typed_parent.add_blood_DNA(GET_ATOM_BLOOD_DNA(from))
	typed_parent.add_fingerprint_list(GET_ATOM_FINGERPRINTS(from))
	typed_parent.add_hiddenprint_list(GET_ATOM_HIDDENPRINTS(from))
	typed_parent.fingerprintslast = from.fingerprintslast
	//TODO bloody overlay
