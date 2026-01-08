/datum/symptom/thick_blood
	name = "Hyper-Fibrinogenesis"
	desc = "Causes the infected to oversynthesize coagulant, as well as rapidly restore lost blood."
	stage = 3
	badness = EFFECT_DANGER_HELPFUL
	severity = 0
	/// While active we reduce all bleeding by this factor
	var/passive_bleed_modifier = 0.7

/datum/symptom/thick_blood/first_activate(mob/living/carbon/mob, datum/disease/acute/disease)
	ADD_TRAIT(mob, TRAIT_COAGULATING, DISEASE_TRAIT)
	var/mob/living/carbon/human/victim = mob
	if(ishuman(mob))
		victim.physiology?.bleed_mod *= passive_bleed_modifier

/datum/symptom/thick_blood/activate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if (ishuman(victim))
		if(victim.is_bleeding())
			victim.restore_blood()
			to_chat(victim, span_notice("You feel your blood regenerate, and your bleeding to stop!"))

/datum/symptom/thick_blood/deactivate(mob/living/carbon/mob)
	REMOVE_TRAIT(mob, TRAIT_COAGULATING, DISEASE_TRAIT)
	var/mob/living/carbon/human/victim = mob
	if(ishuman(mob))
		victim.physiology?.bleed_mod /= passive_bleed_modifier
