/datum/reagent/napalm/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	if(!(mytray.myseed?.resistance_flags & FIRE_PROOF))
		mytray.adjust_plant_health(-round(volume * 6))
		mytray.adjust_toxic(round(volume * 7))

	mytray.adjust_weedlevel(-rand(5,9)) //At least give them a small reward if they bother.

/* Original Code
	/datum/reagent/napalm/on_plant_apply(obj/item/seeds/seed)
	if(seed.resistance_flags & FIRE_PROOF)
		return

	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 6))

*/
