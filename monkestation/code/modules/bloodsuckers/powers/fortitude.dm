/datum/action/cooldown/bloodsucker/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Fortitude:\n\
		Activating Fortitude will provide pierce, shove, and dismember immunity.\n\
		However, everyone around you will know that you have activated it, and you will be unable to sprint.\n\
		You will additionally gain resistance to Brute and Stamina damage, starting at 20%, increasing 5% per level, and maxing at 50%. \n\
		At level 4, you gain additional resistance to stun batons, and will ignore their staggering effects."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY
	purchase_flags = BLOODSUCKER_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 10
	cooldown_time = 10 SECONDS
	constant_bloodcost = 3

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
	)
	/// Upgraded traits granted by fortitude.
	var/static/list/upgraded_traits = list(TRAIT_BATON_RESISTANCE)

	///How much resistance is provided by the current use of fortitude, so it can be adjusted correctly when fortitude ends.
	///Needs to be tracked separately from level_current to avoid exploits.
	var/fortitude_resist
	///Reference to the visual icon of the fortitude power.
	var/atom/movable/flick_visual/icon_ref

/datum/action/cooldown/bloodsucker/fortitude/ActivatePower(trigger_flags)
	. = ..()

	// Traits & Effects
	owner.add_traits(base_traits, FORTITUDE_TRAIT)

	//Everyone around us can tell we are using fortitude.
	icon_ref = owner.do_power_icon_animation("power_fortitude")

	if(level_current >= 4)
		owner.add_traits(upgraded_traits, FORTITUDE_TRAIT)
		owner.visible_message(span_warning("[owner]'s skin turns extremely hard! Batons will be extremely ineffective!"))
	else
		owner.visible_message(span_warning("[owner]'s skin hardens!"))

	var/mob/living/carbon/human/bloodsucker_user = owner

	fortitude_resist = max(0.5, 0.85 - level_current * 0.05)

	bloodsucker_user.physiology.brute_mod *= fortitude_resist
	bloodsucker_user.physiology.stamina_mod *= fortitude_resist


/datum/action/cooldown/bloodsucker/fortitude/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/carbon/user = owner

	/// We don't want people using fortitude being able to use vehicles
	if(istype(user.buckled, /obj/vehicle))
		user.buckled.unbuckle_mob(src, force=TRUE)

/datum/action/cooldown/bloodsucker/fortitude/DeactivatePower()
	var/mob/living/carbon/human/bloodsucker_user = owner
	bloodsucker_user.physiology.brute_mod /= fortitude_resist
	bloodsucker_user.physiology.stamina_mod /= fortitude_resist

	// Remove Traits & Effects
	owner.remove_traits(base_traits + upgraded_traits, FORTITUDE_TRAIT)

	owner.visible_message(span_warning("[owner]'s skin softens & returns to normal."))
	owner.remove_power_icon_animation(icon_ref)
	icon_ref = null

	return ..()
