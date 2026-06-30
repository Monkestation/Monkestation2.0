/**
 * Nabber liver
 * Makes Plasma and Hot Ice heal suffocation damage
 **/

/obj/item/organ/internal/liver/nabber
	name = "catalytic processor" //Nabbers convert oxygen -> plasma lorewise in their blood
	icon_state = "liver"
	icon = 'icons/obj/medical/organs/nabber_organs.dmi'
	liver_resistance = 0.8 //Weaker livers

/obj/item/organ/internal/liver/nabber/handle_chemical(mob/living/carbon/owner, datum/reagent/toxin/chem, seconds_per_tick, times_fired) //converts plasma tox damage to healing oxy damage
	. = ..()
	if(. || (organ_flags & ORGAN_FAILING))
		return
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		chem.toxpwr = 0
		owner.adjustOxyLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE)
