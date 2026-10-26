/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params,A))
		return

	if(stat || (lockcharge) || IsParalyzed() || IsStun())
		return

	var/list/modifiers = params2list(params)

	if(client)
		client.imode.update_istate(src, modifiers)

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(istate & ISTATE_CONTROL)
			CtrlShiftClickOn(A)
			return
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			ShiftMiddleClickOn(A)
			return
		if(!(istate & ISTATE_SECONDARY)) // shift right click = right click, not shift click (context menu pref compatibility)
			ShiftClickOn(A)
			return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		if(istate & ISTATE_SECONDARY)
			AltClickSecondaryOn(A)
		else
			A.borg_click_alt(src)
		return
	if(istate & ISTATE_CONTROL)
		CtrlClickOn(A)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	var/obj/item/W = get_active_held_item()

	//wireless interaction with an atom
	if(!W && get_dist(src, A) <= interaction_range)
		if(istate & ISTATE_SECONDARY && !module_active)
			var/secondary_result = A.attack_robot_secondary(src, modifiers)
			if(secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
				return
			if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
				CRASH("attack_robot_secondary did not return a SECONDARY_ATTACK_* define.")

		A.attack_robot(src, modifiers)
		return

	if(W)
		if(incapacitated())
			return

		//while buckled, you can still connect to and control things like doors, but you can't use your modules
		if(buckled)
			to_chat(src, span_warning("You can't use modules while buckled to [buckled]!"))
			return

		//if your "hands" are blocked you shouldn't be able to use modules
		if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
			return

		if(W == A)
			if(istate & ISTATE_SECONDARY)
				W.attack_self_secondary(src, modifiers)
			else
				W.attack_self(src, modifiers)
			return

		// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
		if(A == loc || (A in loc) || (A in contents))
			W.melee_attack_chain(src, A, modifiers)
			return

		if(!isturf(loc))
			return

		// cyborg rightclick code, allowing borgos to use weapons at range
		if(CanReach(A,W))
			W.melee_attack_chain(src, A, modifiers)
			return
		else if(isturf(A) || isturf(A.loc))
			A.base_ranged_item_interaction(src, W, modifiers)

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(atom/target)
	target.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/ShiftClickOn(atom/target)
	target.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(atom/target)
	target.BorgCtrlClick(src)

/**
 * Handles whenever a cyborg Ctrl+Shift+Click onto this atom.
 *
 * By default, will forward to [/proc/base_click_ctrl_shift] if not overridden.
 */
/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user)
	user.base_click_ctrl_shift(src)

/**
 * Handles whenever a cyborg Shift+Click onto this atom.
 *
 * By default, will forward to [/proc/ShiftClick] behavior if not overridden.
 */
/atom/proc/BorgShiftClick(mob/living/silicon/robot/user)
	ShiftClick(user)

/**
 * Handles whenever a cyborg Ctrl+Click onto this atom.
 *
 * By default, will forward to [/proc/base_click_ctrl] behavior if not overridden.
 */
/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user)
	user.base_click_ctrl(src)

/**
 * Handles whenever a cyborg Alt+Click onto this atom.
 *
 * By default, will forward to [/proc/base_click_alt] behavior if not overridden.
 */
/atom/proc/borg_click_alt(mob/living/silicon/robot/user)
	user.base_click_alt(src)
	return

/obj/machinery/door/airlock/BorgCtrlShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AICtrlShiftClick(user) // Toggles emergency access override on the airlock.
		return
	return ..()

/obj/machinery/door/airlock/BorgShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AIShiftClick(user) // Opens or closes the airlock.
		return
	return ..()

/obj/machinery/door/airlock/BorgCtrlClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AICtrlClick(user) // Toggles bolts on the airlock.
		return
	return ..()

/obj/machinery/door/airlock/borg_click_alt(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		ai_click_alt(user)
		return // Toggles electrification for the airlock.
	return ..()

/obj/machinery/power/apc/BorgCtrlClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AICtrlClick(user) // Toggles main power for the APC.
		return
	return ..()

/obj/machinery/power/apc/BorgCtrlShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AICtrlShiftClick(user) // Toggles environment power for the APC.
		return
	return ..()

/obj/machinery/power/apc/BorgShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AIShiftClick(user) // Toggles lighting power for the APC.
		return
	return ..()

/obj/machinery/power/apc/borg_click_alt(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		ai_click_alt(user) // Toggles equipment power for the APC.
		return
	return ..()

/obj/machinery/power/apc/attack_robot_secondary(mob/living/silicon/robot/user, list/modifiers)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		return attack_ai_secondary(user, modifiers) // Toggles locks for the APC.
	return ..()

/obj/machinery/turretid/BorgCtrlClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		AICtrlClick(user) // Toggles on / off mode for the turret.
		return
	return ..()

/obj/machinery/turretid/borg_click_alt(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range && !(user.control_disabled) && !user.low_power_mode)
		ai_click_alt(user) // Toggles non-lethal / lethal mode for the turret.
		return
	return ..()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!can_unarmed_attack())
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return A.attack_robot_secondary(src, modifiers)

	return A.attack_robot(src, modifiers)

/**
 * What happens when the cyborg holds left-click on an item.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_robot(mob/user, modifiers)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return

	attack_ai(user)

/**
 * What happens when the cyborg without active module holds right-click on an item. Returns a SECONDARY_ATTACK_* value.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_robot_secondary(mob/user, list/modifiers)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return attack_ai_secondary(user, modifiers)
