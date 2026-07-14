#define ICON_STATE_CAMOUFLAGE_ON "camuflage_off"
#define ICON_STATE_CAMOUFLAGE_OFF "camuflage_on"

/datum/action/cooldown/optical_camouflage
	name = "Toggle camouflage"
	desc = "Blend in with your surroundings and become transparent."
	cooldown_time = 10 SECONDS

	button_icon = 'icons/mob/actions/actions_nabber.dmi'
	var/active = FALSE
	var/camouflage_alpha = 60 //ORIGINALLY: 35

/datum/action/cooldown/optical_camouflage/Activate(atom/target)
	. = ..()
	if(!owner)
		return FALSE

	if(isdead(owner) || owner.incapacitated())
		owner.balloon_alert(owner, "Incapacitated!")
		return FALSE

	if(active)
		remove_camouflage()
		return TRUE

/* - Disabled until the effect is re-enabled - *
	if(owner.has_status_effect(/datum/status_effect/nabber_combat))
		owner.balloon_alert(owner, "Can't now!")
		return FALSE
*/

	RegisterSignals(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED, COMSIG_ATOM_BULLET_ACT, COMSIG_LIVING_EARLY_UNARMED_ATTACK, COMSIG_LIVING_MOB_BUMP, COMSIG_HUMAN_BURNING), PROC_REF(remove_camouflage))
	enter_camouflage()
	return TRUE

/datum/action/cooldown/optical_camouflage/Grant(mob/granted_to)
	. = ..()
	button_icon_state = ICON_STATE_CAMOUFLAGE_OFF

/datum/action/cooldown/optical_camouflage/Destroy()
	. = ..()
	if(!owner)
		return
	remove_camouflage()

/datum/action/cooldown/optical_camouflage/proc/enter_camouflage()
	owner.visible_message(span_notice("[owner] starts hypnotically shifting colours, before eventually blending in with their surroundings"), span_notice("You blend in with your surroundings."), span_hear("You hear a low hiss as [owner] begins to shimmer."))

	animate(owner, alpha = camouflage_alpha, time = cooldown_time)

	button_icon_state = ICON_STATE_CAMOUFLAGE_ON
	owner.update_action_buttons()

	active = TRUE

/datum/action/cooldown/optical_camouflage/proc/remove_camouflage()
	owner.visible_message(span_notice("[owner] stops blending in with their surroundings."), span_notice("You become visible again."), span_hear("You hear a low hiss as [owner] shimmers into visibility."))
	animate(owner, alpha = 255, time = 1.5 SECONDS)

	UnregisterSignal(owner, list(COMSIG_LIVING_EARLY_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED, COMSIG_LIVING_MOB_BUMP, COMSIG_HUMAN_BURNING))

	button_icon_state = ICON_STATE_CAMOUFLAGE_OFF
	owner.update_action_buttons()

	active = FALSE

#undef ICON_STATE_CAMOUFLAGE_ON
#undef ICON_STATE_CAMOUFLAGE_OFF
