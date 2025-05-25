/datum/component/particle_spewer/heart
	unusual_description = "hearts"
	duration = 2 SECONDS
	burst_amount = 1
	spawn_interval = 1.3 SECONDS
	particle_state = "heart"
	particle_blending = BLEND_ADD

/datum/component/particle_spewer/heart/animate_particle(obj/effect/abstract/particle/spawned)
	spawned.pixel_x += rand(-6,6)
	spawned.pixel_y += rand(-4,4)

	if(prob(35))
		spawned.layer = ABOVE_MOB_LAYER

	spawned.alpha = 130

	. = ..()

/datum/component/particle_spewer/heart/adjust_animate_steps()
	animate_holder.add_animation_step(list(alpha = 255, time = 0.8 SECONDS, pixel_y = "RANDOM", pixel_x = "RANDOM", easing = LINEAR_EASING))
	animate_holder.set_random_var(1, "pixel_y", list(6, 16))
	animate_holder.set_parent_copy(1, "pixel_y")
	animate_holder.set_random_var(1, "pixel_x", list(-4, 4))
	animate_holder.set_parent_copy(1, "pixel_x")

	animate_holder.add_animation_step(list(alpha = 0, time = 0.8 SECONDS, pixel_x = "RANDOM", pixel_y = "RANDOM", easing = LINEAR_EASING|EASE_OUT))
	animate_holder.set_random_var(2, "pixel_y", list(6, 16))
	animate_holder.set_random_var(2, "pixel_x", list(-4, 4))
	animate_holder.set_parent_copy(2, "pixel_y")
	animate_holder.set_parent_copy(2, "pixel_x", FALSE)
