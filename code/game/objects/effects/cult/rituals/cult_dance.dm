//used by the cultdance emote. other cult dances have their own procs
/obj/effect/cult_ritual/dance
	var/list/dancers = list()
	var/list/extras = list()
	var/datum/rune_spell/tearreality/tear

/obj/effect/cult_ritual/dance/New(turf/loc, mob/first_dancer)
	..()

	if (first_dancer)
		dancers += first_dancer
		we_can_dance()


/obj/effect/cult_ritual/dance/Destroy()
	dancers = list()
	tear = null
	for (var/obj/effect/cult_ritual/dance_platform/P in extras)
		P.dance_manager = null
	extras = list()
	..()

/obj/effect/cult_ritual/dance/proc/i_can_dance(mob/living/carbon/M)
	if (!M.incapacitated())
		return  TRUE
	else if (istype(M) && istype(M.handcuffed, /obj/item/restraints/handcuffs/cult)) //prisoners will be forced to dance even if incapacitated
		return TRUE
	else if (istype(M, /mob/living/basic/construct))
		return TRUE
	return FALSE

/obj/effect/cult_ritual/dance/proc/we_can_dance()
	set waitfor = 0

	if (dancers.len <= 0)
		qdel(src)
		return

	if (tear)
		add_particles(PS_TEAR_REALITY)
		icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
		icon_state = "tear"
		while(src && loc)
			for (var/mob/M in dancers)
				if (get_dist(src, M) > 1 || !i_can_dance(M) || M.occult_muted())
					dancers -= M
					continue
			if ((dancers.len <= 0) && (tear.dance_count < tear.dance_target))
				qdel(src)
				return
			dance_move()
			sleep(3)
			dance_move()
			sleep(3)
			dance_move()
			if (tear.dance_count < tear.dance_target+10)
				adjust_particles(PVAR_SPAWNING, clamp(0.1 + 0.00375 * tear.dance_count, 0.1, 1), PS_TEAR_REALITY)
				var/scale = clamp(1 + 0.00416 * tear.dance_count, 1, 1.9)
				adjust_particles(PVAR_SCALE, list(scale, scale), PS_TEAR_REALITY)
			else
				remove_particles(PS_TEAR_REALITY)
			tear.update_crystals()
			sleep(6)
	else
		while(TRUE)
			for (var/mob/M in dancers)
				if (get_dist(src, M) > 1 || M.incapacitated() || M.occult_muted())
					dancers -= M
					continue
			if (dancers.len <= 0)
				qdel(src)
				return
			dance_step()
			sleep(3)
			dance_step()
			sleep(3)
			dance_step()
			sleep(6)

/obj/effect/cult_ritual/dance/proc/add_dancer(mob/dancer)
	if(dancer in dancers)
		return
	dancers += dancer

/obj/effect/cult_ritual/dance/proc/dance_step()
	var/dance_move = pick("clock", "counter", "spin")
	switch(dance_move)
		if ("clock")
			for (var/mob/M in dancers)
				switch (get_dir(src, M))
					if (NORTHWEST, NORTH)
						step_to(M, get_step(M, EAST))
					if (NORTHEAST, EAST)
						step_to(M, get_step(M, SOUTH))
					if (SOUTHEAST, SOUTH)
						step_to(M, get_step(M, WEST))
					if (SOUTHWEST, WEST)
						step_to(M, get_step(M, NORTH))
		if ("counter")
			for (var/mob/M in dancers)
				switch (get_dir(src, M))
					if (NORTHEAST, NORTH)
						step_to(M, get_step(M, WEST))
					if (SOUTHEAST, EAST)
						step_to(M, get_step(M, NORTH))
					if (SOUTHWEST, SOUTH)
						step_to(M, get_step(M, EAST))
					if (NORTHWEST, WEST)
						step_to(M, get_step(M, SOUTH))
		if ("spin")
			for (var/mob/M in dancers)
				spawn()
					M.dir = SOUTH
					sleep(0.75)
					M.dir = EAST
					sleep(0.75)
					M.dir = NORTH
					sleep(0.75)
					M.dir = WEST
					sleep(0.75)
					M.dir = SOUTH



/obj/effect/cult_ritual/dance/proc/dance_move()
	var/dance_move = pick("clock", "counter", "spin")
	switch(dance_move)
		if ("clock")
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				P.moving = TRUE
			for (var/mob/M in dancers)
				switch (get_dir(src, M))
					if (NORTHWEST, NORTH)
						M.forceMove(get_step(M, EAST))
						M.dir = EAST
					if (NORTHEAST, EAST)
						M.forceMove(get_step(M, SOUTH))
						M.dir = SOUTH
					if (SOUTHEAST, SOUTH)
						M.forceMove(get_step(M, WEST))
						M.dir = WEST
					if (SOUTHWEST, WEST)
						M.forceMove(get_step(M, NORTH))
						M.dir = NORTH
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				switch (get_dir(src, P))
					if (NORTHWEST, NORTH)
						step_to(P, get_step(P, EAST))
					if (NORTHEAST, EAST)
						step_to(P, get_step(P, SOUTH))
					if (SOUTHEAST, SOUTH)
						step_to(P, get_step(P, WEST))
					if (SOUTHWEST, WEST)
						step_to(P, get_step(P, NORTH))
				P.moving = FALSE
		if ("counter")
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				P.moving = TRUE
			for (var/mob/M in dancers)
				switch (get_dir(src, M))
					if (NORTHEAST, NORTH)
						M.forceMove(get_step(M, WEST))
						M.dir = WEST
					if (SOUTHEAST, EAST)
						M.forceMove(get_step(M, NORTH))
						M.dir = NORTH
					if (SOUTHWEST, SOUTH)
						M.forceMove(get_step(M, EAST))
						M.dir = EAST
					if (NORTHWEST, WEST)
						M.forceMove(get_step(M, SOUTH))
						M.dir = SOUTH
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				switch (get_dir(src, P))
					if (NORTHEAST, NORTH)
						step_to(P, get_step(P, WEST))
					if (SOUTHEAST, EAST)
						step_to(P, get_step(P, NORTH))
					if (SOUTHWEST, SOUTH)
						step_to(P, get_step(P, EAST))
					if (NORTHWEST, WEST)
						step_to(P, get_step(P, SOUTH))
				P.moving = FALSE
		if ("spin")
			for (var/mob/M in dancers)
				spawn()
					M.dir = SOUTH
					sleep(0.75)
					M.dir = EAST
					sleep(0.75)
					M.dir = NORTH
					sleep(0.75)
					M.dir = WEST
					sleep(0.75)
					M.dir = SOUTH
