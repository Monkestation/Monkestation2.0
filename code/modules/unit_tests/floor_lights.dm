/// This test ensures that floor lights aren't mapped underneath any sort of solid object that would obscure it.
/datum/unit_test/floor_lights

/datum/unit_test/floor_lights/Run()
	var/static/list/obscuring_typecache = typecacheof(list(
		/obj/structure/table,
		/obj/structure/bookcase,
		/obj/machinery/computer,
		/obj/machinery/vending,
	))

	var/summary_file = world.GetConfig("env", "GITHUB_STEP_SUMMARY")
	var/list/summary
	for(var/obj/machinery/light/floor/light as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light/floor))
		var/turf/light_turf = light.loc
		if(!isturf(light_turf) || !is_station_level(light_turf.z)) // only check lights on-station
			continue
		for(var/obj/thing in light_turf)
			if(thing.density && (is_type_in_typecache(thing, obscuring_typecache) || ((thing.flags_1 & PREVENT_CLICK_UNDER_1) && thing.layer > light.layer)))
				if(summary_file)
					var/area/light_area = get_area(light)
					var/list/details = list(
						"light" = light,
						"obscured_by" = thing,
						"x" = light.x,
						"y" = light.y,
						"z" = light.z,
					)
					LAZYADDASSOCLIST(summary, light_area, details)
				TEST_FAIL("[light] obscured by [thing] at [AREACOORD(light_turf)]!")
	if(LAZYLEN(summary))
		var/list/assembled_markdown = list("## [SSmapping.config.map_name]")
		for(var/area/light_area as anything in summary)
			var/list/area_failures = list()
			for(var/list/failure as anything in summary[light_area])
				area_failures += "- `[failure["x"]],[failure["y"]],[failure["z"]]`: [failure["light"]] obscured by [failure["obscured_by"]]"
			assembled_markdown += "### [light_area.name]\n\n[jointext(area_failures, "\n")]"
		rustg_file_write(jointext(assembled_markdown, "\n\n"), summary_file)
