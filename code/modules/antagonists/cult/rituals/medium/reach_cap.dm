/datum/bloodcult_ritual/reach_cap
	name = "Reach the cap"
	desc = "the cult must grow...<br>until it cannot..."

	only_once = TRUE
	ritual_type = "conversion"
	difficulty = "medium"
	reward_faction = 400

	keys = list(
		"conversion",
		"converted_prisoner",
		"soulstone",
		"soulstone_prisoner",
		)

/datum/bloodcult_ritual/reach_cap/pre_conditions(datum/antagonist/cult/potential)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult.CanConvert())
		return TRUE
	return FALSE

/datum/bloodcult_ritual/reach_cap/key_found(extra)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult.CanConvert())
		return TRUE
	return FALSE
