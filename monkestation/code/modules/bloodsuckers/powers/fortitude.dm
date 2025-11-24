/datum/action/cooldown/bloodsucker/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Fortitude:\n\
		Activating Fortitude will provide pierce, shove, and dismember immunity for 10 seconds.\n\
		Everyone around you will know that you have activated it.\n\
		You will additionally gain resistance to Brute and Stamina damage, scaling with level, in addition to a weaker resistance to Burn damage.\n\
		While using Fortitude, you will be unable to sprint.\n\
		At level 4, you gain complete stun immunity.\n\
		Higher levels will increase Brute, Burn and Stamina resistance (cap at 4), increase the duration (no cap), and reduce the cooldown. (cap at 5)"
	power_flags = BP_AM_TOGGLE | BP_AM_CUSTOM_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY
	purchase_flags = BLOODSUCKER_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 80 //it's a VERY strong ability that standard vamps do constantly. This way they have some form of blood upkeep during fights.
	cooldown_time = 30 SECONDS
	constant_bloodcost = 0 //literally does nothing at the moment anyway

	var/fortitude_resist // So we can raise and lower your brute resist based on what your level_current WAS.
	/// Base traits granted by fortitude.
	var/static/list/base_traits = list(
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_NO_SPRINT,
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
		TRAIT_HARDLY_WOUNDED
	)
	/// Upgraded traits granted by fortitude.
	var/static/list/upgraded_traits = list(TRAIT_STUNIMMUNE, TRAIT_CANT_STAMCRIT)

	///How long fortitude lasts, in seconds
	var/power_duration = 10
	///How much time is left on this current usage of fortitude, in seconds
	var/seconds_remaining = 10
	///The user's brute mod before fortitude was enabled
	var/atom/movable/flick_visual/icon_ref

/datum/action/cooldown/bloodsucker/fortitude/upgrade_power()
	. = ..()

	power_duration += 1
	seconds_remaining = power_duration

	//Reduce cooldown by 5 seconds for every level, can't go below 10 seconds.
	cooldown_time = max(10 SECONDS, (35 SECONDS - ((5 SECONDS) * level_current)))

/datum/action/cooldown/bloodsucker/fortitude/ActivatePower(trigger_flags)
	. = ..()

	// Traits & Effects
	owner.add_traits(base_traits, FORTITUDE_TRAIT)

	//Everyone around us can tell we are using fortitude.
	icon_ref = owner.do_power_icon_animation("power_fortitude")

	if(level_current >= 4)
		owner.add_traits(upgraded_traits, FORTITUDE_TRAIT)
		owner.visible_message(span_warning("[owner]'s skin turns extremely hard! Stuns will be completely ineffective!"))
	else
		owner.visible_message(span_warning("[owner]'s skin hardens!"))

	var/mob/living/carbon/human/bloodsucker_user = owner
	if(HAS_MIND_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED))
		fortitude_resist = max(0.3, 0.7 - level_current * 0.1)

		bloodsucker_user.physiology.brute_mod *= fortitude_resist
		bloodsucker_user.physiology.burn_mod *= (fortitude_resist * 0.5)
		if(level_current >= 4)
			bloodsucker_user.physiology.stamina_mod *= 0.01
			//has to be done this way so we can keep track of what the stamina mod is. Saving the old modifier opens us up to exploits.
		else
			bloodsucker_user.physiology.stamina_mod *= fortitude_resist

/datum/action/cooldown/bloodsucker/fortitude/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/carbon/user = owner

	/// We don't want people using fortitude being able to use vehicles - Actually this doesn't matter anymore now that you're not forced to walk bicycles are bullshit with or without and using fortitude to become a skateboard terminator would be funny
	//if(istype(user.buckled, /obj/vehicle))
	//	user.buckled.unbuckle_mob(src, force=TRUE)

	if (seconds_remaining > 0)
		seconds_remaining -= seconds_per_tick
		build_all_button_icons(UPDATE_BUTTON_STATUS)
	else
		DeactivatePower()

/datum/action/cooldown/bloodsucker/fortitude/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()

	if (active)
		button.maptext = MAPTEXT_TINY_UNICODE("[round(seconds_remaining, 1)]")

/datum/action/cooldown/bloodsucker/fortitude/DeactivatePower()
	if(ishuman(owner) && HAS_MIND_TRAIT(owner, TRAIT_BLOODSUCKER_ALIGNED))
		var/mob/living/carbon/human/bloodsucker_user = owner
		bloodsucker_user.physiology.brute_mod /= fortitude_resist
		bloodsucker_user.physiology.stamina_mod /= (fortitude_resist - 0.2)
		bloodsucker_user.physiology.burn_mod /= (fortitude_resist * 0.5)

	// Remove Traits & Effects
	owner.remove_traits(base_traits + upgraded_traits, FORTITUDE_TRAIT)

	seconds_remaining = power_duration

	owner.visible_message(span_warning("[owner]'s skin softens & returns to normal."))
	owner.remove_power_icon_animation(icon_ref)
	icon_ref = null

	return ..()
