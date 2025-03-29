/datum/mutation/human/spores
	name = "Agaricale Pores" // Pores, not spores. ITS NOT SPORES!!!!!
	desc = "An ancient mutation found in floran DNA that allows the user to emit spores."
	locked = TRUE
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("You feel your pores more sensitively..?")
	instability = 30
	power_path = /datum/action/cooldown/spores

	energy_coeff = 1

/datum/action/cooldown/spores
	name = "Release Spores"
	desc = "Release your blood in a mist using pores."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "smoke"

	cooldown_time = 1 MINUTE
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/spores/Activate(mob/living/carbon/cast_on)
	. = ..()
	var/datum/blood_type/blood = cast_on.get_blood_type()

	var/blood_path = isnull(blood) ? /datum/reagent/drug/mushroomhallucinogen : blood.reagent_type
	var/amount = min(cast_on.blood_volume, 15) // We dont need to check if its below 15 realistically since you'd be dead, but whatever
	var/range = floor(sqrt(amount / 2))

	cast_on.blood_volume -= amount
	do_chem_smoke(range, amount, owner, get_turf(cast_on), blood_path)
	playsound(cast_on, 'sound/effects/smoke.ogg', 50, 1, -3)
	return TRUE

/datum/mutation/human/sapblood
	name = "Sap blood"
	desc = "A mutation that causes the hosts blood to thicken, almost like sap, bleeding less and coagulating faster."
	locked = TRUE
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("You feel your arteries cloying!") // Cloying is apparently an actual word
	instability = 20
	power_coeff = 1
	energy_coeff = 1
	/// The bloodiest wound that the patient has will have its blood_flow reduced by about half this much each second
	var/clot_rate = 0.2
	/// We reduce all bleeding by this factor whilst active
	var/passive_bleed_modifier = 0.8

/datum/mutation/human/sapblood/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	ADD_TRAIT(owner, TRAIT_COAGULATING, GENETIC_MUTATION)
	owner.physiology?.bleed_mod *= passive_bleed_modifier

/datum/mutation/human/sapblood/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_COAGULATING, GENETIC_MUTATION)
	owner.physiology?.bleed_mod /= passive_bleed_modifier
	if(GET_MUTATION_ENERGY(src) < 1)
		owner.physiology?.bleed_mod *= 0.9

/datum/mutation/human/sapblood/modify()
	. = ..()
	if(owner && GET_MUTATION_ENERGY(src) < 1) // And this is where this turns from a helpfull mutation into murder
		owner.physiology?.bleed_mod /= 0.9

/datum/mutation/human/sapblood/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(owner, TRAIT_NOBLOOD) || !length(owner.all_wounds))
		return

	var/datum/wound/bloodiest_wound

	for(var/datum/wound/iter_wound as anything in owner.all_wounds)
		if(iter_wound.blood_flow)
			if(iter_wound.blood_flow > bloodiest_wound?.blood_flow)
				bloodiest_wound = iter_wound

	if(bloodiest_wound)
		bloodiest_wound.adjust_blood_flow(-(clot_rate * GET_MUTATION_POWER(src)) * REM * seconds_per_tick)
