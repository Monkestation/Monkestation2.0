/datum/component/particle_spewer/movement/bubble
	unusual_description = "bubble trail"
	duration = 5 SECONDS
	burst_amount = 1
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "bubble"

/datum/component/particle_spewer/movement/bubble/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()
	var/matrix/second = matrix()

	spawned.pixel_x += rand(-12,12)
	spawned.pixel_y += rand(-6,6)

	first.Turn(rand(-90, 90))
	first.Scale(0.5,0.5)
	second.Turn(rand(-90, 90))

	spawned.color = rgb(103, 183, 218)

	animate(spawned, transform = first, time = 0.4 SECONDS, pixel_y = rand(-12, 1) + spawned.pixel_y, pixel_x = rand(-32, 32) + spawned.pixel_x, easing = ELASTIC_EASING)
	animate(transform = second, time = 1 SECONDS, pixel_y = spawned.pixel_y + 32)
	animate(spawned, alpha = 0, time = duration)
	QDEL_IN(spawned, duration)
