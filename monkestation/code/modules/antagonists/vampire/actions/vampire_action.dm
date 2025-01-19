/datum/action/cooldown/vampire
	name = "Please ahelp"
	desc = "If you see this ahelp IMMEDIATELY"
	cooldown_time = 0.5 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'monkestation/icons/vampires/actions_vampire.dmi'
	background_icon = 'monkestation/icons/vampires/actions_vampire.dmi'
	background_icon_state = "vamp_power_off"
	base_background_icon_state = "vamp_power_off"
	active_background_icon_state = "vamp_power_on"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	/// How much lifeforce it costs to use this action.
	var/life_cost = 0

	/// How much lifeforce this action uses over time while active. Toggle-only.
	var/constant_life_cost = 0

	/// Override for constant_life_cost that makes the ability require lifeforce even with both costs being 0.
	var/has_custom_life_cost = FALSE

	/// Whether this action is a toggle or not.
	var/toggleable = FALSE

	/// If toggleable, whether or not this action is currently toggled on. Use is_active() for checks.
	var/active = FALSE

	/// Whether this ability can be activated or toggled on during masquerade.
	var/works_in_masquerade = FALSE

	/// Whether this ability should call toggle_on when first granted.
	/// Set to FALSE after the first grant.
	var/starts_active = FALSE

	/// The current human mob that owns this action.
	var/mob/living/carbon/human/user

	/// The vampire antag datum that owns this action. Also the target of the action.
	var/datum/antagonist/vampire/vampire

/datum/action/cooldown/vampire/New(Target)
	. = ..()
	vampire = Target
	if(!istype(vampire))
		CRASH("Vampire action created without a linked vampire antag datum.")
	RegisterSignal(vampire, COMSIG_VAMPIRE_LIFEFORCE_CHANGED, PROC_REF(on_lifeforce_changed))
	RegisterSignal(vampire, COMSIG_VAMPIRE_MASQUERADE, PROC_REF(on_masquerade))

/datum/action/cooldown/vampire/Destroy() // assumes that the action target is always the vampire antag datum, so this should be called if vampire is qdel'd
	UnregisterSignal(vampire, list(COMSIG_VAMPIRE_LIFEFORCE_CHANGED, COMSIG_VAMPIRE_MASQUERADE))
	vampire = null
	user = null
	return ..()

/datum/action/cooldown/vampire/Grant(mob/granted_to)
	. = ..()

	if(!ishuman(granted_to))
		CRASH("Vampire action granted to non-human mob.")
	user = granted_to

	RegisterSignal(granted_to, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	if(toggleable && starts_active)
		starts_active = FALSE
		toggle_on()

/datum/action/cooldown/vampire/Remove(mob/removed_from)
	UnregisterSignal(removed_from, COMSIG_LIVING_DEATH)

	if(toggleable && is_active())
		toggle_off() // doesn't matter if can_toggle_off would return false here, just do it anyway
	if(user == removed_from)
		user = null

	return ..()

/datum/action/cooldown/vampire/IsAvailable(feedback)
	if(!..())
		return FALSE

	if(!works_in_masquerade && vampire.masquerade_enabled)
		if(feedback)
			owner.balloon_alert(owner, "in masquerade!")
		return FALSE

	if(toggleable && is_active())
		return can_toggle_off(feedback)

	if(vampire.lifeforce < life_cost)
		if(feedback)
			owner.balloon_alert(owner, "needs [life_cost] lifeforce!")
		return FALSE

	if(toggleable && (has_custom_life_cost && vampire.lifeforce == 0) || (vampire.lifeforce < constant_life_cost))
		if(feedback)
			owner.balloon_alert(owner, "needs lifeforce!")
		return FALSE

	if(toggleable && !is_active())
		return can_toggle_on(feedback)

	return TRUE

/datum/action/cooldown/vampire/proc/on_lifeforce_changed(datum/source, old_amount, new_amount)
	SIGNAL_HANDLER
	if(new_amount == 0 && (has_custom_life_cost || constant_life_cost) && toggleable && can_toggle_off())
		toggle_off()
	update_button()

/datum/action/cooldown/vampire/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if((check_flags & AB_CHECK_CONSCIOUS) && toggleable && can_toggle_off())
		toggle_off()
	update_button()

/datum/action/cooldown/vampire/proc/on_masquerade(datum/source, enabled)
	SIGNAL_HANDLER
	if(enabled && !works_in_masquerade && toggleable && can_toggle_off())
		toggle_off()
	update_button()

/datum/action/cooldown/vampire/proc/update_button() // not named update_button_status as thats an action level proc, this is a signal handler for that
	SIGNAL_HANDLER
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/vampire/Activate(atom/target)
	if(life_cost && !(toggleable && is_active())) // deactivation shouldn't cost anything
		vampire.adjust_lifeforce(-life_cost)
	if(!toggleable)
		return ..()
	if(is_active())
		toggle_off()
	else
		toggle_on()

/// Normally just returns 'active', but can be used to override it if necessary. Used for checks instead of 'active' itself.
/datum/action/cooldown/vampire/proc/is_active()
	return active

/// Actually toggles the action on. Use on_toggle_on() for subtypes if possible.
/datum/action/cooldown/vampire/proc/toggle_on()
	SIGNAL_HANDLER
	if(is_active())
		return
	active = TRUE
	if(constant_life_cost)
		vampire.set_lifeforce_change(VAMPIRE_CONSTANT_LIFEFORCE_COST(src), -constant_life_cost)
	INVOKE_ASYNC(src, PROC_REF(on_toggle_on))
	build_all_button_icons()
	StartCooldown(0.5 SECONDS)

/// To be implemented by subtypes. Called from toggle_on after active is set to TRUE.
/datum/action/cooldown/vampire/proc/on_toggle_on()

/// To be implemented by subtypes. Whether or not the action can be toggled on right now.
/datum/action/cooldown/vampire/proc/can_toggle_on(feedback)
	return TRUE

/// Actually toggles the action on. Use on_toggle_off() for subtypes if possible.
/datum/action/cooldown/vampire/proc/toggle_off()
	SIGNAL_HANDLER
	if(!is_active())
		return
	active = FALSE
	vampire.clear_lifeforce_change(VAMPIRE_CONSTANT_LIFEFORCE_COST(src))
	INVOKE_ASYNC(src, PROC_REF(on_toggle_off))
	build_all_button_icons()
	StartCooldown(cooldown_time)

/// To be implemented by subtypes. Called from toggle_off after active is set to FALSE.
/datum/action/cooldown/vampire/proc/on_toggle_off()

/// To be implemented by subtypes. Whether or not the action can be toggled off right now.
/datum/action/cooldown/vampire/proc/can_toggle_off(feedback)
	return TRUE

/datum/action/cooldown/vampire/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return ..() || is_active()
