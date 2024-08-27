/datum/reagent/toxin/plantbgone/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 10))
	mytray.adjust_toxic(round(volume * 6))
	mytray.adjust_weedlevel(-rand(4,8))

/datum/reagent/toxin/plantbgone/weedkiller/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume * 0.5))
	mytray.adjust_weedlevel(-rand(1,2))

/datum/reagent/toxin/acid/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume))
	mytray.adjust_toxic(round(volume * 1.5))
	mytray.adjust_weedlevel(-rand(1,2))

/datum/reagent/toxin/acid/fluacid/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 2))
	mytray.adjust_toxic(round(volume * 3))
	mytray.adjust_weedlevel(-rand(1,4))

/datum/reagent/toxin/mutagen/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_toxic(round(volume * 3)) //It is still toxic, mind you, but not to the same degree.
	plant_mutation_reagent_apply(volume, mytray, user, mr = 10, hm = 5)
	if(prob(10))
		mytray.mutatespecie_new()

/* Original Code
/datum/reagent/toxin/plantbgone/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 10))

/datum/reagent/toxin/plantbgone/weedkiller/on_plant_apply(obj/item/seeds/seed)


/datum/reagent/toxin/acid/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 1))

/datum/reagent/toxin/acid/fluacid/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 2))

/datum/reagent/toxin/mutagen/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!myseed)
		return
	if(chems.has_reagent(type, 1))
		mytray.adjust_toxic(3) //It is still toxic, mind you, but not to the same degree.
		plant_mutation_reagent_apply(chems, mytray, user, mr = 10, hm = 5)
	if(prob(10))
		chems.remove_all_type(type, chems.get_reagent_amount(type))
		mytray.mutatespecie_new()

*/
