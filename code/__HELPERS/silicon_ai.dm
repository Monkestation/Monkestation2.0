///Returns a list of all data cores on a z level, irrespective of whether or not that core is habitable.
/proc/get_cores_on_level(z_level) as /list
	RETURN_TYPE(/list)

	var/list/obj/machinery/ai/data_core/returned_cores = list()
	var/list/z_list = list()

	//Take Multi-Z into account.
	if(is_station_level(z_level))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			z_list += z
	else
		z_list += z_level

	for(var/z in z_list)
		for(var/obj/machinery/ai/data_core/data_core in GLOB.data_cores["[z]"])
			returned_cores += data_core
	return returned_cores

///Returns a single AI core that is habitable, given a z_level to look for.
/mob/living/silicon/ai/proc/find_valid_ai_core() as /obj/machinery/ai/data_core
	RETURN_TYPE(/obj/machinery/ai/data_core)

	var/turf/ai_turf = get_turf(src)

	var/obj/machinery/ai/data_core/found_data_core

	for(var/obj/machinery/ai/data_core/new_data_core as anything in SSmachines.get_machines_by_type(/obj/machinery/ai/data_core/primary))
		//in the case the primary core is deleted, this is ran before Destroy process is done (for AI relocation), so check QDELETED.
		if(!new_data_core.can_transfer_ai(src) || QDELETED(new_data_core))
			continue

		//If we're on the station, we won't work if the primary is not.
		if(is_station_level(ai_turf.z))
			if(!(is_station_level(new_data_core.z)))
				continue
		//If we're off the z level, we want to have the same z-level.
		else if(ai_turf.z != new_data_core.z)
			continue
		found_data_core = new_data_core
		break

	if(isnull(found_data_core))
		for(var/obj/machinery/ai/data_core/other_data_cores in GLOB.data_cores["[ai_turf.z]"])
			if(other_data_cores.can_transfer_ai(src))
				found_data_core = other_data_cores
				break

	return found_data_core
