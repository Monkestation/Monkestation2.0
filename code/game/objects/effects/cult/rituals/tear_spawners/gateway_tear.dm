
/obj/effect/cult_ritual/tear_spawners/gateway_spawner
	finished = TRUE

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/New(turf/loc, datum/rune_spell/tearreality/_source)
	..()
	source?.gateway_spawners += src

	for(var/direc in GLOB.cardinals)
		var/turf/T = get_step(src, direc)
		near_turfs += T
		var/turf/U = get_step(T, direc)
		far_turfs += U

	for(var/direc in GLOB.diagonals)
		var/turf/T = get_step(src, direc)
		far_turfs += T

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/move_step()
	return

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/special
	finished = FALSE

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/special/start_loop()
	spawn()
		x++
		if (isopenturf(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, EAST)
		sleep(1)
		x -= 2
		if (isopenturf(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, WEST)
		sleep(1)
		x++
	finished = TRUE
