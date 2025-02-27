/datum/disease/acute/premade/fungal_tb
	name = "Tubercle Bacillus Cosmosis Microbes"
	form = "Fungal Spores"
	origin = "Active fungal spores"
	category = DISEASE_FUNGUS

	symptoms = list(
		new /datum/symptom/fungal_tb
	)
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_CONTACT_SKIN|DISEASE_SPREAD_AIRBORNE
	robustness = 100
	strength = 100

	infectionchance = 75
	infectionchance_base = 0
	stage_variance = 0
	severity = DISEASE_SEVERITY_BIOHAZARD

/datum/disease/acute/premade/fungal_tb/after_add()
	. = ..()
	antigen = null
	stage = 4

/datum/disease/acute/premade/fungal_tb/activate(mob/living/mob, starved, seconds_per_tick)
	. = ..()
	if(mob.has_reagent(/datum/reagent/medicine/antipathogenic/spaceacillin, 1))
		if(mob.has_reagent(/datum/reagent/medicine/c2/convermol, 1))
			if(prob(2.5))
				cure()



/datum/disease/acute/premade/death_sandwich_poisoning
	name = "Death Sandwich Poisoning"
	form = "Condition"
	origin = "Death Sandwich"
	category = DISEASE_SANDWICH

	symptoms = list(
		new /datum/symptom/death_sandwich
	)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	robustness = 100
	strength = 100

	infectionchance = 0
	infectionchance_base = 0
	stage_variance = 0
