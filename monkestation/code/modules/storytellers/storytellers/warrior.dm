/datum/storyteller/warrior
	name = "The Warrior"
	desc = "The Warrior will create more impactful events, often focused on combat."
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 0.5,
		EVENT_TRACK_MODERATE = 0.65,
		EVENT_TRACK_MAJOR = 0.65,
		EVENT_TRACK_ROLESET = 0.65,
		EVENT_TRACK_OBJECTIVES = 0.65
		)
	tag_multipliers = list(TAG_COMBAT = 1.5)
	population_min = 40
	welcome_text = "You feel like a fight is brewing."
	weight = 1
