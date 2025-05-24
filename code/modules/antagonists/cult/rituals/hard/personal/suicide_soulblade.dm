
/datum/bloodcult_ritual/suicide_soulblade
	name = "Soul Blade"
	desc = "Become the bone of your own sword..."

	only_once = TRUE
	ritual_type = "suicide"
	difficulty = "hard"
	personal = TRUE
	reward_achiever = 500
	reward_faction = 100

	keys = list("suicide_tome")

/datum/bloodcult_ritual/suicide_soulblade/pre_conditions(datum/antagonist/cult/potential)
	if (potential)
		owner = potential
	if (potential.devotion > DEVOTION_TIER_3)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/suicide_soulblade/key_found(mob/living/extra)
	for(var/mob/M in dview(world.view, get_turf(extra), INVISIBILITY_MAXIMUM))
		if (!M.client)
			continue
		if (isobserver(M))
			reward_achiever += 25
			reward_faction += 5
		else if (IS_CULTIST(M))
			reward_achiever += 50
			reward_faction += 10
		else
			reward_achiever += 100
			reward_faction += 20
	return TRUE
