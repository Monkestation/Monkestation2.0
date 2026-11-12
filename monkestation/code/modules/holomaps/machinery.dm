#define STATION_MAP_LOW_LIGHT 1, 2
#define STATION_MAP_HIGH_LIGHT 2, 3
/// Blip tag for fire alarms in areas that are on fire, shown on engineering station maps
#define MINIMAP_FIRE_ALARM_BLIP "fire_alarm"
/// Biggest side of the little station map drawn on the machine's screen, in pixels
#define STATION_MAP_SCREEN_SIZE 22
/// Icon file with the markers of the legend next to the map
#define STATION_MAP_LEGEND_ICON 'monkestation/code/modules/holomaps/icons/station_map_legend.dmi'
/// Width of the legend next to the map, in pixels
#define STATION_MAP_LEGEND_WIDTH 84
/// Height of each line of the legend, in pixels
#define STATION_MAP_LEGEND_ROW_HEIGHT 10
/// Colors of the checkerboard showing meteor shield coverage
#define STATION_MAP_SHIELD_COLOR_1 rgb(0, 119, 255, 128)
#define STATION_MAP_SHIELD_COLOR_2 rgb(0, 255, 255, 128)

/// Wall mounted map of the station, shows a tactical map of the z-level it's on to whoever uses it
/obj/machinery/station_map
	name = "\improper station map"
	desc = "A virtual map of the surrounding station."
	icon = 'monkestation/code/modules/holomaps/icons/stationmap.dmi'
	icon_state = "station_map"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.16
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/station_map
	light_color = "#0096bb"
	/// The part this map needs on top of the scanning modules and micro lasers
	var/bonus_parts = /obj/item/stock_parts/micro_laser
	/// Minimap of the z-level we show
	var/datum/minimap/minimap
	/// Mobs currently looking at the map
	var/list/mob/viewers = list()
	/// HUD elements given to whoever looks at the map
	var/list/map_huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/station_map,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down,
	)

/obj/machinery/station_map/post_machine_initialize()
	. = ..()
	update_screen_light()
	INVOKE_ASYNC(src, PROC_REF(load_minimap))

/obj/machinery/station_map/Destroy()
	hide_map_from_everyone()
	minimap = null
	return ..()

/// Returns the z-level we show the map of
/obj/machinery/station_map/proc/get_target_z()
	return z

/// Gets the minimap for our z-level, generating it if needed. Can sleep
/obj/machinery/station_map/proc/load_minimap()
	var/target_z = get_target_z()
	if(!target_z)
		return
	minimap = get_minimap_for_z(target_z)
	if(QDELETED(src))
		return
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/station_map/interact(mob/user)
	. = ..()
	if(user in viewers)
		hide_map(user)
		return TRUE
	show_map(user)
	return TRUE

/// Shows the map to the passed user, if we can
/obj/machinery/station_map/proc/show_map(mob/user)
	if(!anchored || panel_open || !is_operational || isnull(user.hud_used))
		return FALSE
	if(isnull(minimap))
		balloon_alert(user, "still loading!")
		return FALSE
	if(!isnull(user.hud_used.screen_objects[HUD_TAC_MINIMAP]))
		balloon_alert(user, "already looking at a map!")
		return FALSE

	var/target_z = get_target_z()
	for(var/hud_key in map_huds)
		var/hud_element_type = map_huds[hud_key]
		var/atom/movable/screen/hud_element = new hud_element_type(null, user.hud_used, minimap, null, target_z, null, FALSE)
		user.hud_used.add_screen_object(hud_element, hud_key, HUD_GROUP_STATIC, update_screen = TRUE)

	viewers |= user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_viewer_moved))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(hide_map))
	playsound(src, 'monkestation/code/modules/holomaps/sounds/holomap_open.ogg', 125)
	update_use_power(ACTIVE_POWER_USE)
	update_screen_light()
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/// Hides the map from the passed user
/obj/machinery/station_map/proc/hide_map(mob/user)
	SIGNAL_HANDLER
	if(!(user in viewers))
		return
	viewers -= user
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if(user.hud_used)
		for(var/hud_key in map_huds)
			user.hud_used.remove_screen_object(hud_key)
	playsound(src, 'monkestation/code/modules/holomaps/sounds/holomap_close.ogg', 125)
	if(!length(viewers))
		update_use_power(IDLE_POWER_USE)
		update_screen_light()
		update_appearance(UPDATE_ICON_STATE)

