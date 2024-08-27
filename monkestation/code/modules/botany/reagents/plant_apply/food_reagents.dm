/datum/reagent/consumable/nutriment/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjustHealth(round(volume * 0.5))
	mytray.adjustNutri(round(volume * 1))

/datum/reagent/consumable/virus_food/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjustNutri(round(volume * 0.5))
	mytray.adjustHealth(-round(volume * 0.5))

/datum/reagent/consumable/honey/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	if(!isnull(mytray.myseed) && prob(80))
		mytray.adjustWeeds(rand(1,2))
		mytray.adjustPests(rand(1,2))


/* Original Code
/datum/reagent/consumable/nutriment/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.2))

/datum/reagent/consumable/virus_food/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 0.5))

/datum/reagent/consumable/honey/on_plant_apply(obj/item/seeds/seed)
	seed.adjust_maturation(rand(1,2))
	seed.adjust_lifespan(rand(1,2))

*/
