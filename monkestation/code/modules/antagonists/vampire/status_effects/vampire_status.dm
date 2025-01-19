/datum/status_effect/vampire
	id = STATUS_EFFECT_ID_ABSTRACT
	status_type = STATUS_EFFECT_MULTIPLE // helps with body swaps, accidentally dusting the wrong mob via thirst would be disasterous
	show_duration = TRUE // this is the whole point of these
	/// The vampire antag datum of the user afflicted by this status effect.
	var/datum/antagonist/vampire/vampire
	/// Allows subtypes to tell if they're being removed via mind transfer. Used by frenzy.
	var/is_transfer = FALSE

/datum/status_effect/vampire/on_creation(mob/living/new_owner, datum/antagonist/vampire/new_vampire_datum)
	. = ..()

	if(!new_vampire_datum)
		CRASH("Vampire status effect created without an associated vampire antag datum passed as an argument, someone messed up.")
	vampire = new_vampire_datum
	RegisterSignal(vampire, COMSIG_QDELETING, PROC_REF(self_destruct))

/datum/status_effect/vampire/Destroy()
	vampire = null
	return ..()

/datum/status_effect/vampire/on_apply()
	. = ..()
	RegisterSignal(owner.mind, COMSIG_QDELETING, PROC_REF(self_destruct)) // this is probably pointless but whatever
	RegisterSignal(owner.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))

/datum/status_effect/vampire/on_remove()
	. = ..()
	UnregisterSignal(owner.mind, list(COMSIG_QDELETING, COMSIG_MIND_TRANSFERRED))

/datum/status_effect/vampire/proc/self_destruct()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/vampire/proc/on_mind_transfer(datum/mind/mind, old_body)
	SIGNAL_HANDLER
	is_transfer = TRUE
	var/datum/status_effect/new_effect = mind.current?.apply_status_effect(type, vampire)
	new_effect.duration = duration
	qdel(src)
