/obj/item/organ/internal/lungs/clockwork
	name = "clockwork diaphragm"
	desc = "A utilitarian bellows which serves to pump oxygen into an automaton's body."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/lungs/cetanoid
	name = "cetanoid lungs"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs"
	var/no_suit = TRUE //cetanoids need their cybernetic suit to breathe

/obj/item/organ/internal/lungs/cetanoid/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	var/turf/cur_turf = get_turf(breather)
	if(no_suit == TRUE)
		if(cur_turf.liquids != null)
			..(breath_liquids(cur_turf.liquids, breath, breather), breather)
		else
			..(null, breather)
	else
		..(breath, breather)

/obj/item/organ/internal/lungs/cetanoid/proc/breath_liquids(obj/effect/abstract/liquid_turf/liquids, datum/gas_mixture/breath, mob/living/carbon/human/breather)
	var/depth = liquids.liquid_state
	var/datum/reagents/reagents = liquids.liquid_group.reagents
	var/water_percentage = 0

	for(var/datum/reagent/water/water in reagents.reagent_list)
		if(water != null)
			water_percentage = water.volume / reagents.total_volume * 100
		else
			water_percentage = 0

	if(depth >= LIQUID_STATE_FULLTILE || depth >= LIQUID_STATE_WAIST && breather.body_position == LYING_DOWN)
		if(water_percentage >= 50)
			return breath
		else
			return null
	else
		return null
