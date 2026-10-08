///Action for a single "overlord" mob to control various "hosts", EG AIs and their shells(not implemented yet)
/datum/action/control_host
	name = "Control Host Body"
	desc = "Take control of a host body."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "god_transmit"
	///Should we return our owner to the overlord mob if it dies
	var/kill_on_overlord_death = TRUE
	///Should a host be lost when it dies
	var/lose_host_on_death = TRUE
	///The text sent when we lack a host are are triggered
	var/no_host_text = "no host!"
	///The mind of our overlord mob
	var/datum/mind/overlord_mind
	///The mob we transfer to when triggered
	var/mob/host
	///Ref to our return action, initialized as an instance of its initial value
	var/datum/action/return_to_overlord/return_action = /datum/action/return_to_overlord

/datum/action/control_host/New(Target)
	. = ..()
	return_action = new return_action()
	RegisterSignal(return_action, COMSIG_ACTION_TRIGGER, PROC_REF(return_action_triggered))

/datum/action/control_host/Destroy()
	overlord_mind = null
	lose_host(host)
	UnregisterSignal(return_action, COMSIG_ACTION_TRIGGER)
	QDEL_NULL(return_action)
	return ..()

/datum/action/control_host/Grant(mob/grant_to)
	. = ..()
	overlord_mind = grant_to.mind
	if(isliving(grant_to) && kill_on_overlord_death)
		RegisterSignal(grant_to, COMSIG_LIVING_DEATH, PROC_REF(overlord_died))

/datum/action/control_host/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	overlord_mind = null

/datum/action/control_host/IsAvailable(feedback)
	if(!check_for_host())
		if(feedback)
			to_chat(owner, span_warning(no_host_text))
		return FALSE
	if(kill_on_overlord_death && owner.stat == DEAD)
		if(feedback)
			owner.balloon_alert(owner, "dead!")
		return FALSE
	return ..()

/datum/action/control_host/Trigger(trigger_flags)
	if(!owner.mind || !..())
		return FALSE

	transfer_to_host(host)

/datum/action/control_host/proc/check_for_host()
	return host

/datum/action/control_host/proc/gain_host(mob/new_host)
	host = new_host
	ADD_TRAIT(new_host, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	RegisterSignal(new_host, COMSIG_QDELETING, PROC_REF(host_died_or_destroyed))
	if(lose_host_on_death && isliving(new_host))
		RegisterSignal(new_host, COMSIG_LIVING_DEATH, PROC_REF(host_died_or_destroyed))

///signal handler wrapper for lose_host()
/datum/action/control_host/proc/host_died_or_destroyed(mob/gone)
	SIGNAL_HANDLER
	lose_host(gone)

/datum/action/control_host/proc/lose_host(mob/removed, silent)
	host = null
	REMOVE_TRAIT(removed, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	UnregisterSignal(removed, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))

	if(overlord_mind)
		if(!silent)
			to_chat(overlord_mind, span_userdanger("Host lost!"))
		if(removed.mind == overlord_mind)
			overlord_mind.transfer_to(owner, TRUE)

/datum/action/control_host/proc/transfer_to_host(mob/new_host)
	if(!new_host)
		return

	owner.mind.transfer_to(new_host, TRUE)
	return_action.Grant(new_host)
	ADD_TRAIT(owner, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	REMOVE_TRAIT(new_host, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

/datum/action/control_host/proc/return_action_triggered(datum/action/triggered)
	SIGNAL_HANDLER
	if(overlord_mind != owner.mind)
		overlord_mind.transfer_to(owner, TRUE)
		ADD_TRAIT(triggered.owner, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
		REMOVE_TRAIT(owner, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

/datum/action/control_host/proc/overlord_died(mob/overlord)
	SIGNAL_HANDLER
	if(owner.mind != overlord_mind)
		overlord_mind.transfer_to(owner)

//dummy action that we just listen for it being triggered
/datum/action/return_to_overlord
	name = "Control Original Body"
	desc = "Return to your original body."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "god_transmit"