/// Closes the map for everyone looking at it
/obj/machinery/station_map/proc/hide_map_from_everyone()
	for(var/mob/viewer as anything in viewers.Copy())
		hide_map(viewer)

/// Closes the map for viewers that walked away from it
/obj/machinery/station_map/proc/on_viewer_moved(mob/source)
	SIGNAL_HANDLER
	if(get_dist(source, src) > 1)
		hide_map(source)

/obj/machinery/station_map/on_set_is_operational(old_value)
	if(!is_operational)
		hide_map_from_everyone()
	update_screen_light()
	update_appearance()

/// Makes our screen glow brighter while someone is looking at the map, and turns it off when we stop working
/obj/machinery/station_map/proc/update_screen_light()
	if(!is_operational)
		set_light(0)
	else if(length(viewers))
		set_light(STATION_MAP_HIGH_LIGHT)
	else
		set_light(STATION_MAP_LOW_LIGHT)

/obj/machinery/station_map/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "station_map_broken"
	else if(panel_open)
		icon_state = "station_map_opened"
	else if((machine_stat & NOPOWER) || !anchored)
		icon_state = "station_map_off"
	else if(length(viewers))
		icon_state = "station_map_active"
	else
		icon_state = initial(icon_state)
	return ..()

/obj/machinery/station_map/update_overlays()
	. = ..()
	// The little "map" painted on the floor below us
	var/mutable_appearance/floor_markings = mutable_appearance('monkestation/code/modules/holomaps/icons/stationmap.dmi', "decal_station_map")
	floor_markings.dir = dir
	floor_markings.pixel_x = -pixel_x
	floor_markings.pixel_y = -pixel_y
	. += floor_markings

	if((machine_stat & (BROKEN | NOPOWER)) || panel_open || !anchored || isnull(minimap))
		return
	var/icon/small_map = get_small_map(minimap)
	var/mutable_appearance/screen_map = mutable_appearance(small_map)
	screen_map.pixel_x = round((world.icon_size - small_map.Width()) / 2)
	screen_map.pixel_y = round((world.icon_size - small_map.Height()) / 2)
	screen_map.color = light_color
	. += screen_map
	var/mutable_appearance/screen_glow = emissive_appearance(small_map, "", src)
	screen_glow.pixel_x = screen_map.pixel_x
	screen_glow.pixel_y = screen_map.pixel_y
	. += screen_glow

/// Returns the passed minimap shrunk down to fit our screen, cached per z-level
/obj/machinery/station_map/proc/get_small_map(datum/minimap/minimap)
	var/static/alist/small_maps = alist()
	var/icon/small_map = small_maps[minimap.z]
	if(small_map)
		return small_map
	small_map = icon(minimap.base_map)
	var/scale = STATION_MAP_SCREEN_SIZE / max(small_map.Width(), small_map.Height())
	small_map.Scale(max(round(small_map.Width() * scale), 1), max(round(small_map.Height() * scale), 1))
	small_maps[minimap.z] = small_map
	return small_map

/obj/machinery/station_map/screwdriver_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_screwdriver(user, "station_map_opened", "station_map_off", tool))
		return FALSE
	hide_map_from_everyone()
	update_appearance()
	return TRUE

/obj/machinery/station_map/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/station_map/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE
	rotate_map(-90)
	tool.play_tool_sound(user, 50)
	return TRUE

/// Rotates the map machine by the given amount of degrees. See byond's builtin `turn` for more info.
/obj/machinery/station_map/proc/rotate_map(direction)
	setDir(turn(dir, direction))
	switch(dir)
		if(NORTH)
			pixel_x = 0
			pixel_y = 32
		if(SOUTH)
			pixel_x = 0
			pixel_y = -32
		if(EAST)
			pixel_x = 32
			pixel_y = 0
		if(WEST)
			pixel_x = -32
			pixel_y = 0
	update_appearance()

