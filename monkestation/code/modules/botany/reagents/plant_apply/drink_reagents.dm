/datum/reagent/consumable/milk/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume * 0.3))
	var/obj/item/seeds/myseed = mytray.myseed
	if(isnull(myseed) || myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		return
	myseed.adjust_potency(-round(volume * 0.5))

/datum/reagent/consumable/sodawater/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume))
	mytray.adjust_plant_health(round(volume * 0.1))


/* Original Code
/datum/reagent/consumable/milk/on_plant_apply(obj/item/seeds/seed)
	seed.adjust_potency(-volume * 0.5)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.1))

/datum/reagent/consumable/sodawater/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.15))

*/
