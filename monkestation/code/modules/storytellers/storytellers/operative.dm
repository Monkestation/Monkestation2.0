/datum/storyteller/operative
	name = "The Operative"
	desc = "The Operative has a lower capacity for threats but will rapidly replace those destroyed."
	welcome_text = "The eyes of multiple organizations have been set on the station."
	starting_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1.2,
		EVENT_TRACK_OBJECTIVES = 1
		)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 0.8,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1.3,
		EVENT_TRACK_OBJECTIVES = 1
		)
	tag_multipliers = list(TAG_ALIEN = 0.4, TAG_CREW_ANTAG = 1.1)
	population_min = 50
	weight = 1
	base_antag_points = -15
