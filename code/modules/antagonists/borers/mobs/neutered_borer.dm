/**
 * A version of the standard borer that can't reproduce
 */

/mob/living/basic/cortical_borer/neutered
	neutered = TRUE
	generation = 1

/mob/living/basic/cortical_borer/neutered/calculate_maturation_speed()
	. = initial(maturation_speed)
	var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(!antag)
		return
	for(var/datum/objective/borer/objective in antag.objectives)
		. -= objective.maturation_boost

	maturation_speed = .
