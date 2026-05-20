/obj/effect/paint_splatter
	name = "paint"
	desc = "A puddle of paint spilled on the floor, someone should probably clean this up."
	icon = null //we dont actually have an icon, our appearance is handled by a mutable appearance
	layer = SIGIL_LAYER
	///Are we still loading
	var/is_loading = TRUE
	///Ref to our visual holder
	var/obj/effect/abstract/paint_splatter_visual_holder/holder
	///The world.time we were created at
	var/creation_timestamp = 0
	///alist of visual holders keyed to their id string
	var/static/alist/visual_holders_by_key = alist()

/obj/effect/paint_splatter/Initialize(mapload, our_color)
	..()
	color = our_color
	for(var/card_dir in GLOB.cardinals)
		var/turf/dir_turf = get_step(src, card_dir)
		if(dir_turf)
			RegisterSignal(dir_turf, COMSIG_PAINT_SPLATTER_UPDATE, PROC_REF(adjacent_paint_update))
	return INITIALIZE_HINT_LATELOAD

/obj/effect/paint_splatter/LateInitialize(mapload_arg)
	var/alist/connections = alist()
	var/adjacent = SEND_SIGNAL(get_turf(src), COMSIG_PAINT_SPLATTER_UPDATE, src, connections)
	is_loading = FALSE

//check this always has proper access to its datums so no NREs
/obj/effect/paint_splatter/proc/adjacent_paint_update(turf/sent_from, /obj/effect/paint_splatter/updating, alist/connections)
	SIGNAL_HANDLER

/obj/effect/paint_splatter/proc/change_appearance(alist/new_appearance)
	var/new_key = SSgangs.get_paint_visual_string(color, new_appearance)
	var/obj/effect/abstract/paint_splatter_visual_holder/new_holder = visual_holders_by_key[new_key]
	if(!new_holder)
		new_holder = new /obj/effect/abstract/paint_splatter_visual_holder(null, color, new_appearance)
		new_holder.string_id = new_key
		visual_holders_by_key[new_key] = new_holder

	appearance = new_holder.appearance

/obj/effect/paint_splatter/proc/check_state_value(obj/effect/paint_splatter/connected_to, alist/current_list)
	var/new_value = connected_to.color
	if(QDELETED(other_thing))
		new_value = null
	else if(thing.color == other_thing.color || creation_timestamp => connected_to.creation_timestamp)
		new_value = color

	var/dir_to = get_dir(src, connected_to)
	if(new_value != current_list[dir_to])
		current_list[dir_to] = new_value
		return TRUE
	return FALSE

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
	var/icon_state_value = 15
	var/list/images
	if(length(connections_list))
		images = list()
		for(var/dir_value, dir_data in connections_list)
			icon_state_value -= dir_value
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
	var/obj/effect/paint_splatter/splatter = new(get_step(spawn_at, WEST))
	splatter.appearance = holder.appearance