/obj/machinery/station_map/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity == EMP_LIGHT && !prob(50))
		return
	do_sparks(8, TRUE, src)
	set_machine_stat(machine_stat | BROKEN)
	update_appearance()

/obj/machinery/station_map/engineering
	name = "\improper engineering station map"
	desc = "A virtual map of the surrounding station. Also shows where fire alarms are going off."
	icon_state = "station_map_engi"
	circuit = /obj/item/circuitboard/machine/station_map/engineering
	bonus_parts = /obj/item/stock_parts/subspace/analyzer
	map_huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/station_map/engineering,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down,
	)

/obj/machinery/station_map/engineering/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)

/obj/machinery/station_map/strategic
	name = "strategic station map"
	icon = 'monkestation/code/modules/holomaps/icons/strategic_stationmap.dmi'
	icon_state = "strat_holomap"
	pixel_x = -16
	pixel_y = -16

/obj/machinery/station_map/syndicate
	name = "recon map"
	desc = "A virtual map of the target station."

/obj/machinery/station_map/syndicate/get_target_z()
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	return length(station_levels) ? station_levels[1] : null

/// Minimap display used by station maps, can't be drawn on and shows the ways between floors
/atom/movable/screen/minimap_display/station_map
	valid_minimap_blip_tags = list(MINIMAP_LADDER_BLIP, MINIMAP_STAIR_BLIP)
	/// Entries of the legend shown next to the map
	var/list/atom/movable/screen/minimap_element/legend_entry/legend_entries = list()
	/// Legend entry that toggles the meteor shield coverage, if the z-level we show has any
	var/atom/movable/screen/minimap_element/legend_entry/meteor_shields/shield_entry
	/// Meteor shield coverage drawn on top of the map
	var/atom/movable/screen/minimap_element/meteor_shields/meteor_shields
	/// If the z-level we show has any meteor shield coverage
	var/has_meteor_shields = FALSE
	/// If the meteor shield coverage is shown, toggled from the legend
	var/show_meteor_shields = TRUE

/atom/movable/screen/minimap_display/station_map/Destroy()
	hide_minimap_elements(legend_entries)
	hide_minimap_element(meteor_shields)
	shield_entry = null
	QDEL_LIST(legend_entries)
	QDEL_NULL(meteor_shields)
	return ..()

/atom/movable/screen/minimap_display/station_map/set_minimap(datum/minimap/minimap)
	. = ..()
	if(isnull(src.minimap))
		return
	update_meteor_shields()
	update_legend()

/// Returns the entries of our legend, as names associated with their marker icons
/atom/movable/screen/minimap_display/station_map/proc/get_legend_markers()
	var/static/list/markers
	if(isnull(markers))
		markers = list()
		var/static/list/department_colors = list(
			"Command" = TACMAP_AREA_COMMAND,
			"Security" = TACMAP_AREA_SECURITY,
			"Medical" = TACMAP_AREA_MEDICAL,
			"Science" = TACMAP_AREA_SCIENCE,
			"Engineering" = TACMAP_AREA_ENGINEERING,
			"Cargo" = TACMAP_AREA_CARGO,
			"Service" = TACMAP_AREA_SERVICE,
			"Maintenance" = TACMAP_AREA_MAINTENANCE,
		)
		for(var/department in department_colors)
			var/icon/marker = icon(STATION_MAP_LEGEND_ICON, "area_legend")
			marker.DrawBox(department_colors[department], 2, 2, 7, 7)
			markers[department] = marker
		markers["You are here"] = icon('icons/ui_icons/minimap/map_blips.dmi', "locator")
		markers["Ladder"] = icon('icons/ui_icons/minimap/map_blips.dmi', "ladder")
		markers["Stairs"] = icon('icons/ui_icons/minimap/map_blips.dmi', "stairs_up")
	return markers.Copy()

