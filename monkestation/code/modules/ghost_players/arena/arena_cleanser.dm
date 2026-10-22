/proc/reset_arena_area()
	GLOB.ghost_arena.reset_turfs()
	GLOB.ghost_arena.spawn_random_arena()

GLOBAL_DATUM(first_arena_marker, /obj/effect/ghost_arena_corner)
GLOBAL_DATUM(ghost_arena, /datum/ghost_arena)

/datum/ghost_arena
	/// The x,y coordinates of the southwest (bottom left) corner of the ghost arena.
	var/list/southwest
	/// The x,y coordinates of the southeast (bottom right) corner of the ghost arena.
	var/list/southeast
	/// The x,y coordinates of the northwest (top left) corner of the ghost arena.
	var/list/northwest
	/// The x,y coordinates of the northeast (top right) corner of the ghost arena.
	var/list/northeast

	/// The x,y coordinates of the center of the south (bottom) edge of the ghost arena.
	var/list/south
	/// The x,y coordinates of the center of the east (right) edge of the ghost arena.
	var/list/east
	/// The x,y coordinates of the center of the north (up) edge of the ghost arena.
	var/list/north
	/// The x,y coordinates of the center of the west (left) edge of the ghost arena.
	var/list/west

	/// The x,y coordinates of the center of the ghost arena.
	var/list/center

	/// The width of the ghost arena.
	var/list/width
	/// The height of the ghost arena.
	var/list/height

	/// The Z-level the ghost arena is located on.
	var/z

INITIALIZE_IMMEDIATE(/obj/effect/ghost_arena_corner)

/datum/ghost_arena/New(obj/effect/ghost_arena_corner/corner_a, obj/effect/ghost_arena_corner/corner_b)
	if(QDELETED(corner_a) || QDELETED(corner_b))
		CRASH("Tried to initialize ghost arena points with invalid corners!")
	var/turf/a = get_turf(corner_a)
	var/turf/b = get_turf(corner_b)
	if(a.z != b.z)
		CRASH("Tried to initialize ghost arena with corners on separate z-levels!")

	var/min_x = min(a.x, b.x)
	var/max_x = max(a.x, b.x)
	var/min_y = min(a.y, b.y)
	var/max_y = max(a.y, b.y)

	var/center_x = round((min_x + max_x) / 2, 1)
	var/center_y = round((min_y + max_y) / 2, 1)

	// Corners
	southwest = list(min_x, min_y)
	southeast = list(max_x, min_y)
	northeast = list(max_x, max_y)
	northwest = list(min_x, max_y)

	// Edge centers
	south = list(center_x, min_y)
	east = list(max_x, center_y)
	north = list(center_x, max_y)
	west = list(min_x, center_y)

	center = list(center_x, center_y)

	width = max_x - min_x
	height = max_y - min_y

	z = a.z

/// Gets a list of all turfs in the arena.
/datum/ghost_arena/proc/get_arena_turfs() as /list
	return block(
		southwest[1], southwest[2], z,
		northeast[1], northeast[2], z
	)

/// Resets all the turfs in the arena to indestructible plating, removing anything on the arena tiles.
/datum/ghost_arena/proc/reset_turfs()
	var/static/list/ignore_typecache = typecacheof(list(/mob/living/carbon/human/ghost, /obj/machinery/camera/motion/thunderdome))

	for(var/turf/turf in get_arena_turfs())
		for(var/mob/living/carbon/human/ghost/ghost_player in turf.get_all_contents())
			ghost_player.life_or_death()
		turf.empty(
			turf_type = /turf/open/indestructible/event/plating,
			baseturf_type = /turf/open/indestructible/event/plating,
			ignore_typecache = ignore_typecache,
			flags = CHANGETURF_IGNORE_AIR
		)
		CHECK_TICK

/datum/ghost_arena/proc/spawn_arena(datum/map_template/random_room/random_arena/arena_template, init = FALSE)
	if(!istype(arena_template))
		CRASH("Tried to spawn invalid ghost arena template [arena_template]")
	if(!init)
		reset_turfs()
	var/turf/corner = locate(southwest[1], southwest[2], z)
	log_world("Loading random arena template [arena_template.name] ([arena_template.type]) at [AREACOORD(corner)]")
	if(init)
		arena_template.stationinitload(corner, centered = arena_template.centerspawner)
		return TRUE
	else
		return arena_template.load(corner, centered = arena_template.centerspawner)

/datum/ghost_arena/proc/spawn_random_arena(init = FALSE)
	var/list/possible_arenas = list()
	for(var/arena_id in SSmapping.random_arena_templates)
		var/datum/map_template/random_room/random_arena/arena = SSmapping.random_arena_templates[arena_id]
		if(arena.weight > 0)
			possible_arenas[arena] = arena.weight
	if(!length(possible_arenas))
		return
	var/datum/map_template/random_room/random_arena/arena_to_spawn = pick_weight(possible_arenas)
	if(spawn_arena(arena_to_spawn, init))
		return arena_to_spawn

/obj/effect/ghost_arena_corner
	name = "ghost arena corner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "tdome_observer"

/obj/effect/ghost_arena_corner/Initialize(mapload)
	. = ..()
	if(GLOB.ghost_arena)
		. = INITIALIZE_HINT_QDEL
		CRASH("Tried to initialize [type] when the ghost arena corners have already been setup!")
	if(isnull(GLOB.first_arena_marker))
		GLOB.first_arena_marker = src
	else
		GLOB.ghost_arena = new(src, GLOB.first_arena_marker)
		QDEL_NULL(GLOB.first_arena_marker)
		return INITIALIZE_HINT_QDEL

/obj/effect/ghost_arena_corner/Destroy(force)
	if(GLOB.first_arena_marker == src)
		GLOB.first_arena_marker = null
	return ..()
