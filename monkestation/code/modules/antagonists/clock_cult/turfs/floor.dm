/turf/open/indestructible/reebe_void
	name = "void"
	desc = "A white, empty void, quite unlike anything you've seen before."
	icon_state = "reebemap"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_dirt = FALSE
	init_air = FALSE
	///is this turf walkable
	var/walkable = FALSE

/turf/open/indestructible/reebe_void/Initialize(mapload)
	. = ..()
	icon_state = "reebegame"

/turf/open/indestructible/reebe_void/Enter(atom/movable/movable)
	if(walkable)
		return ..()

	if(!..())
		return FALSE
	else
		if(istype(movable, /obj/structure/window))
			return FALSE
		if(istype(movable, /obj/projectile))
			return TRUE
		return FALSE

/turf/open/indestructible/reebe_void/RemoveLattice()
	return

/turf/open/indestructible/reebe_void/walkable
	icon_state = "reebespawn"
	baseturfs = /turf/open/indestructible/reebe_void/walkable
	walkable = TRUE

/turf/open/indestructible/reebe_void/spawning
	icon_state = "reebespawn"

/turf/open/indestructible/reebe_void/spawning/Initialize(mapload)
	. = ..()
	if(mapload)
		if(prob(2))
			new /obj/structure/fluff/clockwork/alloy_shards/large(src)

		if(prob(4))
			new /obj/structure/fluff/clockwork/alloy_shards/medium(src)

		if(prob(6))
			new /obj/structure/fluff/clockwork/alloy_shards/small(src)

/turf/open/indestructible/reebe_void/spawning/lattices
	icon_state = "reebelattice"

/turf/open/indestructible/reebe_void/spawning/lattices/Initialize(mapload)
	. = ..()
	if(mapload && prob(40))
		new /obj/structure/lattice/clockwork(src)

//edge of the reebe map
/turf/open/indestructible/reebe_void/void_edge
	icon_state = "reebespawn"

/turf/open/indestructible/reebe_flooring //used on reebe
	name = "clockwork floor"
	desc = "You feel a faint warmth from below it."
	icon_state = "clockwork_floor"
	planetary_atmos = TRUE
	baseturfs = /turf/open/indestructible/reebe_flooring
	turf_flags = NOJAUNT

/turf/open/indestructible/reebe_flooring/ratvar_act()
	return FALSE

/turf/open/indestructible/reebe_flooring/flat
	icon_state = "reebe"

/turf/open/indestructible/reebe_flooring/filled
	icon_state = "clockwork_floor_filled"

/turf/open/floor/engine/clockwork
	name = "clockwork floor"
	desc = "You feel a faint warmth from below it."
	icon_state = "clockwork_floor"
