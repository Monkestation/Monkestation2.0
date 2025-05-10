
/obj/effect/cult_ritual/tear_spawners/vertical_spawner
	direction = SOUTH
	var/steps_to_pillars_and_gateways = 16
	var/steps_to_pillars = 8

	var/ready_to_spawn_pillars_and_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/vertical_spawner/after_step()
	if (steps == steps_to_pillars)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/left(loc, source)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/right(loc, source)
	if (steps == steps_to_pillars_and_gateways)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left(loc, source)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right(loc, source)
		ready_to_spawn_pillars_and_gateways = TRUE
		steps = 0

	if (ready_to_spawn_pillars_and_gateways)
		if (isopenturf(loc))
			new /obj/effect/cult_ritual/tear_spawners/gateway_spawner/special(loc, source)
			ready_to_spawn_pillars_and_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/vertical_spawner/up
	direction = NORTH
