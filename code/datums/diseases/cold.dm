/datum/disease/premade/cold
	name = "Common Cold"
	form = "Viral Infection"
	category = DISEASE_COLD

	symptoms = list(
		new /datum/symptom/cough,
		new /datum/symptom/sneeze,
		new /datum/symptom/fridge,
	)
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	robustness = 45

	infectionchance = 70
	infectionchance_base = 86
	can_kill = list("Bacteria")

/datum/disease/premade/cold/activate(mob/living/mob, starved, seconds_per_tick)
	. = ..()
	if(stage != max_stages)
		return

	if(SPT_PROB(0.25, seconds_per_tick) && !LAZYFIND(affected_mob.disease_resistances, /datum/disease/flu))
		//affected_mob.infect_disease_predefined()
		cure()
		return
