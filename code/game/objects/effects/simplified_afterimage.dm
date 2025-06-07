
/atom/movable/proc/get_afterimage()
	return ""

/atom/movable/proc/spawn_afterimage(afterimage, afterimage_step)
	switch(afterimage)
		if ("red")
			new /obj/effect/afterimage/red(loc,src)
		if ("richter tackle")
			var/obj/effect/afterimage/richter_tackle/RT = new (loc,src)
			RT.overlays += image('monkestation/code/modules/bloody_cult/icons/effects.dmi', src, "castlevania_tackle", dir = turn(SOUTH, 90 * afterimage_step))

/obj/effect/afterimage
	icon = null
	icon_state = null
	anchored = 1
	mouse_opacity = 0
	var/image_color

/obj/effect/afterimage/red
	image_color = "red"

/obj/effect/afterimage/black
	image_color = "black"

/obj/effect/afterimage/richter_tackle/New()
	..()
	transform = matrix()
	pixel_x = 0
	pixel_y = 0

/obj/effect/afterimage/New(turf/loc, atom/model, fadout = 5, initial_alpha = 255, lay = CULT_OVERLAY_LAYER, pla = ABOVE_LIGHTING_PLANE)
	..()
	if(model)
		appearance = model.appearance
		invisibility = 0
		alpha = initial_alpha
		dir = model.dir
		if (image_color)
			color = image_color
		layer = lay
		plane = pla
	animate(src, alpha = 0, time = fadout)
	spawn(fadout)
		qdel(src)

/obj/effect/afterimage/narsie_act()
	return

/obj/effect/afterimage/ex_act()
	return

/obj/effect/afterimage/emp_act()
	return

/obj/effect/afterimage/blob_act()
	return

/obj/effect/afterimage/singularity_act()
	return
