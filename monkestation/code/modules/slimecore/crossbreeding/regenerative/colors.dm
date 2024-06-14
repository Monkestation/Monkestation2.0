/datum/status_effect/regenerative_extract/purple
	base_healing_amt = 4
	diminishing_multiplier = 0.5
	diminish_time = 1.5 MINUTES
	given_traits = list(TRAIT_ANALGESIA, TRAIT_NOCRITDAMAGE, TRAIT_NOCRITOVERLAY, TRAIT_NOSOFTCRIT)

/datum/status_effect/regenerative_extract/silver
	base_healing_amt = 1.5
	nutrition_heal_cap = NUTRITION_LEVEL_WELL_FED + 50
	diminishing_multiplier = 0.8
	diminish_time = 30 SECONDS
	given_traits = list(TRAIT_ANALGESIA, TRAIT_NOCRITDAMAGE, TRAIT_NOCRITOVERLAY, TRAIT_NOFAT)
