/obj/structure/destructible/clockwork/gear_base/powered
	/// If the structure has its "on" switch flipped. Does not mean it's on, necessarily (needs power and anchoring, too)
	var/enabled = FALSE
	/// How much power this structure uses passively
	var/passive_consumption = 0
	/// Do we actually have power when turned on
	var/is_powered = FALSE
	/// Lazylist of nearby transmission signals
	var/list/transmission_sigils
	/// Has an "_inactive" icon state
	var/has_off_icon = TRUE
	/// Has an "_active" icon state
	var/has_on_icon = TRUE
	/// Has the ability to toggle power by using an empty hand on it
	var/has_power_toggle = TRUE

/obj/structure/destructible/clockwork/gear_base/powered/Initialize(mapload)
	. = ..()
	update_icon_state()
	LAZYINITLIST(transmission_sigils)
	for(var/obj/structure/destructible/clockwork/sigil/transmission/trans_sigil in range(src, SIGIL_TRANSMISSION_RANGE))
		link_to_sigil(trans_sigil)
	AddComponent(/datum/component/clockwork_trap/powered_structure)

/obj/structure/destructible/clockwork/gear_base/powered/Destroy()
	for(var/obj/structure/destructible/clockwork/sigil/transmission/trans_sigil as anything in transmission_sigils)
		trans_sigil.linked_structures -= src
	return ..()

/obj/structure/destructible/clockwork/gear_base/powered/attack_hand(mob/user)
	if(!IS_CLOCK(user))
		return ..()

	try_toggle_power(user)

/obj/structure/destructible/clockwork/gear_base/powered/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return

	if(anchored)
		return

	enabled = FALSE
	turn_off()
	update_icon_state()
	visible_message("[src] powers down as it becomes unanchored from the ground.")

/obj/structure/destructible/clockwork/gear_base/powered/update_icon_state()
	. = ..()
	icon_state = base_icon_state || initial(icon_state)

	if(!anchored)
		icon_state = base_icon_state + unwrenched_suffix
		return

	if(has_off_icon && (!is_powered || !enabled))
		icon_state = base_icon_state + "_inactive"
		return

	if(has_on_icon && is_powered)
		icon_state = base_icon_state + "_active"

/obj/structure/destructible/clockwork/gear_base/powered/process(seconds_per_tick)
	var/last_powered_state = is_powered
	is_powered = length(transmission_sigils) > 0
	if(last_powered_state != is_powered)
		if(is_powered)
			repowered()
		else
			depowered()

/obj/structure/destructible/clockwork/gear_base/powered/proc/try_toggle_power(mob/user)
	if(!has_power_toggle)
		return

	if(!anchored)
		if(user)
			balloon_alert(user, "not fastened!")
		return

	if(!enabled)
		if(!length(transmission_sigils) || !SSthe_ark.adjust_passive_power(passive_consumption, TRUE))
			if(user)
				balloon_alert(user, "not enough power!")
			return
		turn_on()
	else
		turn_off()

	enabled = !enabled
	if(user)
		balloon_alert(user, "turned [enabled ? "on" : "off"]")

/// Turn on the structure, letting it consume power and process again
/obj/structure/destructible/clockwork/gear_base/powered/proc/turn_on()
	repowered()
	START_PROCESSING(SSthe_ark, src)

/// Turn off the structure, ceasing its processing
/obj/structure/destructible/clockwork/gear_base/powered/proc/turn_off()
	depowered()
	STOP_PROCESSING(SSthe_ark, src)

/// Checks if there's a sigil to power it, calls repower() if changed from depowered to powered, vice versa
/obj/structure/destructible/clockwork/gear_base/powered/proc/check_transmission_sigils()
	if(!enabled)
		return FALSE

	if(!is_powered)
		if(length(transmission_sigils))
			repowered()
			return TRUE
		return FALSE
	else if(!length(transmission_sigils))
		depowered()
		return FALSE
	return TRUE

/// Uses power if there's enough to do so
/obj/structure/destructible/clockwork/gear_base/powered/proc/use_energy(amount)
	return check_transmission_sigils() && SSthe_ark.adjust_clock_power(-amount)

/// Triggers when the structure runs out of power to use
/obj/structure/destructible/clockwork/gear_base/powered/proc/depowered()
	SHOULD_CALL_PARENT(TRUE)
	is_powered = FALSE
	SSthe_ark.adjust_passive_power(-passive_consumption)
	update_icon_state()

/// Triggers when the structure regains power to use
/obj/structure/destructible/clockwork/gear_base/powered/proc/repowered()
	SHOULD_CALL_PARENT(TRUE)
	is_powered = length(transmission_sigils) > 0
	SSthe_ark.adjust_passive_power(passive_consumption)
	update_icon_state()

/// Adds a sigil to the linked structure list
/obj/structure/destructible/clockwork/gear_base/powered/proc/link_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/sigil)
	LAZYOR(transmission_sigils, sigil)
	sigil.linked_structures |= src

/// Removes a sigil from the linked structure list
/obj/structure/destructible/clockwork/gear_base/powered/proc/unlink_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/sigil)
	if(!LAZYFIND(transmission_sigils, sigil))
		return

	LAZYREMOVE(transmission_sigils, sigil)
	sigil.linked_structures -= src
	check_transmission_sigils()

/datum/component/clockwork_trap/powered_structure
	takes_input = TRUE

/datum/component/clockwork_trap/powered_structure/trigger()
	if(!..())
		return

	var/obj/structure/destructible/clockwork/gear_base/powered/structure = parent
	if(!istype(structure))
		return

	structure.try_toggle_power()
