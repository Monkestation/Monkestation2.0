///this is a pile of shitcode, so its seperated from the actual controller because i will be coming back in the future to fix it

/datum/controller/subsystem/hotspots/proc/generate_map()
	if(map)
		return
	///we load a blank map before we edit it each tile is a 2x2 pixel so map size is 510
	map = icon('monkestation/icons/misc/map_files.dmi', "blank_map")

	var/turf_color
	///brutal
	for(var/turf/turf as anything in Z_TURFS(SSmapping.levels_by_trait(ZTRAIT_MINING)[1]))
		if(istype(turf, /turf/closed/mineral/random/ocean))
			turf_color = "solid"
		else if(istype(turf.loc, /area/station) || istype(turf.loc, /area/mine))
			turf_color = "station"
		else if(isoceanturf(turf))
			turf_color = "nothing"
		else
			turf_color = "other"
		///draw the map with the color chosen
		map.DrawBox(colors[turf_color], turf.x * 2, turf.y * 2, turf.x * 2 + 1, turf.y * 2 + 1)

/obj/item/sea_map
	name = "trench map"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/sea_map/ui_interact(mob/user, datum/tgui/ui)
	if(!SSassets.cache["trenchmap.png"])
		SSassets.transport.register_asset("trenchmap.png", SShotspots.map)
	SSassets.transport.send_assets(user, list("trenchmap.png" = SShotspots.map))
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrenchMap", name)
		ui.open()

/obj/item/sea_map/ui_data(mob/user)
	. = list()
	var/list/hotspot_list = list()
	for (var/datum/hotspot/listed_spot in SShotspots.generated_hotspots)
		hotspot_list += list(list(
			"center_y" = listed_spot.center.y,
			"center_x" = listed_spot.center.x,
			"radius" = listed_spot.radius,
			"locked" = listed_spot.can_drift,
		))
	.["hotspots"] = hotspot_list
	var/turf/user_turf = get_turf(user)
	if(SSmapping.level_trait(user_turf?.z, ZTRAIT_OSHAN))
		.["x"] = user_turf.x
		.["y"] = user_turf.y

/obj/item/sea_map/ui_static_data(mob/user)
	return list("map_image" = SSassets.transport.get_asset_url("trenchmap.png"))
