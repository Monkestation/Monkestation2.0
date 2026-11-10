#define HOLE_SLIDE_TIME (0.5 SECONDS)

/obj/effect/temp_visual/wonderland_hole
	name = "rabbit hole"
	icon = 'icons/mob/red_rabbit.dmi'
	icon_state = "wonderland_hole"
	plane = GAME_PLANE
	layer = BELOW_OBJ_LAYER
	randomdir = FALSE
	duration = 1.5 SECONDS
	pixel_x = -(ICON_SIZE_X / 2)
	pixel_y = -ICON_SIZE_Y + 4

/obj/effect/temp_visual/wonderland_hole/Initialize(mapload)
	. = ..()
	if(!isturf(loc) || isgroundlessturf(loc))
		return INITIALIZE_HINT_QDEL
	playsound(src, 'sound/effects/magic/paradoxskip.ogg', vol = 50, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, pressure_affected = FALSE)

	var/atom/movable/warp_effect/ripple = new(loc)
	ripple.transform = matrix().Scale(0.1)
	animate(ripple, transform = matrix().Scale(1), alpha = 0, time = 0.6 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	QDEL_IN(ripple, 0.6 SECONDS)

	transform = matrix().Scale(0.1)
	animate(src, transform = matrix(), time = 0.25 SECONDS, easing = BACK_EASING | EASE_OUT)
	animate(time = 0.9 SECONDS)
	animate(transform = matrix().Scale(0.1), alpha = 0, time = 0.35 SECONDS)

/// The body already moved the instant the power fired, so this copy is what actually sinks (or rises) while everyone watches
/obj/effect/temp_visual/rabbit_hole_stand_in
	randomdir = FALSE
	duration = HOLE_SLIDE_TIME
	appearance_flags = KEEP_TOGETHER
	/// Sits still inside us while we slide. Masks put straight on a copied appearance get ignored, so the mask lives on us instead
	var/obj/effect/abstract/copy

/obj/effect/temp_visual/rabbit_hole_stand_in/Initialize(mapload, atom/movable/original, rising = FALSE, delay = 0)
	duration += delay
	. = ..()
	if(QDELETED(original))
		return INITIALIZE_HINT_QDEL
	copy = new(src)
	copy.appearance = copy_appearance_filter_overlays(original.appearance, recursion = 1)
	copy.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	vis_contents += copy
	if(isitem(original))
		// held or bagged items look like hud stuff, drag them back down to the floor
		copy.pixel_x = 0
		copy.pixel_y = 0
		layer = OBJ_LAYER
		SET_PLANE_EXPLICIT(src, GAME_PLANE, src)
	else
		layer = original.layer
		SET_PLANE_EXPLICIT(src, PLANE_TO_TRUE(original.plane), src)
	if(!delay)
		rabbit_hole_slide(src, rising)
		return
	alpha = 0
	addtimer(CALLBACK(src, PROC_REF(late_slide), rising), delay)

/obj/effect/temp_visual/rabbit_hole_stand_in/Destroy()
	vis_contents -= copy
	QDEL_NULL(copy)
	return ..()

/obj/effect/temp_visual/rabbit_hole_stand_in/proc/late_slide(rising)
	alpha = 255
	rabbit_hole_slide(src, rising)

/// Slides a sprite down (or up) through the floor. The mask climbs as the sprite drops, so the cut line stays put
/proc/rabbit_hole_slide(atom/movable/thing, rising)
	var/static/icon/white = icon('icons/effects/alphacolors.dmi', "white")
	var/start_mask = rising ? ICON_SIZE_Y : 0
	var/easing = QUAD_EASING | (rising ? EASE_OUT : EASE_IN)
	thing.add_filter("rabbit_hole_cut", 1, alpha_mask_filter(icon = white, y = start_mask))
	if(rising)
		thing.pixel_z -= ICON_SIZE_Y
	animate(thing, pixel_z = rising ? ICON_SIZE_Y : -ICON_SIZE_Y, time = HOLE_SLIDE_TIME, easing = easing, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	// has to be parallel too, or the filter never animates and the mask stays stuck at its start
	thing.transition_filter("rabbit_hole_cut", alpha_mask_filter(y = ICON_SIZE_Y - start_mask), HOLE_SLIDE_TIME, easing, flags = ANIMATION_PARALLEL)

/proc/climb_out_of_rabbit_hole(mob/living/climber)
	if(climber.body_position != STANDING_UP)
		return
	rabbit_hole_slide(climber, rising = TRUE)
	addtimer(CALLBACK(climber, TYPE_PROC_REF(/datum, remove_filter), "rabbit_hole_cut"), HOLE_SLIDE_TIME)

/proc/deliver_thru_rabbit_hole(obj/item/package, turf/destination)
	new /obj/effect/temp_visual/wonderland_hole(destination)
	new /obj/effect/temp_visual/rabbit_hole_stand_in(destination, package, TRUE)
	addtimer(CALLBACK(package, TYPE_PROC_REF(/atom/movable, forceMove), destination), HOLE_SLIDE_TIME)

#undef HOLE_SLIDE_TIME
