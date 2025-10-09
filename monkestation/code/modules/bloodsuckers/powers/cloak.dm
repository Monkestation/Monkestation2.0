/datum/action/cooldown/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Cloak of Darkness:\n\
		Activate this Power in the shadows and you will slowly turn nearly invisible.\n\
		While using Cloak of Darkness, you are unable to sprint.\n\
		Additionally, while Cloak is active, you are completely invisible to the AI.\n\
		If you attack anyone or get attacked, your cloak will break and you will be revealed.\n\
		Higher levels will increase how invisible you are, and reduce the cooldown to cloak again should it be broken."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 5
	constant_bloodcost = 0.2
	cooldown_time = 10 SECONDS

/datum/action/cooldown/bloodsucker/cloak/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/user = owner

	user.add_traits(list(TRAIT_NO_SPRINT, TRAIT_UNKNOWN), REF(src))
	user.AddElement(/datum/element/digitalcamo)

	user.AddElement(/datum/element/relay_attackers)
	RegisterSignal(user, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignals(user, list(COMSIG_USER_ITEM_INTERACTION, COMSIG_USER_ITEM_INTERACTION_SECONDARY), PROC_REF(on_use_item))
	RegisterSignals(user, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK), PROC_REF(on_unarmed_attack))

	user.balloon_alert(user, "cloak turned on.")

/datum/action/cooldown/bloodsucker/cloak/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/user = owner
	animate(user, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)

/datum/action/cooldown/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed due to you falling unconcious!"))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/DeactivatePower()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)

	user.RemoveElement(/datum/element/digitalcamo)
	user.remove_traits(list(TRAIT_NO_SPRINT, TRAIT_UNKNOWN), REF(src))

	user.RemoveElement(/datum/element/relay_attackers)
	UnregisterSignal(user, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_USER_ITEM_INTERACTION,
		COMSIG_USER_ITEM_INTERACTION_SECONDARY,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_HUMAN_MELEE_UNARMED_ATTACK,
	))

	user.balloon_alert(user, "cloak turned off.")
	return ..()

/datum/action/cooldown/bloodsucker/cloak/proc/on_use_item(mob/living/source, atom/target, obj/item/weapon, click_parameters)
	SIGNAL_HANDLER
	if(source == target)
		return
	if(istype(weapon, /obj/item/gun) || weapon.force)
		DeactivatePower()

/datum/action/cooldown/bloodsucker/cloak/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(source != target && proximity && isliving(target) && (source.istate & (ISTATE_HARM | ISTATE_SECONDARY)))
		DeactivatePower()

/datum/action/cooldown/bloodsucker/cloak/proc/on_attacked(mob/living/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(source != attacker)
		DeactivatePower()
