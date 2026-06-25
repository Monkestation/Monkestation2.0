/obj/effect/decal/paint_splatter
	name = "paint"
	desc = "A puddle of paint spilled on the floor, someone should probably clean this up."
	icon = null //we dont actually have an icon, our appearance is handled by a mutable appearance
	layer = SIGIL_LAYER
	turf_loc_check = FALSE //this gets handled by the SSgangs creation procs
	///Ref to our visual holder
	var/obj/effect/abstract/paint_splatter_visual_holder/holder
	///The color of paint we are, used to ensure things dont touch the value if we dont want them to
	var/paint_color
	///The world.time we were created at
	var/creation_timestamp = 0
	///alist of visual holders keyed to their id string
	var/static/alist/visual_holders_by_key = alist()

/obj/effect/decal/paint_splatter/Initialize(mapload, our_color)
	..()
	paint_color = our_color //change this to its own var
	creation_timestamp = world.time
	for(var/card_dir in GLOB.cardinals)
		var/turf/dir_turf = get_step(src, card_dir)
		if(dir_turf)
			RegisterSignal(dir_turf, COMSIG_PAINT_SPLATTER_UPDATE, PROC_REF(adjacent_paint_update))
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/paint_splatter/LateInitialize(mapload_arg)
	new_state()

/obj/effect/decal/paint_splatter/Destroy(force)
	for(var/card_dir in GLOB.cardinals)
		UnregisterSignal(get_step(src, card_dir), COMSIG_PAINT_SPLATTER_UPDATE)
	var/turf/our_turf = get_turf(src)
	SEND_SIGNAL(our_turf, COMSIG_PAINT_SPLATTER_UPDATE, src)
	appearance = null //its technically a ref, so just to be safe
	holder = null
	return ..()

/obj/effect/decal/paint_splatter/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf) && !GET_TURF_BELOW(here_turf)

/obj/effect/decal/paint_splatter/wash(clean_types)
	. = ..()
	if(. || (clean_types & CLEAN_TYPE_HARD_DECAL))
		qdel(src)
		return TRUE
	return .

///Call this whenever we have a full state change, color and/or creation_timestamp overwritten
/obj/effect/decal/paint_splatter/proc/new_state(check_for_holder = TRUE)
	var/list/adjacent = list()
	var/turf/our_turf = get_turf(src)
	SEND_SIGNAL(our_turf, COMSIG_PAINT_SPLATTER_UPDATE, src, adjacent)
	if(check_for_holder && holder)
		return

	var/alist/connections = alist()
	for(var/obj/effect/decal/paint_splatter/splatter in adjacent)
		check_state_value(splatter, connections)
	change_appearance(connections)

///Manually grab adjacent paint splatters and then update our visuals
/obj/effect/decal/paint_splatter/proc/do_manual_visuals()
	var/alist/vis_list = alist()
	for(var/card_dir in GLOB.cardinals)
		var/obj/effect/decal/paint_splatter/splatter = locate() in get_step(src, card_dir)
		if(splatter)
			check_state_value(splatter, vis_list)
	change_appearance(vis_list)

///Set our appearance based on the passed alist
/obj/effect/decal/paint_splatter/proc/change_appearance(alist/new_appearance)
	var/new_key = get_visual_string(paint_color, new_appearance)
	var/obj/effect/abstract/paint_splatter_visual_holder/new_holder = visual_holders_by_key[new_key]
	if(!new_holder)
		new_holder = new /obj/effect/abstract/paint_splatter_visual_holder(null, paint_color, new_appearance)
		new_holder.string_id = new_key
		visual_holders_by_key[new_key] = new_holder

	holder = new_holder
	appearance = new_holder.appearance
	update_appearance()

///Get the passed connections list in key form
/obj/effect/decal/paint_splatter/proc/get_visual_string(passed_color, alist/connections)
	. = "[passed_color]" //stringcasting to ensure nothing runtimes
	for(var/dir_value in GLOB.cardinals) //iterate over cardinals to ensure constant ordering
		var/dir_data = connections[dir_value]
		if(!dir_data)
			continue
		. += "[dir_value]" + "[dir_data]"
	return .

///Check the state value for us and an adjacent splatter, if it differs from current value then operate in place on current_list and return TRUE
/obj/effect/decal/paint_splatter/proc/check_state_value(obj/effect/decal/paint_splatter/connected_to, alist/current_list)
	var/new_value = connected_to.paint_color
	if(QDELETED(connected_to))
		new_value = null
	else if(paint_color == connected_to.paint_color || creation_timestamp >= connected_to.creation_timestamp)
		new_value = paint_color

	var/dir_to = get_dir(src, connected_to)
	if(new_value != current_list[dir_to])
		current_list[dir_to] = new_value
		return TRUE
	return FALSE

/obj/effect/decal/paint_splatter/proc/adjacent_paint_update(turf/sent_from, obj/effect/decal/paint_splatter/updating, list/adjacent)
	SIGNAL_HANDLER
	if(adjacent)
		adjacent += src

	if(!holder)
		do_manual_visuals() //we need to have visuals for whatever we got the signal from
		return

	var/alist/app_copy = holder.connections.Copy()
	if(check_state_value(updating, app_copy))
		change_appearance(app_copy)

//TODO: convert these to a datum that just holds the appearance as a mutable
///The visual holder for paint splatters, these should be singletons
/obj/effect/abstract/paint_splatter_visual_holder
	name = "paint"
	desc = "A puddle of paint spilled on the floor, someone should probably clean this up."
	icon = 'icons/effects/paint_splatter.dmi'
	alpha = 210
	layer = SIGIL_LAYER
	pixel_x = -4
	pixel_y = -4
	///Alist of tile connections keyed to direction, if we dont have an entry for a dir then we have no connections in that direction
	///If the value is a num then its a connection of the same color, otherwise it will be a color string for the overlay coming from that direction
	var/alist/connections
	///Local ref to our string id
	var/string_id

/obj/effect/abstract/paint_splatter_visual_holder/Initialize(mapload, base_color, alist/connections_list = alist())
	. = ..()
	color = base_color
	connections = connections_list
	var/icon_state_value = NONE
	var/list/images
	if(length(connections_list))
		images = list()
		for(var/dir_value, dir_data in connections_list)
			icon_state_value &= dir_value
			if(!istext(dir_data) || dir_data == base_color)
				continue
			var/image/edge = image('icons/effects/paint_splatter.dmi', src, "edge-[dir_value]") //technically we could probably just rotate this but ehh
			edge.color = dir_data
			edge.appearance_flags |= RESET_COLOR | RESET_ALPHA
			images += edge

	icon_state = "splatter-[icon_state_value]"
	if(length(images))
		add_overlay(images)

	update_appearance(UPDATE_ICON)
	var/mutable_appearance/our_appearance = appearance
	cut_overlays()
	appearance = our_appearance
	update_appearance(UPDATE_ICON)

/proc/test_holder(turf/spawn_at)
	var/obj/effect/abstract/paint_splatter_visual_holder/holder = new /obj/effect/abstract/paint_splatter_visual_holder(spawn_at, COLOR_RED, alist(1 = COLOR_GREEN, 2 = COLOR_BLUE, 4 = COLOR_RED, 8 = COLOR_PURPLE))
	var/obj/effect/decal/paint_splatter/splatter = new(get_step(spawn_at, WEST))
	splatter.appearance = holder.appearance
