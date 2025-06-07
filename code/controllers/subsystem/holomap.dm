/// Turfs that will be colored as HOLOMAP_ROCK
#define IS_ROCK(tile) (istype(tile, /turf/closed/mineral) && tile.density)
/// Turfs that will be colored as HOLOMAP_OBSTACLE
#define IS_OBSTACLE(tile) (istype(tile, /turf/closed) ||  (locate(/obj/structure/window) in tile))
/// Turfs that will be colored as HOLOMAP_SOFT_OBSTACLE
#define IS_SOFT_OBSTACLE(tile) ((locate(/obj/structure/grille) in tile) || (locate(/obj/structure/lattice) in tile))
/// Turfs that will be colored as HOLOMAP_PATH
#define IS_PATH(tile) istype(tile, /turf/open/floor)
/// Turfs that contain a Z transition, like ladders and stairs. They show with special animations on the map.
#define HAS_Z_TRANSITION(tile) ((locate(/obj/structure/ladder) in tile) || (locate(/obj/structure/stairs) in tile))

// Holo-Minimaps Generation Subsystem handles initialization of the holo minimaps.

SUBSYSTEM_DEF(holomaps)
	name = "Holomaps"
	init_order = 31
	flags = SS_NO_FIRE

	var/static/list/valid_map_indexes = list()
	var/static/list/holomaps = list()
	var/static/list/extra_holomaps = list()
	var/static/list/station_holomaps = list()
	var/static/list/holomap_z_transitions = list()
	var/static/list/list/holomap_position_to_name = list()

	var/list/holomap_markers = list()

/datum/controller/subsystem/holomaps/Recover()
	flags |= SS_NO_INIT // Make extra sure we don't initialize twice.

/datum/controller/subsystem/holomaps/Initialize(timeofday)
	if (generate_holomaps())
		return SS_INIT_SUCCESS
	return SS_INIT_FAILURE

// Holomap generation.

/// Generates all the holo minimaps, initializing it all nicely, probably.
/datum/controller/subsystem/holomaps/proc/generate_holomaps()
	. = TRUE
	// Starting over if we're running midround (it runs real fast, so that's possible)
	holomaps.Cut()
	extra_holomaps.Cut()

	for(var/z in SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_LAVA_RUINS)))
		if(!generate_holomap(z))
			. = FALSE

	if(!generate_default_holomap_legend())
		. = FALSE

	return .

/datum/controller/subsystem/holomaps/proc/generate_default_holomap_legend()
	for(var/department_color in GLOB.holomap_color_to_name)
		var/image/marker_icon = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "area_legend")
		var/icon/marker_color_overlay = icon('monkestation/code/modules/holomaps/icons/8x8.dmi', "area_legend")
		marker_color_overlay.DrawBox(department_color, 1, 1, 8, 8) // Get the whole icon
		marker_icon.add_overlay(marker_color_overlay)
		GLOB.holomap_default_legend[GLOB.holomap_color_to_name[department_color]] = list(
			"icon" =  marker_icon,
			"markers" = list(),
		)

	return TRUE

