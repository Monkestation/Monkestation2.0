/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/railings.dmi'
	icon_state = "railing"
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW|PASSSTRUCTURE
	layer = ABOVE_TREE_LAYER
	plane = ABOVE_GAME_PLANE
	/// armor is a little bit less than a grille. max_integrity about half that of a grille.
	armor_type = /datum/armor/structure_railing
	max_integrity = 25
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	var/climbable = TRUE
	///item released when deconstructed
	var/item_deconstruct = /obj/item/stack/rods
	/// Whether we draw joins and end caps against the railings around us.
	var/auto_join = TRUE
	/// Whether our layer drops to MOB_LAYER while we face north, so mobs standing behind us draw over us.
	var/layer_by_dir = FALSE
	/// The state and dir of the cap drawn past each end of an arm, keyed by the arm, then by the side the end is on.
	var/static/list/end_caps = list(
		"[NORTH]" = list(
			"[WEST]" = list("railing_end_flip", EAST),
			"[EAST]" = list("railing_end", WEST),
		),
		"[SOUTH]" = list(
			"[WEST]" = list("railing_end", EAST),
			"[EAST]" = list("railing_end_flip", WEST),
		),
		"[EAST]" = list(
			"[NORTH]" = list("railing_end", EAST),
			"[SOUTH]" = list("railing_end_flip", EAST),
		),
		"[WEST]" = list(
			"[NORTH]" = list("railing_end_flip", WEST),
			"[SOUTH]" = list("railing_end", WEST),
		),
	)
	/// The state and dir of the post drawn on the empty tile where two arms meet at a corner, keyed like end_caps. Only the north and south arms draw it, so a corner gets one post.
	var/static/list/corner_posts = list(
		"[NORTH]" = list(
			"[WEST]" = list("railing_corner", EAST),
			"[EAST]" = list("railing_corner", NORTH),
		),
		"[SOUTH]" = list(
			"[WEST]" = list("railing_corner", SOUTH),
			"[EAST]" = list("railing_corner", WEST),
		),
	)

/datum/armor/structure_railing
	melee = 35
	bullet = 50
	laser = 50
	energy = 100
	bomb = 10

/obj/structure/railing/unbreakable
	resistance_flags = INDESTRUCTIBLE

/obj/structure/railing/wood
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE
	auto_join = FALSE
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

/obj/structure/railing/corner/unbreakable
	resistance_flags = INDESTRUCTIBLE

/obj/structure/railing/corner/end //end of a segment of railing without making a loop
	icon_state = "railing_end"

/obj/structure/railing/corner/end/unbreakable
	resistance_flags = INDESTRUCTIBLE

/obj/structure/railing/corner/end/flip //same as above but flipped around
	icon_state = "railing_end_flip"

/obj/structure/railing/corner/end/flip/unbreakable
	resistance_flags = INDESTRUCTIBLE

/obj/structure/railing/Initialize(mapload)
	. = ..()
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

	if(layer_by_dir)
		adjust_dir_layer(dir)

	if(!mapload)
		update_neighbors()

	return INITIALIZE_HINT_LATELOAD

/obj/structure/railing/LateInitialize(mapload_arg)
	. = ..()
	if(auto_join)
		update_appearance(UPDATE_ICON)

/obj/structure/railing/Destroy()
	// grab these before ..() shoves us into nullspace, or range() finds nothing
	var/list/neighbors = get_neighbors()
	. = ..()
	for(var/obj/structure/railing/neighbor as anything in neighbors)
		if(!QDELETED(neighbor))
			neighbor.update_appearance(UPDATE_ICON)

/obj/structure/railing/setDir(newdir)
	. = ..()
	if(layer_by_dir)
		adjust_dir_layer(dir)
	update_appearance(UPDATE_ICON)
	update_neighbors()

/obj/structure/railing/proc/adjust_dir_layer(direction)
	layer = (direction & NORTH) ? MOB_LAYER : initial(layer)

/obj/structure/railing/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	update_appearance(UPDATE_ICON)
	update_neighbors()

/obj/structure/railing/examine(mob/user)
	. = ..()
	if(anchored == TRUE)
		. += span_notice("The railing is <b>bolted</b> to the floor.")
	else
		. += span_notice("The railing is <i>unbolted</i> from the floor and can be deconstructed with <b>wirecutters</b>.")

/obj/structure/railing/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	add_fingerprint(user)
	return ..()

