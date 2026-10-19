/**Spontaneous Combustion
 * Slightly hidden.
 * Lowers resistance tremendously.
 * Decreases stage speed tremendously.
 * Decreases transmittablity tremendously.
 * Fatal level
 * Bonus: Ignites infected mob.
 */

/datum/symptom/fire
	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	illness = "Spontaneous Combustion"
	badness = EFFECT_DANGER_DEADLY
	severity = 5
	base_message_chance = 20
	stage = 1
	max_multiplier = 5

/datum/symptom/fire/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	. = ..()
	switch(round(multiplier))
		if(1 to 2)
			return
		if(3)
			if(prob(base_message_chance))
				warn_mob(mob)
		else
			mob.adjust_fire_stacks(disease.stage * multiplier)
			mob.take_overall_damage(burn = ((disease.stage) * multiplier))
			mob.ignite_mob(silent = TRUE)
			if(mob.on_fire) //check to make sure they actually caught on fire, or if it was prevented cause they were wet.
				mob.visible_message(span_warning("[mob] catches fire!"), ignored_mobs = mob)
				to_chat(mob, span_userdanger((disease.stage ? "Your skin erupts into an inferno!" : "Your skin bursts into flames!")))
				mob.emote("scream")
			else
				warn_mob(mob)
	multiplier_tweak(0.1)

/datum/symptom/fire/proc/warn_mob(mob/living/mob)
	if(prob(33.33))
		mob.audible_message(self_message = "You hear a crackling noise.")
	else
		to_chat(mob, span_warning("[pick("You feel hot.", "You smell smoke.")]"))
