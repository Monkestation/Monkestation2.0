/datum/vampire_ability/fortitude
	name = "Fortitude"
	desc = "Temporarily enhance your already sturdy body beyond it's limits. \
		Grants you significant armor while active at the cost of speed. \
		Can be broken if enough damage is taken, causing backlash. \
		Durability scales with Tenacity."
	stat_reqs = list(VAMPIRE_STAT_TENACITY = 6)
	granted_action = /datum/action/cooldown/vampire/fortitude