/// Rebuilds the legend next to the map, adding the meteor shield entry if the z-level we show has any coverage
/atom/movable/screen/minimap_display/station_map/proc/update_legend()
	hide_minimap_elements(legend_entries)
	shield_entry = null
	QDEL_LIST(legend_entries)

	var/screen_width = get_screen_pixel_size()
	var/screen_height = screen_width
	var/mob/owner = get_mob()
	if(owner?.client)
		var/list/view_pixels = view_to_pixels(owner.client.view_size.getView())
		screen_width = view_pixels[1]
		screen_height = view_pixels[2]
	// Left of the map if it fits on the screen, right of it otherwise, and on top of it at the edge of the screen if neither fits
	var/legend_x = -(STATION_MAP_LEGEND_WIDTH + 4)
	if(origin_px[1] + legend_x < 0)
		legend_x = minimap.base_map.Width() + 4
		if(origin_px[1] + legend_x + STATION_MAP_LEGEND_WIDTH > screen_width)
			legend_x = screen_width - origin_px[1] - STATION_MAP_LEGEND_WIDTH - 4
	// Lined up with the top of the map, unless that is off the screen
	var/legend_y = min(minimap.base_map.Height(), screen_height - origin_px[2] - 4) - STATION_MAP_LEGEND_ROW_HEIGHT

	var/list/markers = get_legend_markers()
	for(var/entry_name in markers)
		legend_entries += new /atom/movable/screen/minimap_element/legend_entry(null, null, entry_name, markers[entry_name])
	if(has_meteor_shields)
		shield_entry = new(null, null, "Meteor shields", icon(STATION_MAP_LEGEND_ICON, "meteor_shield"), src)
		shield_entry.set_crossed(!show_meteor_shields)
		legend_entries += shield_entry

	for(var/atom/movable/screen/minimap_element/legend_entry/entry as anything in legend_entries)
		entry.pixel_w = legend_x
		entry.pixel_z = legend_y
		legend_y -= STATION_MAP_LEGEND_ROW_HEIGHT
	show_minimap_elements(legend_entries)

/// Redraws the meteor shield coverage of the z-level we show, it can go past the edges of the map since it mostly covers space
/atom/movable/screen/minimap_display/station_map/proc/update_meteor_shields()
	has_meteor_shields = FALSE
	hide_minimap_element(meteor_shields)
	var/list/turf/open/shielded_turfs = list()
	// World coordinates covered by the map, grown to fit every shielded turf
	var/min_x = minimap.min_x
	var/min_y = minimap.min_y
	var/max_x = minimap.min_x + minimap.base_map.Width() / MINIMAP_PIXEL_MULTIPLIER - 1
	var/max_y = minimap.min_y + minimap.base_map.Height() / MINIMAP_PIXEL_MULTIPLIER - 1
	for(var/turf/open/shielded_turf as anything in GLOB.meteor_shielded_turfs)
		if(shielded_turf.z != minimap.z)
			continue
		shielded_turfs += shielded_turf
		min_x = min(min_x, shielded_turf.x)
		min_y = min(min_y, shielded_turf.y)
		max_x = max(max_x, shielded_turf.x)
		max_y = max(max_y, shielded_turf.y)
	if(!length(shielded_turfs))
		return
	has_meteor_shields = TRUE
	var/icon/canvas = icon('icons/ui_icons/minimap/minimap.dmi')
	canvas.Crop(1, 1, (max_x - min_x + 1) * MINIMAP_PIXEL_MULTIPLIER, (max_y - min_y + 1) * MINIMAP_PIXEL_MULTIPLIER)
	for(var/turf/open/shielded_turf as anything in shielded_turfs)
		var/start_x = MINIMAP_WORLD_TO_PIXEL(shielded_turf.x, min_x, 0)
		var/start_y = MINIMAP_WORLD_TO_PIXEL(shielded_turf.y, min_y, 0)
		var/shield_color = ISODD(shielded_turf.x + shielded_turf.y) ? STATION_MAP_SHIELD_COLOR_1 : STATION_MAP_SHIELD_COLOR_2
		canvas.DrawBox(shield_color, start_x, start_y, start_x + MINIMAP_PIXEL_MULTIPLIER - 1, start_y + MINIMAP_PIXEL_MULTIPLIER - 1)
	meteor_shields ||= new
	meteor_shields.icon = canvas
	meteor_shields.pixel_w = (min_x - minimap.min_x) * MINIMAP_PIXEL_MULTIPLIER
	meteor_shields.pixel_z = (min_y - minimap.min_y) * MINIMAP_PIXEL_MULTIPLIER
	if(show_meteor_shields)
		show_minimap_element(meteor_shields)

