/datum/status_effect/silenced
	id = "silent"
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/silenced/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/silenced/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_silence))
	owner.add_traits(list(TRAIT_MUTE, TRAIT_EMOTEMUTE), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/silenced/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.remove_traits(list(TRAIT_MUTE, TRAIT_EMOTEMUTE), TRAIT_STATUS_EFFECT(id))

/// Signal proc that clears any silence we have (self-deletes).
/datum/status_effect/silenced/proc/clear_silence(mob/living/source)
	SIGNAL_HANDLER
	qdel(src)
