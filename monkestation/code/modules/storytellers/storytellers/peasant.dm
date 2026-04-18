//credit to absolucy for the design
/datum/storyteller/peasant
	name = "The Peasant"
	desc = "The Peasant prefers plain, internal conflict and won't give overly chaotic events. A nice breather, hopefully less chaotic while still allowing things to happen."
	event_repetition_multiplier = 0.4
	tag_multipliers = list(
		TAG_CREW_ANTAG = 1.2,
		TAG_EXTERNAL = 0.8,
		TAG_ALIEN = 0.5, // "alien" events tend to be more chaotic / destructive
		TAG_OUTSIDER_ANTAG = 0.2,
		TAG_DESTRUCTIVE = 0.2,
	)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1.6,
		EVENT_TRACK_MODERATE = 0.6,
		EVENT_TRACK_MAJOR = 0.6,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
	)
	weight = 2
	population_max = 50

/datum/storyteller/peasant/can_run_event(datum/round_event_control/event)
	if(event.shared_occurence_type == SHARED_HIGH_THREAT)
		return FALSE
	if(event.roundstart && !(TAG_CREW_ANTAG in event.tags)) //are there even any low threat external roundstarts?
		return FALSE
	return TRUE