/// Shows or hides the meteor shield coverage
/atom/movable/screen/minimap_display/station_map/proc/toggle_meteor_shields()
	show_meteor_shields = !show_meteor_shields
	shield_entry?.set_crossed(!show_meteor_shields)
	if(show_meteor_shields && has_meteor_shields)
		show_minimap_element(meteor_shields)
	else
		hide_minimap_element(meteor_shields)

/// Engineering station maps also show fire alarms that are going off
/atom/movable/screen/minimap_display/station_map/engineering
	valid_minimap_blip_tags = list(MINIMAP_LADDER_BLIP, MINIMAP_STAIR_BLIP, MINIMAP_FIRE_ALARM_BLIP)

/atom/movable/screen/minimap_display/station_map/engineering/get_legend_markers()
	. = ..()
	.["Fire alarm"] = icon('monkestation/code/modules/holomaps/icons/station_map_blips.dmi', "fire_alarm")

/// Meteor shield coverage drawn on top of station maps
/atom/movable/screen/minimap_element/meteor_shields
	name = "meteor shields"
	layer = MINIMAP_BLIPS_LAYER - 0.5

/// One line of the legend next to station maps, a marker icon with its name
/atom/movable/screen/minimap_element/legend_entry
	maptext_x = 8
	maptext_y = -4
	maptext_width = STATION_MAP_LEGEND_WIDTH - 8
	maptext_height = 16

/atom/movable/screen/minimap_element/legend_entry/Initialize(mapload, datum/hud/hud_owner, entry_name, icon/marker)
	. = ..()
	if(entry_name)
		name = entry_name
		maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>&nbsp;[entry_name]</span>") // the space keeps the first letter from getting cut off
	if(marker)
		icon = marker

/// Legend entry that shows or hides the meteor shield coverage when clicked
/atom/movable/screen/minimap_element/legend_entry/meteor_shields
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	/// The station map display we toggle the coverage of
	var/atom/movable/screen/minimap_display/station_map/display

/atom/movable/screen/minimap_element/legend_entry/meteor_shields/Initialize(mapload, datum/hud/hud_owner, entry_name, icon/marker, atom/movable/screen/minimap_display/station_map/display)
	if(marker)
		// Widen the icon so the whole line can be clicked, not just the marker
		marker.Crop(1, 1, STATION_MAP_LEGEND_WIDTH, marker.Height())
	. = ..()
	src.display = display

/atom/movable/screen/minimap_element/legend_entry/meteor_shields/Destroy()
	display = null
	return ..()

/atom/movable/screen/minimap_element/legend_entry/meteor_shields/Click(location, control, params)
	if(..() || isnull(display) || usr != display.get_mob())
		return
	display.toggle_meteor_shields()

/// Crosses out the marker, for when the coverage is hidden
/atom/movable/screen/minimap_element/legend_entry/meteor_shields/proc/set_crossed(crossed)
	cut_overlays()
	if(crossed)
		add_overlay(mutable_appearance(STATION_MAP_LEGEND_ICON, "legend_cross"))

/obj/machinery/firealarm
	/// If we're on engineering station maps because our area is on fire
	var/on_station_maps = FALSE

/obj/machinery/firealarm/set_status()
	. = ..()
	var/should_show = !!(my_area?.fire && !(obj_flags & EMAGGED))
	if(should_show == on_station_maps)
		return
	on_station_maps = should_show
	if(should_show)
		add_minimap_blip(src, MINIMAP_FIRE_ALARM_BLIP, "fire_alarm", 'monkestation/code/modules/holomaps/icons/station_map_blips.dmi')
	else
		remove_minimap_blip(MINIMAP_FIRE_ALARM_BLIP, src)

