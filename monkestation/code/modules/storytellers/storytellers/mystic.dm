/datum/storyteller/mystic
	name = "The Mystic"
	desc = "The Mystic gives events from beyond the veil, some of which may even be magic in nature."
	tag_multipliers = list(TAG_SPOOKY = 1.2, TAG_MAGICAL = 1.5, TAG_SPACE = 1.1, TAG_MUNDANE = 0.4)
	weight = 2
	population_min = 40 //all current magic antags are very murder and/or pop-based (eg: cult, wizard, heretic) change if we get less murdery magic antags

// do NOT run any mundane antags roundstart at all.
/datum/storyteller/mystic/can_run_event(datum/round_event_control/event)
	if(event.roundstart && (TAG_MUNDANE in event.tags))
		return FALSE
	return TRUE
