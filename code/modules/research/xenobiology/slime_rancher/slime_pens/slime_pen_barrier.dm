/// Do pen fences stop this thing? (slimes, monkeys, and basic mobs worth biomass)
/proc/is_slime_pen_contained(atom/movable/mover)
	if(isslime(mover) || ismonkeybasic(mover))
		return TRUE
	if(!isbasicmob(mover))
		return FALSE
	var/mob/living/basic/critter = mover
	return critter.biomass_value > 0

/// One edge of a pen's fence, keeps slimes and their snacks from wandering off
/obj/structure/slime_pen_barrier
	name = "containment field"
	desc = "A shimmering mesh strung between two pen posts. Slimes bounce off it. You won't."
	icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi'
	icon_state = "barrier"
	flags_1 = ON_BORDER_1
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = INFINITY
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	/// Adds the little connector sprite so the corner doesn't have a gap
	var/top_row = FALSE
	/// Color of this piece, as a hex string
	var/barrier_color = SLIME_PEN_DEFAULT_COLOR

/obj/structure/slime_pen_barrier/Initialize(mapload, new_dir, top_row = FALSE)
	. = ..()
	setDir(new_dir)
	src.top_row = top_row
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_offsets()
	sync_with_twin()

/obj/structure/slime_pen_barrier/Destroy(force)
	find_twin()?.sync_with_twin()
	return ..()

/// The barrier on the other side of our edge, if the neighboring pen has one.
/obj/structure/slime_pen_barrier/proc/find_twin() as /obj/structure/slime_pen_barrier
	var/turf/across = get_step(loc, dir)
	if(isnull(across))
		return null
	var/facing_us = REVERSE_DIR(dir)
	for(var/obj/structure/slime_pen_barrier/barrier in across)
		if(barrier.dir == facing_us && !QDELING(barrier))
			return barrier
	return null

/// Puts the sprite on the tile border and picks whether mobs draw in front of us or behind us.
/obj/structure/slime_pen_barrier/proc/update_offsets()
	SET_PLANE_IMPLICIT(src, dir == SOUTH ? GAME_PLANE_UPPER : GAME_PLANE)
	// the extra 2px keeps us level with the posts, which sit up off the tile line so they don't draw over the wall below
	switch(dir)
		if(NORTH)
			pixel_w = 0
			pixel_z = 15
			layer = BELOW_MOB_LAYER
		if(SOUTH)
			pixel_w = 0
			pixel_z = 2
			layer = ABOVE_MOB_LAYER
		if(EAST)
			pixel_w = 6
			pixel_z = 8
			layer = BELOW_MOB_LAYER + 0.02
		if(WEST)
			pixel_w = -6
			pixel_z = 8
			layer = BELOW_MOB_LAYER + 0.02

/// pokes the twin too, since only one of us is actually visible
/obj/structure/slime_pen_barrier/proc/set_barrier_color(new_color)
	barrier_color = new_color
	sync_with_twin()
	find_twin()?.sync_with_twin()

/// Picks whether we or our twin gets drawn, and mixes our colors together
/obj/structure/slime_pen_barrier/proc/sync_with_twin()
	var/obj/structure/slime_pen_barrier/twin = find_twin()
	// two pens sharing an edge would draw the same fence twice, so one of us hides - south always takes priority over north or east
	var/hidden = twin && (dir & (NORTH|EAST))
	alpha = hidden ? 0 : 255
	var/final_color = barrier_color
	if(twin && twin.barrier_color != barrier_color)
		final_color = blend_hue_colors(barrier_color, twin.barrier_color)
	if(final_color == SLIME_PEN_DEFAULT_COLOR)
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		add_atom_colour(color_transition_filter(final_color), FIXED_COLOUR_PRIORITY)
	update_appearance()
	if(twin)
		twin.alpha = hidden ? 255 : 0
		twin.update_appearance()

/// fancy HSL color blend that actually looks kinda good
/proc/blend_hue_colors(first_color, second_color)
	var/list/first_hsl = rgb2num(first_color, COLORSPACE_HSL)
	var/list/second_hsl = rgb2num(second_color, COLORSPACE_HSL)
	var/x = cos(first_hsl[1]) + cos(second_hsl[1])
	var/y = sin(first_hsl[1]) + sin(second_hsl[1])
	var/hue = arctan(x, y)
	if(hue < 0)
		hue += 360
	var/saturation = (first_hsl[2] + second_hsl[2]) * 0.5
	var/lightness = (first_hsl[3] + second_hsl[3]) * 0.5
	return rgb(hue, saturation, lightness, space = COLORSPACE_HSL)

/obj/structure/slime_pen_barrier/update_overlays()
	. = ..()
	if(!alpha)
		return
	var/mutable_appearance/glow = emissive_appearance(icon, "barrier", src)
	glow.dir = dir
	. += glow
	if(!top_row)
		return
	var/mutable_appearance/connector = mutable_appearance(icon, "barrier_half")
	connector.dir = dir
	connector.pixel_z = 7
	. += connector
	var/mutable_appearance/connector_glow = emissive_appearance(icon, "barrier_half", src)
	connector_glow.dir = dir
	connector_glow.pixel_z = 7
	. += connector_glow

/obj/structure/slime_pen_barrier/CanAllowThrough(atom/movable/mover, border_dir)
	// we're not dense, so the parent always says yes and we're the only one who can say no
	if(border_dir == dir && should_block(mover))
		return FALSE
	return ..()

/obj/structure/slime_pen_barrier/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(direction != dir || leaving == src)
		return
	if(!should_block(leaving))
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/// Should the fence stop this thing from moving thru?
/obj/structure/slime_pen_barrier/proc/should_block(atom/movable/mover)
	if(!is_slime_pen_contained(mover))
		return FALSE
	var/mob/living/critter = mover
	if(critter.movement_type & PHASING)
		return FALSE
	if(critter.pulledby || critter.buckled || critter.throwing)
		return FALSE
	return TRUE

/obj/structure/slime_pen_barrier/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return dir != to_dir || !pass_info.slime_pen_contained
