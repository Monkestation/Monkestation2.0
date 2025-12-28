/*Headache
 * Slightly reduces stealth
 * Increases resistance tremendously
 * Increases stage speed
 * No change to transmissibility
 * Low level
 * Bonus: Displays an annoying message! Should be used for buffing your disease.
*/
/datum/symptom/headache
	name = "Headache"
	desc = "The virus causes inflammation inside the brain, causing constant headaches."
	illness = "Brain Freeze"
	severity = 1
	max_multiplier = 2
	badness = EFFECT_DANGER_ANNOYING
	base_message_chance = 100
	max_chance = 20
	/// Cooldown between stun headaches effects (monkestation addition)
	COOLDOWN_DECLARE(effect_cooldown)

/datum/symptom/headache/activate(mob/living/carbon/mob)
	if(round(multiplier) == 2 & prob(50))
		if(prob(50) & COOLDOWN_FINISHED(src, effect_cooldown))
			to_chat(mob, span_userdanger("[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]"))
			mob.Stun(35)
			COOLDOWN_START(src, effect_cooldown, rand(10 SECONDS, 30 SECONDS))
		else
			to_chat(mob, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
			mob.stamina.adjust(-25)
	else
		if(prob(base_message_chance))
			to_chat(mob, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))

