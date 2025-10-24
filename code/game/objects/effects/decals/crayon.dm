/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE
	flags_1 = ALLOW_DARK_PAINTS_1
	var/do_icon_rotate = TRUE
	var/rotation = 0
	var/paint_colour = "#FFFFFF"
	///Used by `create_outline` to determine how strong (how wide) the outline itself will be.
	var/color_strength

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null, color_strength)
	. = ..()
	if(e_name)
		name = e_name
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

/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/T)
	return isgroundlessturf(T)

/**
 * Using a given atom, gives this decal an outline of said atom, then masks the contents,
 * leaving us with solely the outline.
 * This also deletes the previous icon, so the decal turns into JUST an outline.
 * Args:
 * outlined_atom: Anything you wish to draw an outline of.
 * add_mouse_opacity: Boolean on whether you want mouse opacity, which allows the outline to be clickable/examinable without the context menu.
 */
/obj/effect/decal/cleanable/crayon/proc/create_outline(atom/outlined_atom, add_mouse_opacity = FALSE)
	icon = null
	icon_state = null
	if(add_mouse_opacity)
		mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(ishuman(outlined_atom))
		//humans are special, we want to exclude things like wounds so the outline isn't animated.
		var/mob/living/carbon/human/human_outline = outlined_atom
		add_overlay(human_outline.get_overlays_copy(list(WOUND_LAYER, HALO_LAYER)))
	else
		icon = outlined_atom.icon
		icon_state = outlined_atom.icon_state
		copy_overlays(outlined_atom)
	transform = outlined_atom.transform
	dir = outlined_atom.dir
	add_filter("crayon_outline", 1, outline_filter(color_strength, paint_colour))
	add_filter("alpha_mask", 2, alpha_mask_filter(
		icon = getFlatIcon(outlined_atom.appearance, defdir = outlined_atom.dir, no_anim = TRUE),
		flags = MASK_INVERSE,
	))
