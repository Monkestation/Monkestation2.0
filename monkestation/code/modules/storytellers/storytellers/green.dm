/datum/storyteller/green
	name = "The Green"
	desc = "The Green will not create any player antagonists, running only events that don't create antagonists."
	star_colour = STARCOLOUR_ORANGESTAR
	weight = 1
	event_repetition_multiplier = 0.8
	always_votable = TRUE
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.8,
		EVENT_TRACK_MODERATE = 0.8,
		EVENT_TRACK_MAJOR = 0.8,
		EVENT_TRACK_ROLESET = 0,
		STORYTELLER_TRACK_BOOSTER = 0,
		)
	starting_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 0,
		EVENT_TRACK_OBJECTIVES = 1,
		STORYTELLER_TRACK_BOOSTER = 0,
		)
	tag_multipliers = list(TAG_CREW_ANTAG = 0, TAG_TEAM_ANTAG = 0, TAG_OUTSIDER_ANTAG = 0)
	guarantees_roundstart_roleset = FALSE
