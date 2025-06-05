/datum/symptom/cough//creates pathogenic clouds that may contain even non-airborne viruses.
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, releasing pathogenic clouds."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	severity = 2
	max_chance = 10

/datum/symptom/cough/activate(mob/living/mob)
	if(HAS_TRAIT(mob, TRAIT_NOBREATH))
		return
	mob.emote("cough")
	var/mob/living/carbon/human/victim = mob
	if(!ishuman(victim) || !isturf(victim.loc) || !QDELETED(victim.internal) || !QDELETED(victim.external) || victim.is_mouth_covered() || victim.has_smoke_protection() || victim.check_airborne_sterility())
		return
	var/strength = 0
	for(var/datum/disease/acute/virus in victim.diseases)
		strength += virus.infectionchance
	strength = round(strength / length(victim.diseases))
	var/i = 1
	while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
		new /obj/effect/pathogen_cloud/core(get_turf(src), victim, virus_copylist(victim.diseases))
		strength -= 30
		i++
