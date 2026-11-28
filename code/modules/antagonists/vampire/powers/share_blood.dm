/// Drinks it takes to make a vassal.
#define BLOOD_BOND_DRINKS 3

/datum/action/cooldown/vampire/targeted/share_blood
	name = "Share Blood"
	desc = "Feed your blood to someone you are holding. Three drinks make them your vassal."
	button_icon_state = "power_bleed"
	power_explanation = "Activate Share Blood and click someone next to you to feed them your blood.\n\
		They have to be held: aggressively grabbed by you, restrained, buckled, or unconscious.\n\
		Each drink takes 5 seconds. Drinks keep coming as long as they stay held.\n\
		After two drinks they can no longer bring themselves to attack you.\n\
		The third drink makes them your vassal. Anyone with loyalties elsewhere gets to refuse.\n\
		A bond that never finishes fades after 15 minutes, and a mindshield implant breaks it.\n\
		Using this on your own vassal refills their blood in one drink, and they don't need to be held."
	vampire_power_flags = NONE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	special_flags = VAMPIRE_DEFAULT_POWER
	vitaecost = 30
	cooldown_time = 5 SECONDS
	target_range = 1
	power_activates_immediately = FALSE
	prefire_message = "Select who to feed."

/datum/action/cooldown/vampire/targeted/share_blood/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target_atom))
		return FALSE
	var/mob/living/carbon/target = target_atom
	if(is_own_vassal(target))
		return TRUE
	if(!vampiredatum_power.can_make_vassal(target))
		return FALSE
	if(!is_held(target))
		owner.balloon_alert(owner, "hold [target.p_them()] still first!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/share_blood/fire_targeted_power(atom/target_atom)
	. = ..()
	var/mob/living/carbon/target = target_atom
	if(is_own_vassal(target))
		refill_vassal(target)
	else
		bond_target(target)
	StartCooldown()
	deactivate_power()

/datum/action/cooldown/vampire/targeted/share_blood/proc/is_own_vassal(mob/living/target)
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(target)
	return vassaldatum?.master == vampiredatum_power

/datum/action/cooldown/vampire/targeted/share_blood/proc/is_held(mob/living/target)
	if(owner.pulling == target && owner.grab_state >= GRAB_AGGRESSIVE)
		return TRUE
	return HAS_TRAIT(target, TRAIT_RESTRAINED) || target.buckled || target.stat != CONSCIOUS

/datum/action/cooldown/vampire/targeted/share_blood/proc/refill_vassal(mob/living/carbon/target)
	if(!drink(target, hold_required = FALSE))
		return
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(target)
	vassaldatum.adjust_vitae(VASSAL_VITAE_MAX)
	to_chat(target, span_cult("Your master's blood fills you again."))

/// Keeps feeding them one drink at a time until they're a vassal or the hold breaks.
/datum/action/cooldown/vampire/targeted/share_blood/proc/bond_target(mob/living/carbon/target)
	while(can_pay_cost() && vampiredatum_power.can_make_vassal(target))
		var/datum/status_effect/blood_bond/bond = get_bond(target)
		if(bond?.drinks == BLOOD_BOND_DRINKS - 1 && !ask_consent(target))
			return
		if(!drink(target, hold_required = TRUE))
			return
		bond = get_bond(target) || target.apply_status_effect(/datum/status_effect/blood_bond, vampiredatum_power)
		bond.add_drink()
		if(bond.drinks < BLOOD_BOND_DRINKS)
			continue
		if(vampiredatum_power.make_vassal(target))
			vampiredatum_power.my_clan?.on_vassal_made(owner, target)
			var/datum/weakref/mind_ref = WEAKREF(target.mind)
			if(!(mind_ref in vampiredatum_power.ranked_vassal_minds))
				vampiredatum_power.ranked_vassal_minds += mind_ref
				vampiredatum_power.rank_up(1, ignore_reqs = TRUE, increase_goal = FALSE)
		return

/datum/action/cooldown/vampire/targeted/share_blood/proc/get_bond(mob/living/target)
	for(var/datum/status_effect/blood_bond/bond in target.status_effects)
		if(bond.vampire == vampiredatum_power)
			return bond

/// Antags get to refuse the last drink. Moon heretics never get asked, so the vampire walks straight into the reversal in make_vassal().
/datum/action/cooldown/vampire/targeted/share_blood/proc/ask_consent(mob/living/carbon/target)
	if(!target.is_antag() || target.has_status_effect(/datum/status_effect/heretic_passive/moon))
		return TRUE
	owner.balloon_alert(owner, "has other loyalties, awaiting [target.p_their()] choice...")
	var/alert_response = tgui_alert(
		user = target,
		message = "[owner] is feeding you [owner.p_their()] blood for the third time. Do you want to give in to the addiction? \n\
			You will not lose your current objectives, but they come second to the will of your new master!",
		title = "Give in to the addiction?",
		buttons = list("Accept", "Refuse"),
		timeout = 15 SECONDS,
		autofocus = TRUE,
	)
	if(alert_response == "Accept")
		return TRUE
	target.balloon_alert_to_viewers("refused the blood!")
	return FALSE

/// One drink. Getting interrupted costs nothing.
/datum/action/cooldown/vampire/targeted/share_blood/proc/drink(mob/living/carbon/target, hold_required)
	owner.visible_message(
		span_danger("[owner] opens a vein on [owner.p_their()] wrist and presses it to [target]'s mouth!"),
		span_notice("You open a vein and press it to [target]'s mouth."),
		ignored_mobs = target,
	)
	to_chat(target, span_userdanger("[owner] presses a bleeding wrist to your mouth!"))
	var/datum/callback/hold_check = hold_required ? CALLBACK(src, PROC_REF(is_held), target) : null
	if(!do_after(owner, 5 SECONDS, target, extra_checks = hold_check))
		owner.balloon_alert(owner, "interrupted!")
		return FALSE
	pay_cost()
	log_combat(owner, target, "fed vampire blood to")
	target.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)
	return TRUE

