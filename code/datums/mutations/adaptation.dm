/datum/mutation/temperature_adaptation
	name = "Temperature Adaptation"
	desc = "A strange mutation that renders the host immune to damage from extreme temperatures. Does not protect from vacuums."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	instability = 25
	conflicts = list(/datum/mutation/pressure_adaptation)

/datum/mutation/temperature_adaptation/New(datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER))

/* Moved to 'monkestation/code/datums/mutations/adaptation.dm'
/datum/mutation/temperature_adaptation/get_visual_indicator()
	return visual_indicators[type][1]
*/

/datum/mutation/temperature_adaptation/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTHEAT), GENETIC_MUTATION)

/datum/mutation/temperature_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTHEAT), GENETIC_MUTATION)

/datum/mutation/pressure_adaptation
	name = "Pressure Adaptation"
	desc = "A strange mutation that renders the host immune to damage from both low and high pressure environments. Does not protect from temperature, including the cold of space."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels numb!</span>"
	instability = 25
	conflicts = list(/datum/mutation/temperature_adaptation)

/datum/mutation/pressure_adaptation/New(datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "pressure", -MUTATIONS_LAYER))

/* Moved to 'monkestation/code/datums/mutations/adaptation.dm'
/datum/mutation/pressure_adaptation/get_visual_indicator()
	return visual_indicators[type][1]
*/

/datum/mutation/pressure_adaptation/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), GENETIC_MUTATION)

/datum/mutation/pressure_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), GENETIC_MUTATION)
