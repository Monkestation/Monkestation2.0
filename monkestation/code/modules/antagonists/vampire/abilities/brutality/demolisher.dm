/datum/vampire_ability/demolisher
	name = "Demolisher"
	desc = "You can tear down walls with your bare hands."
	stat_reqs = list(VAMPIRE_STAT_BRUTALITY = 12)

/datum/vampire_ability/demolisher/on_grant_mob()
	// While this is a capstone ability (and thus should be strong), I had to reign it in so they don't tear apart entire departments.
	// It's also loud to the point where using it is guaranteed to make you incredibly suspicious if not immediately getting you lynched.
	user.AddElement(/datum/element/wall_tearer, allow_reinforced = TRUE, tear_time = 5 SECONDS, reinforced_multiplier = 3)

/datum/vampire_ability/demolisher/on_remove_mob()
	user.RemoveElement(/datum/element/wall_tearer, allow_reinforced = TRUE, tear_time = 5 SECONDS, reinforced_multiplier = 3)
