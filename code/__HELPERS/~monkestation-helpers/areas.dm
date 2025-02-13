/// Find all areas adjacent to a given area.
/proc/find_adjacent_areas(area/area)
	. = list()
	var/static/list/blacklisted_areas = typecacheof(list(
		/area/icemoon,
		/area/misc,
		/area/shuttle,
		/area/space,
		/area/station/asteroid,
	))
	if(ispath(area, /area))
		area = GLOB.areas_by_type[area]
	else if(isatom(area))
		area = get_area(get_turf(area))
	if(isnull(area) || is_type_in_typecache(area, blacklisted_areas))
		return
	var/list/area_turfs = area.get_turfs_from_all_zlevels()
	var/list/adjacent_turfs = list()
	for(var/turf/turf as anything in area_turfs)
		adjacent_turfs |= RANGE_TURFS(1, turf)
	adjacent_turfs -= area_turfs
	for(var/turf/turf as anything in adjacent_turfs)
		. |= get_area(turf)

/proc/is_station_area_or_adjacent(area/area, allow_icebox_cabins = FALSE)
	if(ispath(area, /area))
		area = GLOB.areas_by_type[area]
	else if(isatom(area))
		area = get_area(get_turf(area))
	if(isnull(area))
		return FALSE
	if(GLOB.the_station_areas.Find(area.type))
		return TRUE
	for(var/area/adjacent_area as anything in find_adjacent_areas(area))
		if(GLOB.the_station_areas.Find(adjacent_area.type) || (allow_icebox_cabins && istype(adjacent_area, /area/icemoon))) // yeah sure you can make a neat little base in an icebox cabin
			return TRUE
	return FALSE

