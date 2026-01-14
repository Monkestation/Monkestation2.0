/*
Necrotizing Fasciitis (AKA Flesh-Eating Disease)
	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmissibility tremendously.
	Fatal Level.
Bonus
	Deals brute damage over time.
*/
/datum/symptom/flesh_eating
	name = "Necrotizing Fasciitis"
	desc = "The virus aggressively attacks bone cells, causing excessive wobbliness and falling down a lot."
	illness = "Jellyitis"
	severity = 5
	badness = EFFECT_DANGER_DEADLY
	stage = 3
	max_multiplier = 2
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 60

/datum/symptom/flesh_eating/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	if(HAS_TRAIT(mob, TRAIT_NO_ZOMBIFY)) //These are the zombie symtomps. Best not to kill the zombies with them
		return
	switch(disease.stage)
		if(2)
			if(prob(base_message_chance))
				to_chat(mob, span_warning("[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]"))
		if(3, 4)
			to_chat(mob, span_userdanger("[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]"))
			Flesheat(mob, disease)

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/mob, datum/disease/acute/disease)
	var/get_damage = rand(15,25) * multiplier
	mob.take_overall_damage(brute = get_damage)
	if(round(multiplier) == 2)
		mob.stamina.adjust(-get_damage)
		var/mob/living/carbon/human/H = mob
		var/obj/item/bodypart/random_part = pick(H.bodyparts)
		random_part.adjustBleedStacks(5 * multiplier)
	return 1
