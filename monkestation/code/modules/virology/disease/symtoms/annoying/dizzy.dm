/**Dizziness
 * Increases stealth
 * Lowers resistance
 * Decreases stage speed considerably
 * Slightly reduces transmissibility
 * Intense Level
 * Bonus: Shakes the affected mob's screen for short periods.
 */

/datum/symptom/dizzy // Not the egg

	name = "Dizziness"
	desc = "The virus causes inflammation of the vestibular system, leading to bouts of dizziness."
	illness = "Motion Sickness"
	level = 4
	severity = 2
	badness = EFFECT_DANGER_ANNOYING
	base_message_chance = 50
	max_multiplier = 3


/datum/symptom/dizzy/Start(datum/disease/acute/A)
	. = ..()
	if(!.)
		return

/datum/symptom/dizzy/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	switch(round(multiplier))
		if(1)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(mob, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
		if(2 to 3)
			to_chat(mob, span_userdanger("A wave of dizziness washes over you!"))
			mob.adjust_dizzy_up_to(1 MINUTES, 140 SECONDS)
			if(round(multiplier) == 3)
				mob.set_drugginess(80 SECONDS)
