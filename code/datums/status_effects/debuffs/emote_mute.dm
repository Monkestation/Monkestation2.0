/datum/status_effect/emote_mute
	id = "emote_muted"
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/emote_mute/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/emote_mute/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_effect))
	ADD_TRAIT(owner, TRAIT_EMOTEMUTE, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/emote_mute/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	REMOVE_TRAIT(owner, TRAIT_EMOTEMUTE, TRAIT_STATUS_EFFECT(id))

/// Signal proc that self-deletes
/datum/status_effect/emote_mute/proc/clear_effect(mob/living/source)
	SIGNAL_HANDLER

	qdel(src)
