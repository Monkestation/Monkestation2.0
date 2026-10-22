/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/railing_basic.dmi'
	icon_state = "railing0-1"
	flags_1 = ON_BORDER_1
	obj_flags = IGNORE_DENSITY | CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW|PASSSTRUCTURE
	/// armor is a little bit less than a grille. max_integrity about half that of a grille.
	armor_type = /datum/armor/structure_railing
	max_integrity = 25
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

	var/climbable = TRUE
	///Initial direction of the railing.
	var/ini_dir
	///item released when deconstructed
	var/item_deconstruct = /obj/item/stack/rods
	var/neighbor_status = list() ///list of smoothing we need doing
	var/standard_smoothing = TRUE

/datum/armor/structure_railing
	melee = 35
	bullet = 50
	laser = 50
	energy = 100
	bomb = 10

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	density = FALSE
	climbable = FALSE

/obj/structure/railing/wood
	custom_materials = list(/datum/material/wood = SMALL_MATERIAL_AMOUNT)

/obj/structure/railing/Initialize(mapload)
	. = ..()
	ini_dir = dir
	if(climbable)
		AddElement(/datum/element/climbable)

	if(density && flags_1 & ON_BORDER_1) // blocks normal movement from and to the direction it's facing.
		var/static/list/loc_connections = list(
			COMSIG_ATOM_EXIT = PROC_REF(on_exit),
		)
		AddElement(/datum/element/connect_loc, loc_connections)

	var/static/list/tool_behaviors = list(
		TOOL_WELDER = list(
			SCREENTIP_CONTEXT_LMB = "Repair",
		),
		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Anchor/Unanchor",
		),
		TOOL_WIRECUTTER = list(
			SCREENTIP_CONTEXT_LMB = "Deconstruct",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM)

	if(!standard_smoothing)
		material_flags = NONE

	return INITIALIZE_HINT_LATELOAD

/obj/structure/railing/LateInitialize(mapload_arg)
	. = ..()
	if(anchored)
		update_icon()

/obj/structure/railing/Destroy()
	. = ..()
	for(var/thing in range(1, src))
		var/turf/T = thing
		for(var/obj/structure/railing/R in T.contents)
			R.update_icon()

/obj/structure/railing/setDir(newdir)
	. = ..()
	if(anchored)
		update_icon()

/obj/structure/railing/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	..()
	add_fingerprint(user)

	if(attacking_item.tool_behaviour == TOOL_WELDER && !(user.istate & ISTATE_HARM))
		if(atom_integrity < max_integrity)
			if(!attacking_item.tool_start_check(user, amount=0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(attacking_item.use_tool(src, user, 40, volume=50))
				atom_integrity = max_integrity
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

/obj/structure/railing/deconstruct(disassembled)
	if((flags_1 & NODECONSTRUCT_1))
		return ..()
	var/rods_to_make = istype(src,/obj/structure/railing/corner) ? 1 : 2
	var/obj/rod = new item_deconstruct(drop_location(), rods_to_make)
	transfer_fingerprints_to(rod)
	return ..()

///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/railing/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(flags_1&NODECONSTRUCT_1)
		return
	to_chat(user, span_notice("You begin to [anchored ? "unfasten the railing from":"fasten the railing to"] the floor..."))
	if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		set_anchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "fasten the railing to":"unfasten the railing from"] the floor."))
	return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir & dir)
		return . || mover.throwing || mover.movement_type & (FLYING | FLOATING)
	return TRUE

/obj/structure/railing/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!(to_dir & dir))
		return TRUE
	return ..()

