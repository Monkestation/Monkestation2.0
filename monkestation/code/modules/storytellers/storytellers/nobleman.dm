/datum/storyteller/nobleman
	name = "The Nobleman"
	desc = "The Nobleman enjoys a good fight but abhors senseless destruction. Prefers heavy hits on single targets."
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.5,
		EVENT_TRACK_MODERATE = 0.6,
		EVENT_TRACK_MAJOR = 0.575,
		EVENT_TRACK_ROLESET = 0.5,
		EVENT_TRACK_OBJECTIVES = 0.5
		)
	tag_multipliers = list(TAG_COMBAT = 1.4, TAG_DESTRUCTIVE = 0.4, TAG_TARGETED = 1.2)
	population_min = 25 //combat based so we should have some kind of min pop(even if low)
	weight = 3
