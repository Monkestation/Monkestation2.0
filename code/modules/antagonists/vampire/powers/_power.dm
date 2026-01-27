/datum/action/cooldown/vampire
	name = "Vampiric Gift"
	desc = "A vampiric gift."
	background_icon = 'icons/vampires/actions_vampire.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/vampires/actions_vampire.dmi'
	button_icon_state = "power_feed"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	/// Cooldown you'll have to wait between each use, decreases depending on level.
	cooldown_time = 2 SECONDS

	active_background_icon_state = "vamp_power_on"
	base_background_icon_state = "vamp_power_off"

	/// A sort of tutorial text found in the Antagonist tab.
	var/power_explanation = "Use this power to do... something"
	/// The owner's vampire datum
	var/datum/antagonist/vampire/vampiredatum_power

	/// The effects on this Power (Toggled/Single Use/Static Cooldown)
	var/vampire_power_flags = BP_AM_TOGGLE | BP_AM_SINGLEUSE | BP_AM_STATIC_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	/// Vampire-specific requirement flags for checks
	var/vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS

	// Special flags you can give to powers. Mainly used for any powers we want them to have by default, so, feed.
	var/special_flags = NONE
	/// If the Power is currently active, differs from action cooldown because of how powers are handled.
	var/currently_active = FALSE
	///Can increase to yield new abilities
	var/level_current = 1
	///The cost to ACTIVATE this Power
	var/vitaecost = 0
	///The cost to MAINTAIN this Power Only used for constant powers
	var/constant_vitaecost = 0
	/// A multiplier for the vitaecost during sol.
	var/sol_multiplier = 1

	///The upgraded version of this Power. 'null' means it's the max level.
	var/upgraded_power = null

// Modify description to add cost.
/datum/action/cooldown/vampire/New(Target)
	. = ..()
	update_desc()

/datum/action/cooldown/vampire/Destroy()
	vampiredatum_power = null
	return ..()

/datum/action/cooldown/vampire/Grant(mob/user)
	. = ..()
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(owner)
	if(vampiredatum)
		vampiredatum_power = vampiredatum

	if(vampire_check_flags & BP_CANT_USE_IN_TORPOR)
		RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_NODEATH), SIGNAL_REMOVETRAIT(TRAIT_NODEATH)), PROC_REF(update_status_on_signal))
	if(vampire_check_flags & BP_CANT_USE_IN_FRENZY)
		RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_FRENZY), SIGNAL_REMOVETRAIT(TRAIT_FRENZY)), PROC_REF(update_status_on_signal))
	if(vampire_check_flags & BP_CANT_USE_WHILE_INCAPACITATED)
		RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED)), PROC_REF(update_status_on_signal))
	if(vampire_check_flags & BP_CANT_USE_WHILE_UNCONSCIOUS)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/vampire/Remove(mob/removed_from)
	if(owner)
		UnregisterSignal(owner, list(
			COMSIG_MOB_STATCHANGE,
			SIGNAL_ADDTRAIT(TRAIT_NODEATH),
			SIGNAL_ADDTRAIT(TRAIT_FRENZY),
			SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
			SIGNAL_REMOVETRAIT(TRAIT_NODEATH),
			SIGNAL_REMOVETRAIT(TRAIT_FRENZY),
			SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED),
		))
	return ..()

/datum/action/cooldown/vampire/is_action_active(atom/movable/screen/movable/action_button/current_button)
	if(currently_active)
		return TRUE
	return ..()

//This is when we CLICK on the ability Icon, not USING.
/datum/action/cooldown/vampire/Activate(atom/target)
	if(currently_active)
		deactivate_power()
		return FALSE
	if(!can_pay_cost() || !can_use())
		return FALSE
	pay_cost()
	activate_power()
	if(!(vampire_power_flags & BP_AM_TOGGLE) || !currently_active)
		StartCooldown()

	return TRUE

/datum/action/cooldown/vampire/proc/update_desc()
	desc = initial(desc)
	if(vitaecost > 0)
		desc += "<br><br><b>COST:</b> [vitaecost] Blood"
	if(constant_vitaecost > 0)
		desc += "<br><br><b>CONSTANT COST:</b><i> [constant_vitaecost] Blood.</i>"
	if(vampire_power_flags & BP_AM_SINGLEUSE)
		desc += "<br><br><b>SINGLE USE:</br><i> Can only be used once per night.</i>"

/datum/action/cooldown/vampire/proc/can_pay_cost()
	if(QDELETED(owner))
		return FALSE

	// Check if we have enough blood for non-vampires
	if(!vampiredatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD) && living_owner.blood_volume < vitaecost)
			living_owner.balloon_alert(living_owner, "not enough blood.")
			return FALSE

		return TRUE

	// Have enough blood? Vampires in a Frenzy don't need to pay them
	if(owner.has_status_effect(/datum/status_effect/frenzy))
		return TRUE
	if(vampiredatum_power.current_vitae < vitaecost)
		owner.balloon_alert(owner, "not enough blood.")
		return FALSE

	return TRUE

