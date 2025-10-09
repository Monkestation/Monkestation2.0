/datum/component/particle_spewer/movement/falling_leaves
	unusual_description = "flighty leaves"
	icon_file = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'
	particle_state = "leaf2"
	burst_amount = 2
	duration = 6 SECONDS
	random_bursts = TRUE
	spawn_interval = 0.4 SECONDS

/datum/component/particle_spewer/movement/falling_leaves/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix(rand(1, 60), MATRIX_ROTATE)
	var/chance = rand(1, 10)
	switch(chance)
		if(1 to 2)
			spawned.icon_state = "leaf1"
		if(3 to 5)
			spawned.icon_state = "leaf2"
		if(5 to 10)
			spawned.icon_state = "leaf3"

	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER
	spawned.pixel_x += rand(-12, 12)
	spawned.pixel_y += rand(5, 10)
	spawned.transform = first
	spawned.alpha = 10

	. = ..()

/datum/component/particle_spewer/movement/falling_leaves/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 1 SECONDS, pixel_y = "RANDOM", alpha = 255, easing = LINEAR_EASING))
	animate_holder.set_random_var(1, "pixel_y", list(-16, -12))
	animate_holder.set_random_var(1, "transform", list(-60, 60))
	animate_holder.set_transform_type(1, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(time = duration, alpha = 1, easing = LINEAR_EASING))
