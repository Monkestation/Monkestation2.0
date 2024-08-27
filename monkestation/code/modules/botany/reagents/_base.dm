// OLYMPUS EDIT Commenting out the Signalers because we dont want to send them with each plant growth tick like in monkey, it would use up too much resource


/datum/reagent/proc/on_plant_apply(obj/machinery/hydroponics/mytray, mob/user)
	return

/*
/datum/reagent/proc/on_plant_apply(obj/item/seeds/seed)
*/
///this proc is basically a signal sender
/datum/reagent/proc/on_plant_grower_apply(atom/movable/parent)
