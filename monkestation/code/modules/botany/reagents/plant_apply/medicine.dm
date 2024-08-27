/datum/reagent/medicine/cryoxadone/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjustHealth(round(volume * 3))
	mytray.adjustToxic(-round(volume * 3))


/* Original Code
/datum/reagent/medicine/cryoxadone/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 3))

*/
