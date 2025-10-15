/datum/component/particle_spewer/sakura
	unusual_description = "sakura"
	icon_file = 'monkestation/code/modules/outdoors/icons/effects/particles/particle.dmi'
	particle_state = "petals1"
	burst_amount = 5
	duration = 9 SECONDS
	random_bursts = TRUE
	spawn_interval = 4 SECONDS

/datum/component/particle_spewer/sakura/animate_particle(obj/effect/abstract/particle/spawned)
	spawned.icon_state = "petals1"

	if(prob(65))
		spawned.layer = LOW_ITEM_LAYER
	spawned.pixel_x += rand(-12, 12)
	spawned.pixel_y += rand(-5, 10)
	. = ..()

/datum/component/particle_spewer/sakura/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(0.5, 0.5, MATRIX_SCALE), alpha = 125, time = 0))

	animate_holder.add_animation_step(list(transform = "RANDOM", time = 2 SECONDS, pixel_y = "RANDOM", pixel_x = "RANDOM", easing = LINEAR_EASING))

	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_random_var(2, "pixel_x", list(-16, 16))
	animate_holder.set_random_var(2, "pixel_y", list(-16, 16))
	animate_holder.set_transform_type(2, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(alpha = 25, time = 5 SECONDS))
