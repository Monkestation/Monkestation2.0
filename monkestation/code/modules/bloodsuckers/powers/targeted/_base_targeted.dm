// NOTE: All Targeted spells are Toggles! We just don't bother checking here.
/datum/action/cooldown/bloodsucker/targeted
	power_flags = BP_AM_TOGGLE

	///If set, how far the target has to be for the power to work.
	var/target_range
	///Message sent to chat when clicking on the power, before you use it.
	var/prefire_message
	///Most powers happen the moment you click. Some, like Mesmerize, require time and shouldn't cost you if they fail.
	var/power_activates_immediately = TRUE
	///Is this power LOCKED due to being used?
	var/power_in_use = FALSE

/// Modify description to add notice that this is aimed.
/datum/action/cooldown/bloodsucker/targeted/New(Target)
	desc += "<br>\[<i>Targeted Power</i>\]"
	return ..()

/datum/action/cooldown/bloodsucker/targeted/Remove(mob/living/remove_from)
	. = ..()
	if(remove_from.click_intercept == src)
		unset_click_ability(remove_from)

/datum/action/cooldown/bloodsucker/targeted/ActivatePower(trigger_flags)
	. = ..()

	return TRUE

/datum/action/cooldown/bloodsucker/targeted/Trigger(trigger_flags, atom/target)
	if(active && can_deactivate())
		DeactivatePower()
		return FALSE
	if(!can_pay_cost(owner) || !can_use(owner, trigger_flags))
		return FALSE
	var/datum/action/cooldown/already_set = owner.click_intercept
	if(already_set && already_set != src)
		already_set.unset_click_ability(owner)

	if(prefire_message)
		to_chat(owner, span_announce("[prefire_message]"))

	var/power_needs_to_set_click = ActivatePower(trigger_flags)

	if(!QDELETED(target))
		return InterceptClickOn(owner, null, target)

	if (power_needs_to_set_click)
		return set_click_ability(owner)
	else
		return FALSE

/datum/action/cooldown/bloodsucker/targeted/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	if(active)
		DeactivatePower()

/datum/action/cooldown/bloodsucker/targeted/DeactivatePower()
	if(power_flags & BP_AM_TOGGLE)
		STOP_PROCESSING(SSprocessing, src)
	active = FALSE
	build_all_button_icons()
	unset_click_ability(owner)
//	..() // we don't want to pay cost here

/// Check if target is VALID (wall, turf, or character?)
/datum/action/cooldown/bloodsucker/targeted/proc/CheckValidTarget(atom/target_atom)
	if(target_atom == owner)
		return FALSE
	return TRUE

/// Check if valid target meets conditions
/datum/action/cooldown/bloodsucker/targeted/proc/CheckCanTarget(atom/target_atom)
	if(target_range)
		// Out of Range
		if(!(target_atom in view(target_range, owner)))
			if(target_range > 1) // Only warn for range if it's greater than 1. Brawn doesn't need to announce itself.
				owner.balloon_alert(owner, "out of range.")
			return FALSE
	return istype(target_atom)

/// Click Target
/datum/action/cooldown/bloodsucker/targeted/proc/click_with_power(atom/target_atom, params)
	// CANCEL RANGED TARGET check
	if(power_in_use || !CheckValidTarget(target_atom))
		return FALSE
	// Valid? (return true means DON'T cancel power!)
	if(!can_pay_cost() || !can_use(owner) || !CheckCanTarget(target_atom))
		return TRUE
	power_in_use = TRUE // Lock us into this ability until it successfully fires off. Otherwise, we pay the blood even if we fail.
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		. = FireSecondaryTargetedPower(target_atom, modifiers)
	else
		. = FireTargetedPower(target_atom, modifiers)
	// Skip this part so we can return TRUE right away.
	if(power_activates_immediately)
		power_activated_sucessfully() // Mesmerize pays only after success.
	power_in_use = FALSE

/// Like ActivatePower, but specific to Targeted (and takes an atom input). We don't use ActivatePower for targeted.
/datum/action/cooldown/bloodsucker/targeted/proc/FireTargetedPower(atom/target_atom)
	log_combat(owner, target_atom, "used [name] on")
	return TRUE

/// The power went off! We now pay the cost of the power.
/datum/action/cooldown/bloodsucker/targeted/proc/power_activated_sucessfully(cost_override = 0, cooldown_override)
	unset_click_ability(owner)
	pay_cost(cost_override)
	StartCooldown(cooldown_override)
	DeactivatePower()

/// Called on right click
/datum/action/cooldown/bloodsucker/targeted/proc/FireSecondaryTargetedPower(atom/target, params)
	return FireTargetedPower(target, params)

/datum/action/cooldown/bloodsucker/targeted/InterceptClickOn(mob/living/user, params, atom/target)
	return click_with_power(target, params)

