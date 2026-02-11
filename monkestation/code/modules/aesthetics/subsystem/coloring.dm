
SUBSYSTEM_DEF(station_coloring)
	name = "Station Coloring"
	init_order = INIT_ORDER_ICON_COLORING // before SSicon_smooth
	flags = SS_NO_FIRE
	///do we bother with wall trims?
	var/wall_trims = FALSE
	//RED (Only sec stuff honestly)
	var/list/red = list("#DE3A3A")
	//BAR
	var/list/bar = list("#791500")
	//PURPLE (RnD + Research outpost)
	var/list/purple = list("#D381C9")
	//BROWN (Mining + Cargo)
	var/list/brown = list("#A46106")
	//GREEN (Virology and Hydro areas)
	var/list/green = list("#9FED58")
	//BLUE (Some of Medbay areas)
	var/list/blue = list("#52B4E9")
	//ORANGE (engineering)
	var/list/orange = list("#EFB341")

/datum/controller/subsystem/station_coloring/Initialize()
	var/list/color_palette = list(
		pick(red)          = typesof(/area/station/security),
		pick(purple)       = typesof(/area/station/science),
		pick(green)        = list(/area/station/medical/virology) + typesof(/area/station/service) - /area/station/service/bar,
		pick(blue)         = typesof(/area/station/medical),
		pick(bar)          = list(/area/station/service/bar),
		pick(brown)		   = typesof(/area/station/cargo) + typesof(/area/mine),
		COLOR_WHITE        = typesof(/area/shuttle),
		COLOR_WHITE        = typesof(/area/centcom),
		pick(orange)	   = typesof(/area/station/engineering),
	)

	for(var/color in color_palette)
		color_area_objects(color_palette[color], color)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/station_coloring/proc/color_area_objects(list/possible_areas, color) // paint in areas
	for(var/type in possible_areas)
		for(var/obj/structure/window/window in GLOB.areas_by_type[type]) // for in area is slow by refs, but we have a time while in lobby so just to-do-sometime
			if(window.uses_color)
				window.change_color(color)
		if(wall_trims)
			for(var/turf/closed/wall/wall in GLOB.areas_by_type[type])
				if(wall.wall_trim)
					wall.change_trim_color(color)

/datum/controller/subsystem/station_coloring/proc/get_default_color()
	var/static/default_color = pick(list("#1a356e", "#305a6d", "#164f41"))

	return default_color

/datum/controller/subsystem/station_coloring/proc/recolor_areas()
	var/list/color_palette = list(
		pick(red)          = typesof(/area/station/security),
		pick(purple)       = typesof(/area/station/science),
		pick(green)        = list(/area/station/medical/virology) + typesof(/area/station/service) - /area/station/service/bar,
		pick(blue)         = typesof(/area/station/medical),
		pick(bar)          = list(/area/station/service/bar),
		pick(brown)		   = typesof(/area/station/cargo) + typesof(/area/mine),
		COLOR_WHITE        = typesof(/area/shuttle),
		COLOR_WHITE        = typesof(/area/centcom),
		pick(orange)	   = typesof(/area/station/engineering),
	)

	for(var/color in color_palette)
		color_area_objects(color_palette[color], color)