///Checks if the Power is available to use.
/datum/action/cooldown/vampire/proc/can_use()
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	// Torpor?
	if((vampire_check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(carbon_owner, TRAIT_TORPOR))
		to_chat(carbon_owner, span_warning("Not while you're in Torpor."))
		return FALSE
	// Frenzy?
	if((vampire_check_flags & BP_CANT_USE_IN_FRENZY) && owner.has_status_effect(/datum/status_effect/frenzy))
		to_chat(carbon_owner, span_warning("You cannot use powers while in a Frenzy!"))
		return FALSE
	// Stake?
	if((vampire_check_flags & BP_CANT_USE_WHILE_STAKED) && vampiredatum_power?.check_if_staked())
		to_chat(carbon_owner, span_warning("You have a stake in your chest! Your powers are useless."))
		return FALSE
	// Conscious? -- We use our own (AB_CHECK_CONSCIOUS) here so we can control it more, like the error message.
	if((vampire_check_flags & BP_CANT_USE_WHILE_UNCONSCIOUS) && carbon_owner.stat != CONSCIOUS)
		to_chat(carbon_owner, span_warning("You can't do this while you are unconcious!"))
		return FALSE
	// Incapacitated?
	if((vampire_check_flags & BP_CANT_USE_WHILE_INCAPACITATED) && carbon_owner.incapacitated(IGNORE_RESTRAINTS | IGNORE_GRAB))
		to_chat(carbon_owner, span_warning("Not while you're incapacitated!"))
		return FALSE
	// Constant Cost (out of blood)
	if(constant_vitaecost > 0 && vampiredatum_power?.current_vitae <= 0)
		to_chat(carbon_owner, span_warning("You don't have the blood to upkeep [src]."))
		return FALSE
	// Sol check
	if((vampire_check_flags & BP_CANT_USE_DURING_SOL) && carbon_owner.has_status_effect(/datum/status_effect/vampire_sol))
		to_chat(carbon_owner, span_warning("You can't use [src] during Sol!"))
		return FALSE
	// Silver cuffed?
	if(!(vampire_check_flags & BP_ALLOW_WHILE_SILVER_CUFFED) && owner.has_status_effect(/datum/status_effect/silver_cuffed))
		owner.balloon_alert(owner, "the silver cuffs on your wrists prevent you from using your powers!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/proc/pay_cost()
	// Vassals get powers too!
	if(!vampiredatum_power)
		var/mob/living/living_owner = owner
		if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD))
			living_owner.blood_volume -= vitaecost
		return

	// Vampires in a Frenzy don't have enough Blood to pay it, so just don't.
	if(!owner.has_status_effect(/datum/status_effect/frenzy))
		vampiredatum_power.current_vitae -= vitaecost
		vampiredatum_power.update_hud()

/datum/action/cooldown/vampire/proc/activate_power()
	currently_active = TRUE
	if(vampire_power_flags & BP_AM_TOGGLE)
		RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(UsePower))

	owner.log_message("used [src][vitaecost != 0 ? " at the cost of [vitaecost]" : ""].", LOG_ATTACK, color="red")
	build_all_button_icons(UPDATE_BUTTON_NAME | UPDATE_BUTTON_BACKGROUND)

/datum/action/cooldown/vampire/proc/deactivate_power()
	if(!currently_active) //Already inactive? Return
		return

	if(vampire_power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	if(vampire_power_flags & BP_AM_SINGLEUSE)
		remove_after_use()
		return

	currently_active = FALSE
	StartCooldown()
	build_all_button_icons(UPDATE_BUTTON_NAME | UPDATE_BUTTON_BACKGROUND)

/// Used by powers that are continuously active (That have BP_AM_TOGGLE flag)
/datum/action/cooldown/vampire/proc/UsePower()
	if(!continue_active()) // We can't afford the Power? Deactivate it.
		deactivate_power()
		return FALSE

	// IF USER IS UNCONSCIOUS
	if((vampire_power_flags & BP_AM_COSTLESS_UNCONSCIOUS) && owner.stat != CONSCIOUS)
		return TRUE
	else
		if(vampiredatum_power)
			vampiredatum_power.AdjustBloodVolume(-constant_vitaecost)
		else
			var/mob/living/living_owner = owner
			if(!HAS_TRAIT(living_owner, TRAIT_NOBLOOD))
				living_owner.blood_volume = max(living_owner.blood_volume - constant_vitaecost, 0)
	return TRUE

/// Checks to make sure this power can stay active
/datum/action/cooldown/vampire/proc/continue_active()
	if(QDELETED(owner))
		return FALSE
	if (!(check_flags & BP_ALLOW_WHILE_SILVER_CUFFED) && owner.has_status_effect(/datum/status_effect/silver_cuffed))
		return FALSE
	if(vampiredatum_power && vampiredatum_power.current_vitae < constant_vitaecost)
		return FALSE

	return TRUE

/// Used to unlearn Single-Use Powers
/datum/action/cooldown/vampire/proc/remove_after_use()
	vampiredatum_power?.powers -= src
	Remove(owner)

// If there's a mortal in line of sight, we get a masq infraction
/datum/action/cooldown/vampire/proc/check_witnesses(mob/living/target)
	var/turf/our_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	var/is_dark = min(GET_SIMPLE_LUMCOUNT(our_turf), GET_SIMPLE_LUMCOUNT(target_turf)) <= SHADOW_SPECIES_DIM_LIGHT
	for(var/mob/living/watcher in oviewers(6, owner) - target)
		if(!vampiredatum_power.is_masq_watcher(watcher))
			continue
		if(is_dark && !watcher.Adjacent(owner) && !watcher.Adjacent(target))
			continue
		if(!watcher.incapacitated(IGNORE_RESTRAINTS))
			watcher.face_atom(owner)

		watcher.do_alert_animation(watcher)
		playsound(watcher, 'sound/machines/chime.ogg', 50, FALSE, -5)
		vampiredatum_power.give_masquerade_infraction()
		break
