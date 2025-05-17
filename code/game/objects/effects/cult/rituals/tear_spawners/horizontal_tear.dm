
/obj/effect/cult_ritual/tear_spawners/horizontal_spawner
	var/steps_to_spire = 8
	var/steps_to_gateway = 15
	var/also_spawn_gateways = TRUE

	var/ready_to_spawn_pillar = FALSE
	var/ready_to_spawn_gateway = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/after_step()
	if (steps == steps_to_spire)
		ready_to_spawn_pillar = TRUE
	if (also_spawn_gateways && steps == steps_to_gateway)
		ready_to_spawn_gateway = TRUE
	if (steps == (2*steps_to_spire))
		ready_to_spawn_pillar = TRUE
		steps = 0

	if (ready_to_spawn_pillar)
		if (isopenturf(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, direction)
			ready_to_spawn_pillar = FALSE

	if (ready_to_spawn_gateway)
		if (isopenturf(loc))
			new /obj/effect/cult_ritual/tear_spawners/gateway_spawner(loc, source)
			ready_to_spawn_gateway = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt
	steps = 4
	also_spawn_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left
	direction = WEST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right
	direction = EAST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/left
	direction = WEST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/right
	direction = EAST
