/datum/component/particle_spewer/movement/shooting_star
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "starsmall"

	unusual_description = "shooting star"
	duration = 5 SECONDS
	burst_amount = 6
	offsets = FALSE

/datum/component/particle_spewer/movement/shooting_star/animate_particle(obj/effect/abstract/particle/spawned)

	spawned.dir = move_dir
	if(prob(30))
		spawned.icon_state = "starlarge"
	if(move_dir & (NORTH|SOUTH))
		spawned.pixel_x += rand(-16, 16)

	if(move_dir & (EAST|WEST))
		spawned.pixel_y += rand(-16, 16)

	switch(move_dir)
		if(NORTH)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_y = spawned.pixel_y + 160, alpha = 25)
		if(SOUTH)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_y = spawned.pixel_y - 160, alpha = 25)
		if(EAST)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_x = spawned.pixel_x + 160, alpha = 25)
		if(WEST)
			animate(spawned, time = rand(0.5 SECONDS, duration), pixel_x = spawned.pixel_x - 160, alpha = 25)