/obj/structure/railing/welder_act(mob/living/user, obj/item/tool)
	if(user.istate & ISTATE_HARM)
		return NONE

	add_fingerprint(user)
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=1))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(!tool.use_tool(src, user, 40, volume=50))
		return ITEM_INTERACT_BLOCKING

	atom_integrity = max_integrity
	to_chat(user, span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS


/obj/structure/railing/wirecutter_act(mob/living/user, obj/item/I)
	if(flags_1 & NODECONSTRUCT_1)
		return NONE
	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("You try to cut apart the railing, but it's too hard!"))
		I.play_tool_sound(src, 100)
		return ITEM_INTERACT_BLOCKING
	if(anchored)
		balloon_alert(user, "unbolt it first!")
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_warning("You cut apart the railing."))
	I.play_tool_sound(src, 100)
	deconstruct()
	return ITEM_INTERACT_SUCCESS

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
		return . || mover.throwing || (mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
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

	if (leaving.movement_type & (PHASING|MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/// Whether we draw joins against this railing. Unbolted railings never join, they stand loose.
/obj/structure/railing/proc/joins_with(obj/structure/railing/other)
	return other != src && other.auto_join && other.anchored && !QDELETED(other)

/// The railings within one tile of us whose joins depend on us.
/obj/structure/railing/proc/get_neighbors()
	. = list()
	if(!auto_join)
		return
	for(var/obj/structure/railing/neighbor in range(1, src))
		if(neighbor != src && neighbor.auto_join)
			. += neighbor

/obj/structure/railing/proc/update_neighbors()
	for(var/obj/structure/railing/neighbor as anything in get_neighbors())
		neighbor.update_appearance(UPDATE_ICON)

/// The dirs of the joined railings on our tile that run across us. Only a railing facing one way pairs up.
/obj/structure/railing/proc/get_perpendicular_dirs()
	. = list()
	if(!auto_join || !anchored || !(dir in GLOB.cardinals))
		return
	for(var/obj/structure/railing/other in loc)
		if(joins_with(other) && (other.dir in GLOB.cardinals) && !(other.dir & (dir | REVERSE_DIR(dir))))
			. += other.dir

/// Whether a joined railing continues the end of our arm on this side.
/obj/structure/railing/proc/is_end_joined(arm, side)
	var/side_reverse = REVERSE_DIR(side)
	for(var/obj/structure/railing/other in loc)
		if(joins_with(other) && (other.dir & side))
			return TRUE
	for(var/obj/structure/railing/other in get_step(src, side))
		if(joins_with(other) && (other.dir & (arm | side_reverse)))
			return TRUE
	return FALSE

/// Whether a joined railing on the diagonal tile turns the end of our arm into a corner around the empty tile on this side.
/obj/structure/railing/proc/is_corner_joined(arm, side)
	var/side_reverse = REVERSE_DIR(side)
	for(var/obj/structure/railing/other in get_step(src, side | arm))
		if(joins_with(other) && (other.dir & side_reverse))
			return TRUE
	return FALSE

/obj/structure/railing/update_icon_state()
	. = ..()
	if(!auto_join)
		return
	// no such state. the pair overlays draw both rails as one, so the base has to draw nothing
	icon_state = length(get_perpendicular_dirs()) ? "railing_paired" : initial(icon_state)

/obj/structure/railing/update_overlays()
	. = ..()
	if(!auto_join || !anchored)
		return
	for(var/partner_dir in get_perpendicular_dirs())
		. += image(icon, null, "railing", dir = dir | partner_dir)
	for(var/arm in GLOB.cardinals)
		if(!(dir & arm))
			continue
		for(var/side in list(turn(arm, 90), turn(arm, -90)))
			if((dir & side) || is_end_joined(arm, side))
				continue
			var/list/piece_info
			if(!is_corner_joined(arm, side))
				piece_info = end_caps["[arm]"]["[side]"]
			else if(arm & (NORTH | SOUTH))
				piece_info = corner_posts["[arm]"]["[side]"]
			if(!piece_info)
				continue
			var/image/piece = image(icon, null, piece_info[1], dir = piece_info[2])
			piece.pixel_w = ((side & EAST) ? ICON_SIZE_X : 0) - ((side & WEST) ? ICON_SIZE_X : 0)
			piece.pixel_z = ((side & NORTH) ? ICON_SIZE_Y : 0) - ((side & SOUTH) ? ICON_SIZE_Y : 0)
			. += piece

/obj/structure/railing/wooden_fence
	name = "wooden fence"
	desc = "wooden fence meant to keep animals in."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing"
	item_deconstruct = /obj/item/stack/sheet/mineral/wood
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 2)
	material_flags = NONE
	auto_join = FALSE
	layer_by_dir = TRUE

/obj/structure/railing/corner/end/wooden_fence
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing_corner"

/obj/structure/railing/corner/end/flip/wooden_fence
	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_railing_corner_flipped"
