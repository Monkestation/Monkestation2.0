#define STATION_MAP_LOW_LIGHT 1, 2
#define STATION_MAP_HIGH_LIGHT 2, 3
/// Blip tag for fire alarms in areas that are on fire, shown on engineering station maps
#define MINIMAP_FIRE_ALARM_BLIP "fire_alarm"
/// Biggest side of the little station map drawn on the machine's screen, in pixels
#define STATION_MAP_SCREEN_SIZE 22

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

/// Engineering station maps also show fire alarms that are going off
/atom/movable/screen/minimap_display/station_map/engineering
	valid_minimap_blip_tags = list(MINIMAP_LADDER_BLIP, MINIMAP_STAIR_BLIP, MINIMAP_FIRE_ALARM_BLIP)

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
