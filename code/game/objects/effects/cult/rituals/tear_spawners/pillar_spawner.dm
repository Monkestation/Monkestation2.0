
/obj/effect/cult_ritual/tear_spawners/pillar_spawner
	finished = TRUE
	var/obj/structure/cult/pillar

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/New(turf/loc, datum/rune_spell/tearreality/_source, _direction)
	if (!_direction)
		qdel(src)
		return
	..()
	if (source)
		source.pillar_spawners += src
	direction = _direction

	for(var/direc in GLOB.cardinals)
		var/turf/T = get_step(src, direc)
		near_turfs += T
		var/turf/U = get_step(T, direc)
		far_turfs += U

	for(var/direc in GLOB.diagonals)
		var/turf/T = get_step(src, direc)
		far_turfs += T

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/move_step()
	return

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/execute(level)
	switch(level)
		if (1)
			var/turf/T = loc
			if (T)
				T.narsie_act()
		if (2)
			var/turf/T = loc
			if (T)
				switch(direction)
					if (EAST)
						pillar = new /obj/structure/cult/pillar/alt(loc)

					if (WEST)
						pillar = new /obj/structure/cult/pillar(loc)
			for (var/turf/U in near_turfs)
				U.narsie_act()
		if (3)
			if (pillar)
				pillar.update_icon()
			for (var/turf/T in far_turfs)
				T.narsie_act()

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/proc/cancel()
	if (!pillar)
		qdel(src)
		return
	spawn(rand(1 SECONDS, 5 SECONDS))
		if (pillar)
			pillar.takeDamage(100)
		for (var/turf/T in far_turfs)
			T.decultify()
		sleep(rand(10 SECONDS, 20 SECONDS))
		if (pillar)
			pillar.takeDamage(100)
		for (var/turf/T in near_turfs)
			T.decultify()
		sleep(rand(20 SECONDS, 30 SECONDS))
		var/turf/T = loc
		T.decultify()
