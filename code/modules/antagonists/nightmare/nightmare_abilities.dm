/datum/action/cooldown/spell/jaunt/shadow_walk
	check_flags = AB_CHECK_PHASED

/datum/action/cooldown/spell/jaunt/shadow_walk/IsAvailable(feedback)
	if(!..())
		return FALSE
	if(owner.stat >= UNCONSCIOUS)
		if(feedback)
			owner.balloon_alert(owner, "unconscious!")
		return FALSE
	return TRUE
