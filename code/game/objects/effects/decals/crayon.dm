/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	mergeable_decal = FALSE
	flags_1 = ALLOW_DARK_PAINTS_1
	var/do_icon_rotate = TRUE
	var/rotation = 0
	var/paint_colour = COLOR_WHITE
	///Used by `create_outline` to determine how strong (how wide) the outline itself will be.
	var/color_strength

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null, desc_override = null, color_strength)
	. = ..()
	if(isclosedturf(loc) && loc.density)
		// allows for wall graffiti to be seen
		SET_PLANE_IMPLICIT(src, GAME_PLANE)
		layer = FLOOR_CLEAN_LAYER
	if(e_name)
		name = e_name
	if(desc_override)
		desc = "[desc_override]"
	else
		desc = "A [name] vandalizing the station."
	if(alt_icon)
		icon = alt_icon
	if(type)
		icon_state = type
	if(graf_rot)
		rotation = graf_rot
	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M
	if(main)
		paint_colour = main
	src.color_strength = color_strength
	add_atom_colour(paint_colour, FIXED_COLOUR_PRIORITY)

/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/**
 * Using a given atom, gives this decal an outline of said atom, then masks the contents,
 * leaving us with solely the outline.
 * This also deletes the previous icon, so the decal turns into JUST an outline.
 * Args:
 * outlined_atom: Anything you wish to draw an outline of.
 * add_mouse_opacity: Boolean on whether you want mouse opacity, which allows the outline to be clickable/examinable without the context menu.
 */
/obj/effect/decal/cleanable/crayon/proc/create_outline(mob/living/outlined_atom, add_mouse_opacity = FALSE)
	var/icon/outline_icon = getFlatIcon(outlined_atom.appearance, defdir = outlined_atom.dir, no_anim = TRUE)
	if(istype(outlined_atom))
		outline_icon.Turn(outlined_atom.get_lying_angle())
	icon = outline_icon

	if(add_mouse_opacity)
		mouse_opacity = MOUSE_OPACITY_OPAQUE

	add_filter("crayon_outline", 1, outline_filter(color_strength, paint_colour))
	add_filter("alpha_mask", 2, alpha_mask_filter(
		icon = outline_icon,
		flags = MASK_INVERSE,
	))

///Common crayon decals in map.
/obj/effect/decal/cleanable/crayon/rune4
	icon_state = "rune4"
	paint_colour = COLOR_CRAYON_RED

/obj/effect/decal/cleanable/crayon/rune2
	icon_state = "rune2"

/obj/effect/decal/cleanable/crayon/x
	icon_state = "x"
	name = "graffiti"
	paint_colour = COLOR_CRAYON_ORANGE

/obj/effect/decal/cleanable/crayon/l
	icon_state = "l"

/obj/effect/decal/cleanable/crayon/i
	icon_state = "i"

/obj/effect/decal/cleanable/crayon/e
	icon_state = "e"

/obj/effect/decal/cleanable/crayon/i/orange
	name = "graffiti"
	paint_colour = COLOR_CRAYON_ORANGE
