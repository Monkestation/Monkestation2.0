/obj/item/reagent_containers/proc/reagent_processing()
	reagents?.reagent_processing()

///lets any reagents that need to act on their holder (like australium) do so
/datum/reagents/proc/reagent_processing()
	for(var/datum/reagent/listed_reagent in reagent_list)
		if(listed_reagent.requires_process)
			listed_reagent.reagent_fire(src)