#undef BLOOD_BOND_DRINKS

/// A half-finished bond with one vampire. One of these per vampire who has fed you.
/datum/status_effect/blood_bond
	id = "blood_bond"
	duration = 15 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	/// The vampire whose blood this is.
	var/datum/antagonist/vampire/vampire
	/// How many drinks they've had from that vampire.
	var/drinks = 0

/datum/status_effect/blood_bond/on_creation(mob/living/new_owner, datum/antagonist/vampire/vampire)
	src.vampire = vampire
	return ..()

/datum/status_effect/blood_bond/on_apply()
	RegisterSignals(vampire, list(COMSIG_QDELETING, COMSIG_VAMPIRE_FINAL_DEATH), PROC_REF(on_vampire_gone))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD), PROC_REF(on_mindshield))
	return TRUE

/datum/status_effect/blood_bond/on_remove()
	UnregisterSignal(vampire, list(COMSIG_QDELETING, COMSIG_VAMPIRE_FINAL_DEATH))
	UnregisterSignal(owner, list(
		SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD),
		COMSIG_LIVING_EARLY_UNARMED_ATTACK,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_TRYING_TO_FIRE_GUN,
	))

/datum/status_effect/blood_bond/Destroy()
	. = ..()
	vampire = null

/datum/status_effect/blood_bond/proc/add_drink()
	drinks++
	duration = world.time + initial(duration)
	switch(drinks)
		if(1)
			owner.add_mood_event("blood_bond", /datum/mood_event/blood_bond)
			to_chat(owner, span_awe("That blood was... sweet. You want more of it."))
		if(2)
			RegisterSignal(owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
			RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_item_attack))
			RegisterSignal(owner, COMSIG_MOB_TRYING_TO_FIRE_GUN, PROC_REF(on_fire_gun))
			var/list/msg = list()
			msg += span_cultlarge("You crave [vampire.owner.current]'s blood.")
			msg += span_cult("You can't bring yourself to hurt [vampire.owner.current.p_them()]. One more drink and you will belong to [vampire.owner.current.p_them()].")
			msg += span_cult("You can still run, talk, and tell others what happened.")
			to_chat(owner, boxed_message(msg.Join("\n")))

/datum/status_effect/blood_bond/proc/refuse_attack()
	owner.balloon_alert(owner, "you can't bring yourself to!")

/datum/status_effect/blood_bond/proc/on_unarmed_attack(mob/living/source, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(target != vampire.owner.current || !(source.istate & ISTATE_HARM))
		return NONE
	refuse_attack()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/blood_bond/proc/on_item_attack(mob/living/source, mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers, obj/item/weapon)
	SIGNAL_HANDLER
	if(target_mob != vampire.owner.current || (weapon.item_flags & NOBLUDGEON))
		return NONE
	if(!(weapon.item_flags & NEEDS_PERMIT) && !(source.istate & ISTATE_HARM) && weapon.force <= 0)
		return NONE
	refuse_attack()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/blood_bond/proc/on_fire_gun(mob/living/source, obj/item/gun/gun, atom/target, flag, params)
	SIGNAL_HANDLER
	if(target != vampire.owner.current)
		return NONE
	refuse_attack()
	return COMPONENT_CANCEL_GUN_FIRE

/datum/status_effect/blood_bond/proc/on_vampire_gone()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/blood_bond/proc/on_mindshield()
	SIGNAL_HANDLER
	qdel(src)
