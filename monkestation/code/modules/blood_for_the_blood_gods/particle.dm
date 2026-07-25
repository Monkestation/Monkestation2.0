/// Blood drip subtype meant to be thrown around as a particle
/obj/effect/decal/cleanable/blood/particle
	name = "blood droplet"
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	plane = GAME_PLANE
	layer = BELOW_MOB_LAYER
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.2
	mergeable_decal = FALSE
	/// Whether or not we transfer our pixel_x and pixel_y to the splatter, only works for floor splatters though
	var/messy_splatter = TRUE
	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc

/obj/effect/decal/cleanable/blood/particle/Initialize(mapload)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(QDELETED(loc))
		return INITIALIZE_HINT_QDEL

/obj/effect/decal/cleanable/blood/particle/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/particle/proc/start_movement(movement_angle)
	prev_loc = loc
	get_or_init_physics()?.set_angle(movement_angle)

/obj/effect/decal/cleanable/blood/particle/proc/get_or_init_physics() as /datum/component/movable_physics
	RETURN_TYPE(/datum/component/movable_physics)
	if(QDELETED(src))
		return
	return LoadComponent(/datum/component/movable_physics, \
		horizontal_velocity = rand(3 * 100, 5.5 * 100) * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * 0.01, \
		horizontal_friction = rand(0.05 * 100, 0.1 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		vertical_conservation_of_momentum = 0.1, \
		z_floor = 0, \
		bounce_callback = CALLBACK(src, PROC_REF(on_bounce)), \
		bump_callback = CALLBACK(src, PROC_REF(on_bump)), \
	)

/obj/effect/decal/cleanable/blood/particle/proc/on_bounce()
	if(QDELETED(src))
		return

	else if(loc == prev_loc || !isturf(loc) || QDELING(loc))
		qdel(src)
		return

	for(var/atom/movable/iter_atom in loc)
		if(iter_atom == src || iter_atom.invisibility || iter_atom.alpha <= 0 || (isobj(iter_atom) && !iter_atom.density))
			continue
		iter_atom.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

	var/obj/effect/decal/cleanable/blood/splatter/splatter = new(loc, null, GET_ATOM_BLOOD_DNA(src))
	splatter.adjust_bloodiness(splatter.bloodiness * -0.66)
	splatter.update_appearance()
	qdel(src)

/obj/effect/decal/cleanable/blood/particle/proc/on_bump(atom/bumped_atom)
	if(QDELETED(src) || QDELING(loc) || QDELETED(bumped_atom))
		return

	if(loc == prev_loc)
		return

	var/obj/effect/decal/cleanable/final_splatter

	if(iswallturf(bumped_atom))
		//Adjust pixel offset to make splatters appear on the wall
		final_splatter = new /obj/effect/decal/cleanable/blood/splatter/over_window(prev_loc, null, GET_ATOM_BLOOD_DNA(src))
		var/dir_to_wall = get_dir(src, bumped_atom)
		final_splatter.pixel_x = (dir_to_wall & EAST ? world.icon_size : (dir_to_wall & WEST ? -world.icon_size : 0))
		final_splatter.pixel_y = (dir_to_wall & NORTH ? world.icon_size : (dir_to_wall & SOUTH ? -world.icon_size : 0))
		qdel(src)
		return TRUE

	else if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/the_window = bumped_atom

		if(!the_window.fulltile)
			return FALSE

		final_splatter = new /obj/effect/decal/cleanable/blood/splatter/over_window(prev_loc, null, GET_ATOM_BLOOD_DNA(src))
		final_splatter.forceMove(the_window)
		the_window.vis_contents += final_splatter
		qdel(src)
		return TRUE

	qdel(src)
