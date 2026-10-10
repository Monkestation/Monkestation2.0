/// Icon that sits in something's vis_contents and blends on top of it.
/obj/effect/abstract/blank
	name = ""
	alpha = 150
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon ='icons/obj/xenobiology/slime_rancher/filters.dmi'
	icon_state = "diag"
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	blend_mode = BLEND_INSET_OVERLAY


/obj/effect/abstract/blank/overlay
	name = ""
	alpha = 150
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon ='icons/obj/xenobiology/slime_rancher/filters.dmi'
	icon_state = "diag"
	vis_flags = NONE
	blend_mode = 0

	var/id


/atom/movable/proc/rainbow_effect() // this just animates between the primary colors of a rainbow
	var/obj/effect/abstract/blank/rainbow_effect = new

	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += rainbow_effect
	ADD_TRAIT(src, TRAIT_RAINBOWED, "rainbow")

/// Undoes rainbow_effect().
/atom/movable/proc/remove_rainbow_effect()
	var/obj/effect/abstract/blank/rainbow_effect = locate() in vis_contents
	qdel(rainbow_effect)
	REMOVE_TRAIT(src, TRAIT_RAINBOWED, "rainbow")

/image/proc/rainbow_effect() // this just animates between the primary colors of a rainbow
	var/obj/effect/abstract/blank/rainbow_effect = new

	appearance_flags &= ~KEEP_APART
	appearance_flags |= KEEP_TOGETHER
	vis_contents += rainbow_effect

/// Squishes the atom up and down in a loop.
/atom/proc/ungulate()
	var/matrix/ungulate_matrix = matrix(transform)
	ungulate_matrix.Scale(1, 0.9)
	var/matrix/base_matrix = matrix(transform)
	var/base_pixel_y = pixel_y

	animate(src, transform = ungulate_matrix, time = 0.1 SECONDS, easing = EASE_OUT, loop = -1)
	animate(pixel_y = -1, time = 0.1 SECONDS, easing = EASE_OUT)
	animate(transform = base_matrix, time = 0.1 SECONDS, easing = EASE_IN)
	animate(pixel_y = base_pixel_y, time = 0.1 SECONDS, easing = EASE_IN)
