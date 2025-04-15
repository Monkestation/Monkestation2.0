/datum/mutation/human/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "A hyperactive liver improves the patient's ability to metabolize alcohol."
	quality = POSITIVE
	text_gain_indication = span_notice("Your liver feels amazing.")
	text_lose_indication = span_danger("Your liver feels sad.")
	instability = 10
	power_coeff = 1

/datum/mutation/human/alcohol_tolerance/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	ADD_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE, GENETIC_MUTATION)

/datum/mutation/human/alcohol_tolerance/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE, GENETIC_MUTATION)

/datum/mutation/human/alcohol_tolerance/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(GET_MUTATION_POWER(src) <= 1)
		return

	switch(owner.get_drunk_amount()) // Same as drunken resilience
		if(6 to 40)
			owner.adjustBruteLoss(-0.067 * seconds_per_tick * GET_MUTATION_POWER(src), FALSE, required_bodytype = BODYTYPE_ORGANIC)
			owner.adjustFireLoss(-0.0335 * seconds_per_tick * GET_MUTATION_POWER(src), required_bodytype = BODYTYPE_ORGANIC)
		if(41 to 60)
			owner.adjustBruteLoss(-0.268 * seconds_per_tick * GET_MUTATION_POWER(src), FALSE, required_bodytype = BODYTYPE_ORGANIC)
			owner.adjustFireLoss(-0.134 * seconds_per_tick * GET_MUTATION_POWER(src), required_bodytype = BODYTYPE_ORGANIC)
		if(61 to INFINITY)
			owner.adjustBruteLoss(-0.536 * seconds_per_tick * GET_MUTATION_POWER(src), FALSE, required_bodytype = BODYTYPE_ORGANIC)
			owner.adjustFireLoss(-0.268 * seconds_per_tick * GET_MUTATION_POWER(src), required_bodytype = BODYTYPE_ORGANIC)

/datum/mutation/human/alcohol_brewery
	name = "Auto-brewery Syndrome"
	desc = "The patient's body now naturally produces alcohol into their bloodstream."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("Your liver hurts.")
	text_lose_indication = span_notice("Your liver feels better.")
	instability = 10
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/alcohol_brewery/on_life(seconds_per_tick, times_fired)
	if(prob(15 / GET_MUTATION_ENERGY(src)))
		owner.reagents?.add_reagent(/datum/reagent/consumable/ethanol, 1.5 * seconds_per_tick * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src))