/obj/item/circuitboard/machine/station_map
	name = "Station Map"
	build_path = /obj/machinery/station_map/directional/north
	req_components = list(/obj/item/stock_parts/scanning_module = 3, /obj/item/stock_parts/micro_laser = 4)
	/// Map types this board can be set to, and their names
	var/static/list/map_names_paths = list(
		/obj/machinery/station_map/directional/north = "Station",
		/obj/machinery/station_map/engineering/directional/north = "Station Engineering",
		/obj/machinery/station_map/strategic = "Station Strategic",
	)

/obj/item/circuitboard/machine/station_map/screwdriver_act(mob/living/user, obj/item/tool)
	var/static/list/display_map_names_paths
	if(!display_map_names_paths)
		display_map_names_paths = list()
		for(var/path in map_names_paths)
			display_map_names_paths[map_names_paths[path]] = path
	var/choice = tgui_input_list(user, "Choose a new map type", "Select an Item", sort_list(display_map_names_paths))
	if(isnull(choice))
		return
	if(isnull(display_map_names_paths[choice]))
		return
	set_type(display_map_names_paths[choice])
	return TRUE

/// Changes the map type this board builds
/obj/item/circuitboard/machine/station_map/proc/set_type(obj/machinery/station_map/typepath)
	build_path = typepath
	name = "[map_names_paths[build_path]] Map"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/micro_laser = 3,
		initial(typepath.bonus_parts) = 1,)

/obj/item/circuitboard/machine/station_map/apply_default_parts(obj/machinery/machine)
	for(var/typepath in map_names_paths)
		if(istype(machine, typepath))
			set_type(typepath)
			break
	return ..()

/obj/item/circuitboard/machine/station_map/engineering
	name = "Engineering Station Map"
	desc = "A virtual map of the surrounding station. Also shows where fire alarms are going off."
	build_path = /obj/machinery/station_map/engineering/directional/north
	req_components = list(/obj/item/stock_parts/scanning_module = 3, /obj/item/stock_parts/micro_laser = 4, /obj/item/stock_parts/subspace/analyzer = 1)

// Directional Ones for Mapping //
/obj/machinery/station_map/directional/north
	dir = NORTH
	pixel_y = 32

/obj/machinery/station_map/directional/south
	dir = SOUTH
	pixel_y = -32

/obj/machinery/station_map/directional/west
	dir = WEST
	pixel_x = -32

/obj/machinery/station_map/directional/east
	dir = EAST
	pixel_x = 32

/obj/machinery/station_map/engineering/directional/north
	dir = NORTH
	pixel_y = 32

/obj/machinery/station_map/engineering/directional/south
	dir = SOUTH
	pixel_y = -32

/obj/machinery/station_map/engineering/directional/west
	dir = WEST
	pixel_x = -32

/obj/machinery/station_map/engineering/directional/east
	dir = EAST
	pixel_x = 32

/obj/machinery/station_map/syndicate/directional/north
	dir = NORTH
	pixel_y = 32

/obj/machinery/station_map/syndicate/directional/south
	dir = SOUTH
	pixel_y = -32

/obj/machinery/station_map/syndicate/directional/west
	dir = WEST
	pixel_x = -32

/obj/machinery/station_map/syndicate/directional/east
	dir = EAST
	pixel_x = 32

#undef STATION_MAP_LOW_LIGHT
#undef STATION_MAP_HIGH_LIGHT
#undef MINIMAP_FIRE_ALARM_BLIP
#undef STATION_MAP_SCREEN_SIZE
#undef STATION_MAP_LEGEND_ICON
#undef STATION_MAP_LEGEND_WIDTH
#undef STATION_MAP_LEGEND_ROW_HEIGHT
#undef STATION_MAP_SHIELD_COLOR_1
#undef STATION_MAP_SHIELD_COLOR_2
