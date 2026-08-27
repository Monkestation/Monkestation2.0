/// A version thats significantly stronger than the standard borer
/mob/living/basic/cortical_borer/empowered
	maxHealth = 150
	health = 150
	health_per_level = 15

	stat_evolution = 8
	chemical_evolution = 8

	max_chemical_storage = 250
	chemical_storage = 250
	chem_regen_per_level = 0.75
	chem_storage_per_level = 25

/// A version of the standard borer that can't reproduce
/mob/living/basic/cortical_borer/neutered
	generation = 1

/mob/living/basic/cortical_borer/neutered/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEUTERED, INNATE_TRAIT)

/mob/living/basic/cortical_borer/neutered/calculate_maturation_speed()
	. = initial(maturation_speed)
	var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(!antag)
		return
	for(var/datum/objective/borer/objective in antag.objectives)
		. -= objective.maturation_boost

	maturation_speed = .
