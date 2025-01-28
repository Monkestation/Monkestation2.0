/// This test ensures that floor lights aren't mapped underneath any sort of solid object that would obscure it.
/datum/unit_test/floor_lights

/datum/unit_test/floor_lights/Run()
	for(var/obj/machinery/light/floor/light as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light/floor))
		var/turf/light_loc = light.loc
		if(!isturf(light_loc) || !is_station_level(light_loc.z)) // only check lights on-station
			continue
		for(var/obj/thing in light_loc)
			if(thing.density && thing.layer > light.layer)
				TEST_FAIL("Floor light obscured by [thing] at [AREACOORD(light_loc)]!")
