/*
Alkali perspiration
	Hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmissibility.
	Fatal Level.
Bonus
	Ignites infected mob.
	Explodes mob on contact with water.
*/

/datum/symptom/alkali

	name = "Alkali perspiration"
	desc = "The diserase attaches to sudoriparous glands, synthesizing a chemical that bursts into flames when reacting with water, leading to self-immolation."
	illness = "Crispy Skin"
	stage = 1
	severity = 6
	badness = EFFECT_DANGER_DEADLY
	base_message_chance = 100
	var/chems = FALSE
	var/explosion_power = 1
	max_multiplier = 2

/datum/symptom/alkali/first_activate(mob/living/carbon/mob, datum/disease/acute/disease)
	if(disease.robustness >= 60)
		chems = TRUE
	if(disease.infectivity >= 40)
		explosion_power = 2

/datum/symptom/alkali/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	switch(disease.stage)
		if(1 to 2)
			if(prob(base_message_chance))
				to_chat(mob, span_warning("[pick("Your veins boil.", "You feel hot.", "You smell meat cooking.")]"))
		if(3)
			if(mob.fire_stacks < 0)
				mob.visible_message(span_warning("[mob]'s sweat sizzles and pops on contact with water!"))
				explosion(mob, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_4(mob, disease)
			mob.ignite_mob()
			to_chat(mob, span_userdanger("Your sweat bursts into flames!"))
			mob.emote("scream")
		if(4)
			if(mob.fire_stacks < 0)
				mob.visible_message(span_warning("[mob]'s sweat sizzles and pops on contact with water!"))
				explosion(mob, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_5(mob, disease)
			mob.ignite_mob()
			to_chat(mob, span_userdanger("Your skin erupts into an inferno!"))
			mob.emote("scream")

/datum/symptom/alkali/proc/Alkali_fire_stage_4(mob/living/carbon/mob, datum/disease/acute/disease)
	var/get_stacks = 3 * multiplier
	mob.adjust_fire_stacks(get_stacks)
	mob.take_overall_damage(burn = get_stacks / 2)
	if(chems)
		mob.reagents?.add_reagent(/datum/reagent/clf3, 2 * multiplier)

/datum/symptom/alkali/proc/Alkali_fire_stage_5(mob/living/carbon/mob, datum/disease/acute/disease)
	var/get_stacks = 5 * multiplier
	mob.adjust_fire_stacks(get_stacks)
	mob.take_overall_damage(burn = get_stacks)
	if(chems)
		mob.reagents?.add_reagent_list(list(/datum/reagent/napalm = 4 * multiplier, /datum/reagent/clf3 = 4 * multiplier))