/// Generates the base holomap and the area holomap, before passing the latter to setup_station_map to tidy it up for viewing.
/datum/controller/subsystem/holomaps/proc/generate_holomap(z_level = 1)
	// Sanity checks - Better to generate a helpful error message now than have DrawBox() runtime
	var/icon/canvas = icon(HOLOMAP_ICON, "blank")
	var/icon/area_canvas = icon(HOLOMAP_ICON, "blank")
	LAZYINITLIST(SSholomaps.holomap_z_transitions["[z_level]"])
	var/list/z_transition_positions = SSholomaps.holomap_z_transitions["[z_level]"]

	var/list/position_to_name = list()
	if(world.maxx > canvas.Width())
		stack_trace("Minimap for z=[z_level] : world.maxx ([world.maxx]) must be <= [canvas.Width()]")
	if(world.maxy > canvas.Height())
		stack_trace("Minimap for z=[z_level] : world.maxy ([world.maxy]) must be <= [canvas.Height()]")

	for(var/x = 1 to world.maxx)
		for(var/y = 1 to world.maxy)
			var/turf/tile = locate(x, y, z_level)
			var/offset_x = HOLOMAP_CENTER_X + x
			var/offset_y = HOLOMAP_CENTER_Y + y
			var/area/tile_area = get_area(tile)

			if(!tile || !tile_area.holomap_should_draw)
				continue

			if(tile_area.holomap_color)
				area_canvas.DrawBox(tile_area.holomap_color, offset_x, offset_y)
				position_to_name["[offset_x]:[offset_y]"] = tile_area.holomap_color == HOLOMAP_AREACOLOR_MAINTENANCE ? "Maintenance" : tile_area.name

			if(IS_ROCK(tile))
				canvas.DrawBox(HOLOMAP_ROCK, offset_x, offset_y)

			else if(IS_OBSTACLE(tile))
				canvas.DrawBox(HOLOMAP_OBSTACLE, offset_x, offset_y)

			else if(IS_SOFT_OBSTACLE(tile))
				canvas.DrawBox(HOLOMAP_SOFT_OBSTACLE, offset_x, offset_y)

			else if(IS_PATH(tile))
				canvas.DrawBox(HOLOMAP_PATH, offset_x, offset_y)

			var/z_transition_obj = HAS_Z_TRANSITION(tile)
			if(!z_transition_obj)
				continue

			var/image/image_to_use

			if(istype(z_transition_obj, /obj/structure/stairs))
				if(!z_transition_positions["Stairs Up"])
					z_transition_positions["Stairs Up"] = list("icon" = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "stairs"), "markers" = list())

				image_to_use = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "stairs")
				image_to_use.pixel_x = offset_x
				image_to_use.pixel_y = offset_y

				z_transition_positions["Stairs Up"]["markers"] += image_to_use

				var/turf/checking = get_step_multiz(get_turf(z_transition_obj), UP)
				if(!istype(checking))
					continue

				var/list/transitions = SSholomaps.holomap_z_transitions["[checking.z]"]
				if(!transitions)
					transitions = list()
					SSholomaps.holomap_z_transitions["[checking.z]"] = transitions

				image_to_use = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "stairs_down")
				image_to_use.pixel_x = checking.x + HOLOMAP_CENTER_X
				image_to_use.pixel_y = checking.y + HOLOMAP_CENTER_Y

				if(!transitions["Stairs Down"])
					transitions["Stairs Down"] = list("icon" = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "stairs_down"), "markers" = list())

				transitions["Stairs Down"]["markers"] += image_to_use
				continue

			if(!z_transition_positions["Ladders"])
				z_transition_positions["Ladders"] = list("icon" = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "ladder"), "markers" = list())

			image_to_use = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "ladder")
			image_to_use.pixel_x = offset_x
			image_to_use.pixel_y = offset_y

			z_transition_positions["Ladders"]["markers"] += image_to_use

		// Check sleeping after each row to avoid *completely* destroying the server
		CHECK_TICK

	valid_map_indexes += z_level
	holomaps["[z_level]"] = canvas
	holomap_position_to_name["[z_level]"] = position_to_name
	return setup_station_map(area_canvas, z_level)


/// Draws the station area overlay. Required to be run if you want the map to be viewable on a station map viewer.
/// Takes the area canvas, and the Z-level value.
/datum/controller/subsystem/holomaps/proc/setup_station_map(icon/canvas, z_level)
	// Save this nice area-colored canvas in case we want to layer it or something I guess
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z_level]"] = canvas

	var/icon/map_base = icon(holomaps["[z_level]"])
	map_base.Blend(HOLOMAP_HOLOFIER, ICON_MULTIPLY)

	// Generate the full sized map by blending the base and areas onto the backdrop
	var/icon/big_map = icon(HOLOMAP_ICON, "stationmap")
	big_map.Blend(map_base, ICON_OVERLAY)
	big_map.Blend(canvas, ICON_OVERLAY)
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAP]_[z_level]"] = big_map

	// Generate the "small" map (I presume for putting on wall map things?)
	var/icon/small_map = icon(HOLOMAP_ICON, "blank")
	small_map.Blend(map_base, ICON_OVERLAY)
	small_map.Blend(canvas, ICON_OVERLAY)
	small_map.Scale(40, 40)
	small_map.Crop(5, 5, 36, 36)

	// And rotate it in every direction of course!
	var/icon/actual_small_map = icon(small_map)
	actual_small_map.Insert(new_icon = small_map, dir = NORTH)
	actual_small_map.Insert(new_icon = turn(small_map, 90), dir = EAST)
	actual_small_map.Insert(new_icon = turn(small_map, 180), dir = SOUTH)
	actual_small_map.Insert(new_icon = turn(small_map, 270), dir = WEST)
	extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[z_level]"] = actual_small_map
	return TRUE

/atom/movable/screen/fullscreen/blind/above_hud
	plane = 41

