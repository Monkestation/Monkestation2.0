/datum/action/cooldown/vampire/reconstitute
	name = "Reconstitute"
	desc = "Convert your lifeforce into physical form, then reconstitute it into a new body. Works even as a brain."
	check_flags = NONE
	cooldown_time = 10 MINUTES
	life_cost = LIFEFORCE_PER_HUMAN * 0.5 // Justified by the long cooldown. By the time you get this it's probably at least 40 min into the round, so this gives about 5 uses.

/datum/action/cooldown/vampire/reconstitute/Activate(atom/target)
	return ..()