/obj/structure/railing/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return // Let's not block ourselves.

	if(!(direction & dir))
		return

	if (!density)
		return

	if (leaving.throwing)
		return

	if (leaving.movement_type & (PHASING | FLYING | FLOATING))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/update_icon(update_neighbors = TRUE)
	. = ..()
	if(standard_smoothing)
		check_neighbors(update_neighbors)
		overlays.Cut()

		var/turf/turf = get_turf(src)
		if(dir == SOUTH)
			SET_PLANE(src, GAME_PLANE_FOV_HIDDEN, turf)
			layer = ABOVE_MOB_LAYER + 0.01

		else if(dir != NORTH)
			SET_PLANE(src, GAME_PLANE_FOV_HIDDEN, turf)
		else
			SET_PLANE(src, GAME_PLANE, turf)
			layer = initial(layer)

		if(!neighbor_status || !anchored)
			icon_state = "railing0-[density]"
		else
			icon_state = "railing1-[density]"

			if(("corneroverlay_l" in neighbor_status) && ("corneroverlay_r" in neighbor_status))
				icon_state = "blank"


			var/turf/right_turf = get_step(src, turn(src.dir, -90))
			var/turf/left_turf = get_step(src, turn(src.dir, 90))

			if((!locate(/obj/structure/railing) in right_turf.contents))
				if(!("mcorneroverlay_l" in neighbor_status))
					overlays += image(icon, "frontend_r[density]")
				else
					overlays += image(icon, "frontoverlay_r[density]")


			if((!locate(/obj/structure/railing) in left_turf.contents))
				if(!("mcorneroverlay_l" in neighbor_status))
					overlays += image(icon, "frontend_l[density]")
				else
					overlays += image(icon, "frontoverlay_l[density]")


			if("corneroverlay_l" in neighbor_status)
				overlays += image(icon, "corneroverlay_l[density]")
			if("corneroverlay_r" in neighbor_status)
				overlays += image(icon, "corneroverlay_r[density]")
			if("frontoverlay_l" in neighbor_status)
				overlays += image(icon, "frontoverlay_l[density]")
			if("frontoverlay_r" in neighbor_status)
				overlays += image(icon, "frontoverlay_r[density]")
			if("mcorneroverlay_l" in neighbor_status)
				var/pix_offset_x = 0
				var/pix_offset_y = 0
				switch(dir)
					if(NORTH)
						pix_offset_x = 32
					if(SOUTH)
						pix_offset_x = -32
					if(EAST)
						pix_offset_y = -32
					if(WEST)
						pix_offset_y = 32
				overlays += image(icon, "mcorneroverlay_l[density]", pixel_x = pix_offset_x, pixel_y = pix_offset_y)

/obj/structure/railing/proc/check_neighbors(updates = TRUE)
	neighbor_status = list()
	var/Rturn = turn(src.dir, -90)
	var/Lturn = turn(src.dir, 90)

	for(var/obj/structure/railing/R in get_turf(src))
		if((R.dir == Lturn) && R.anchored)
			neighbor_status |= "corneroverlay_l"
			if(updates)
				R.update_icon(FALSE)
		if((R.dir == Rturn) && R.anchored)
			neighbor_status |= "corneroverlay_r"
			if(updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, Lturn))
		if((R.dir == src.dir) && R.anchored)
			neighbor_status |= "frontoverlay_l"
			if(updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, Rturn))
		if((R.dir == src.dir) && R.anchored)
			neighbor_status |= "frontoverlay_r"
			if (updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, (Lturn + src.dir)))
		if((R.dir == Rturn) && R.anchored)
			neighbor_status |= "frontoverlay_l"
			if (updates)
				R.update_icon(FALSE)
	for(var/obj/structure/railing/R in get_step(src, (Rturn + src.dir)))
		if((R.dir == Lturn) && R.anchored)
			neighbor_status |= "mcorneroverlay_l"
			if (updates)
				R.update_icon(FALSE)

	///corner hell
	///we are basically checking if 2 or more cardinal directions exist here so we can set our dir

/obj/structure/railing/wooden_fence
	name = "wooden fence"
	desc = "wooden fence meant to keep animals in."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing"
	item_deconstruct = /obj/item/stack/sheet/mineral/wood
	plane = GAME_PLANE_FOV_HIDDEN
	layer = ABOVE_MOB_LAYER
	standard_smoothing = FALSE

/obj/structure/railing/wooden_fence/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_change_layer))
	adjust_dir_layer(dir)

/obj/structure/railing/wooden_fence/proc/on_change_layer(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	adjust_dir_layer(new_dir)

/obj/structure/railing/wooden_fence/proc/adjust_dir_layer(direction)
	var/new_layer = (direction & NORTH) ? MOB_LAYER : ABOVE_MOB_LAYER
	layer = new_layer


/obj/structure/railing/corner/end/wooden_fence
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing_corner"

/obj/structure/railing/corner/end/flip/wooden_fence
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing_corner_flipped"
