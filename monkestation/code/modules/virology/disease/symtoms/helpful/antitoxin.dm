/datum/symptom/antitox
	name = "Antioxidantisation Syndrome"
	desc = "A very real syndrome beloved by Super-Food Fans and Essential Oil Enthusiasts; encourages the production of anti-toxin within the body."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	severity = 0
	max_multiplier = 5
	max_chance = 10

/datum/symptom/antitox/activate(mob/living/mob)
	if(prob(2.5))
		to_chat(mob, span_notice("You feel your toxins being purged!"))
	mob?.adjustToxLoss(-2 * multiplier)

