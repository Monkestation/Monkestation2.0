/datum/storyteller/hermit
	name = "The Hermit"
	desc = "The Hermit will create mostly internal conflict around the station, and rarely any external threats."
	event_repetition_multiplier = 0.7 //Hermit has a smaller event pool, let it repeat a bit more
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.6,
		EVENT_TRACK_MODERATE = 0.55,
		EVENT_TRACK_MAJOR = 0.45,
		EVENT_TRACK_ROLESET = 0.45,
		EVENT_TRACK_OBJECTIVES = 0.5
		)
	tag_multipliers = list(TAG_EXTERNAL = 0.2, TAG_OUTSIDER_ANTAG = 0.8)
	weight = 3
