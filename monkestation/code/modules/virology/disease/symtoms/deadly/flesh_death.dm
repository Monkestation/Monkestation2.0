/*
//////////////////////////////////////

Autophagocytosis (AKA Programmed mass cell death)

	Very noticable.
	Lowers resistance.
	Fast stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_death
	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage."
	illness = "Premature Mummification"
	severity = 6
	max_multiplier = 2
	base_message_chance = 50
	max_chance = 20
	badness = EFFECT_DANGER_DEADLY
	var/zombie = FALSE

/datum/symptom/flesh_death/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	if(HAS_TRAIT(mob, TRAIT_NO_ZOMBIFY)) //These are the zombie symtomps. Best not to kill the zombies with them
		return
	switch(disease.stage)
		if(1,2)
			if(prob(base_message_chance))
				to_chat(mob, span_warning("[pick("You feel your body break apart.", "Your skin rubs off like dust.")]"))
		if(3,4)
			if(prob(base_message_chance / 2)) //reduce spam
				to_chat(mob, span_userdanger("[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]"))
			Flesh_death(mob, disease)

/datum/symptom/flesh_death/proc/Flesh_death(mob/living/mob, datum/disease/acute/disease)
	var/get_damage = rand(6,10)
	mob.take_overall_damage(brute = get_damage)
	if(round(multiplier) == 2 && mob.reagents)
		mob.reagents.add_reagent_list(list(/datum/reagent/toxin/heparin = 2, /datum/reagent/toxin/lipolicide = 2))
		if(zombie)
			mob.reagents.add_reagent(/datum/reagent/romerol, 1)
	return 1