/datum/controller/subsystem/holomaps/proc/generate_cult_maps()
	for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/icon/map_base = icon(extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z_level]"])
		if(!map_base)
			continue
		var/icon/canvas = icon('monkestation/code/modules/bloody_cult/icons/cult_map.dmi', "cultmap")
		map_base.Blend("#E30000", ICON_MULTIPLY)
		canvas.Blend(map_base, ICON_OVERLAY)
		extra_holomaps["[HOLOMAP_EXTRA_CULTMAP]_[z_level]"] = canvas

/datum/controller/subsystem/holomaps/proc/update_cult_map(mob/user, atom/source_object)
	if(!("[HOLOMAP_EXTRA_CULTMAP]_[user.z]" in extra_holomaps))
		generate_cult_maps()
	var/image/map_base = image(extra_holomaps["[HOLOMAP_EXTRA_CULTMAP]_[user.z]"])
	if(!map_base)
		return

	map_base.cut_overlays()

	var/datum/holomap_marker/located_marker = source_object.return_attached_holomap_markers()
	for(var/datum/holomap_marker/marker as anything in holomap_markers)
		if(!(marker.filter & HOLOMAP_FILTER_CULT))
			continue
		var/image/marker_image = image(marker.icon, icon_state = marker.icon_state)
		if(located_marker == marker)
			marker_image.icon_state = "[marker.icon_state]-here"
		marker_image.pixel_x = marker.x + HOLOMAP_CENTER_X
		marker_image.pixel_y = marker.y + HOLOMAP_CENTER_Y
		map_base.overlays += marker_image

	var/datum/team/cult/located_cult = locate_team(/datum/team/cult)
	for(var/datum/mind/mind as anything in located_cult?.members)
		var/mob/living/current_mob = mind.current
		if(current_mob.z != user.z)
			continue
		var/image/cultist_image = image('monkestation/code/modules/bloody_cult/icons/holomap_markers.dmi', icon_state = "mau1")
		cultist_image.pixel_x = current_mob.x + HOLOMAP_CENTER_X
		cultist_image.pixel_y = current_mob.y + HOLOMAP_CENTER_Y
		map_base.overlays += cultist_image

	return map_base

/datum/controller/subsystem/holomaps/proc/show_cult_map(mob/user, atom/source_object, break_on_move = TRUE)
	if(user.hud_used.holomap in user.client.screen)
		return
	var/image/cult_map = update_cult_map(user, source_object)
	if(!cult_map)
		return
	user.hud_used.holomap.used_base_map = cult_map


	if(break_on_move)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(hide_cult_map), cult_map)

	user.hud_used.holomap.plane = 41
	cult_map.loc = user.hud_used.holomap
	user.client.screen |= user.hud_used.holomap
	user.client.images |= cult_map
	user.overlay_fullscreen("map_blocker", /atom/movable/screen/fullscreen/blind/above_hud)
	user.update_fullscreen_alpha("map_blocker", 255, 0)

/datum/controller/subsystem/holomaps/proc/hide_cult_map(mob/user, image/cult_map)
	user.client.screen -= user.hud_used.holomap
	user.client.images -= user.hud_used.holomap.used_base_map
	user.hud_used.holomap.used_base_map = cult_map
	user.hud_used.holomap.plane = 40
	user.clear_fullscreen("map_blocker", 10)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/controller/subsystem/holomaps/proc/live_update_cult_map(mob/user)
	var/image/cult_map = update_cult_map(user, null)
	user.client.images -= user.hud_used.holomap.used_base_map
	user.hud_used.holomap.used_base_map = cult_map
	cult_map.loc = user.hud_used.holomap
	user.client.images |= cult_map

/datum/holomap_marker
	var/x
	var/y
	var/z

	///this is a filter used when quickly searching for all matching markers IE FILTER_CULT will bring all cult markers up
	var/filter
	///this is the id we use when locating them inside the list of markers
	var/id

	///this is our map icon
	var/icon
	///this is our map icon_state
	var/icon_state

	var/atom/reference_atom

/datum/holomap_marker/New(atom/host)
	. = ..()
	SSholomaps.holomap_markers |= src
	if(host)
		RegisterSignal(host, COMSIG_QDELETING, PROC_REF(clear_marker))

/datum/holomap_marker/proc/clear_marker()
	SSholomaps.holomap_markers -= src
	reference_atom = null
	qdel(src)

/atom/proc/return_attached_holomap_markers()
	for(var/datum/holomap_marker/marker as anything in SSholomaps.holomap_markers)
		if(!marker.reference_atom)
			continue
		if(marker.reference_atom != src)
			continue
		return marker
	return null

#undef IS_ROCK
#undef IS_OBSTACLE
#undef IS_SOFT_OBSTACLE
#undef IS_PATH
#undef HAS_Z_TRANSITION
