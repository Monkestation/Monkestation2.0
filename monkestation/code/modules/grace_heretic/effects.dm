/datum/status_effect/pacify/grace_honor
	id = "pacify"
	alert_type = null
	duration = 2.5 SECONDS
	var/had_chunkyfingers = FALSE

/datum/status_effect/pacify/grace_honor/on_apply()
	if(HAS_TRAIT(owner, TRAIT_CHUNKYFINGERS))
		had_chunkyfingers = TRUE
		ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	else
		ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
		ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/pacify/grace_honor/on_remove()
	if(!had_chunkyfingers)
		REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
