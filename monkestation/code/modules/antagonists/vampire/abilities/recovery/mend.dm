/datum/vampire_ability/mend
	name = "Mend"
	desc = "Undoes major wounds on your body from dislocations to broken bones. \
		The process is instant, but extremely obvious to onlookers. \
		Cost scales with wound count."
	stat_reqs = list(VAMPIRE_STAT_RECOVERY = 6)
	granted_action = /datum/action/cooldown/vampire/mend
