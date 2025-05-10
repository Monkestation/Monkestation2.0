/obj/effect/cult_ritual/tear_spawners
	icon = 'icons/effects/effects.dmi'
	icon_state = "blank"
	density = 0
	mouse_opacity = 0
	invisibility = 101
	var/datum/rune_spell/tearreality/source = null
	var/finished = FALSE
	var/direction = 0
	var/steps = 0

	var/near_turfs = list()
	var/far_turfs = list()

/obj/effect/cult_ritual/tear_spawners/New(turf/loc, var/datum/rune_spell/tearreality/_source)
	if (!_source)
		qdel(src)
		return
	source = _source
	if (source.destroying_self)
		qdel(src)
		return
	..()
	if (!finished)
		start_loop()

/obj/effect/cult_ritual/tear_spawners/Destroy()
	source = null
	..()

/obj/effect/cult_ritual/tear_spawners/proc/perform_step()
	move_step()
	after_step()

/obj/effect/cult_ritual/tear_spawners/proc/start_loop()
	set waitfor = 0
	spawn()
		while(!finished && direction)
			perform_step()
			sleep(1)

/obj/effect/cult_ritual/tear_spawners/proc/execute(level)
	return
/obj/effect/cult_ritual/tear_spawners/proc/after_step()
	return
/obj/effect/cult_ritual/tear_spawners/proc/move_step()
	switch(direction)
		if (SOUTH)
			y--
			if (y <= TRANSITIONEDGE)
				finished = TRUE
				qdel(src)
				return
		if (NORTH)
			y++
			if (y >= (world.maxy - TRANSITIONEDGE))
				finished = TRUE
				qdel(src)
		if (EAST)
			x++
			if (x >= (world.maxx - TRANSITIONEDGE))
				finished = TRUE
				qdel(src)
		if (WEST)
			x--
			if (x <= TRANSITIONEDGE)
				finished = TRUE
				qdel(src)
				return

	steps++
