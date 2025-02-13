/// Find all areas adjacent to a given area.
/proc/find_adjacent_areas(area/area)
	. = list()
	if(ispath(area, /area))
		area = GLOB.areas_by_type[area]
	else if(isatom(area))
		area = get_area(get_turf(area))
	if(isnull(area))
		return
	var/list/area_turfs = area.get_turfs_from_all_zlevels()
	var/list/adjacent_turfs = list()
	for(var/turf/turf as anything in area_turfs)
		adjacent_turfs |= RANGE_TURFS(1, turf)
	adjacent_turfs -= area_turfs
	for(var/turf/turf as anything in adjacent_turfs)
		. |= get_area(turf)

/proc/is_station_area_or_adjacent(area/area)
	if(ispath(area, /area))
		area = GLOB.areas_by_type[area]
	else if(isatom(area))
		area = get_area(get_turf(area))
	if(isnull(area))
		return FALSE
	if(GLOB.the_station_areas.Find(area))
		return TRUE
	for(var/adjacent_area in find_adjacent_areas(area))
		if(GLOB.the_station_areas.Find(adjacent_area))
			return TRUE
	return FALSE

