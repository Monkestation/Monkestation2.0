
/datum/bloodcult_ritual/suicide_tome
	name = "An Ending"
	desc = "grab a tome...<br>then think of an ending...<br>preferably one with many witnesses..."

	only_once = TRUE
	ritual_type = "suicide"
	difficulty = "hard"
	personal = TRUE
	reward_achiever = 500
	reward_faction = 100

	keys = list("suicide_tome")

/datum/bloodcult_ritual/suicide_tome/pre_conditions(var/datum/antagonist/cult/potential)
	if (potential)
		owner = potential
	if (potential.devotion > DEVOTION_TIER_4)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/suicide_tome/key_found(var/mob/living/extra)
	for(var/mob/M in dview(world.view, get_turf(extra), INVISIBILITY_MAXIMUM))
		if (!M.client)
			continue
		if (isobserver(M))
			reward_achiever += 50
			reward_faction += 10
		else if (IS_CULTIST(M))
			reward_achiever += 100
			reward_faction += 20
		else
			reward_achiever += 200
			reward_faction += 40
	return TRUE
