/obj/effect/stun_indicator
	icon = null
	anchored = 1
	mouse_opacity = 0
	var/list/viewers = list()
	var/image/indicator = null
	var/current_dots = 6
	var/mob/living/victim = null

/obj/effect/stun_indicator/New()
	..()
	if (!ismob(loc))
		qdel(src)
		return

	victim = loc
	if (isalien(victim))
		current_dots = clamp(round(victim.AmountParalyzed() / 10), 0, 5)
	else
		current_dots = clamp(round(victim.AmountKnockdown() / 10), 0, 5)

	if (!current_dots)
		qdel(src)
		return

	current_dots++//so we get integers from 1 to 6

	for (var/mob/M in GLOB.player_list)
		if (IS_CULTIST(M) && M.client)
			viewers += M.client

	indicator = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', loc = victim, icon_state = "")
	update_indicator()

/obj/effect/stun_indicator/proc/update_indicator()
	set waitfor = FALSE
	while (victim && (victim.stat < DEAD) && (victim.AmountKnockdown() || (isalien(victim) && victim.AmountParalyzed())))
		for (var/client/C in viewers)
			C.images -= indicator
		var/dots = clamp(1+round(victim.AmountKnockdown() / 10), 1, 6)
		if (isalien(victim))
			dots = clamp(1+round(victim.AmountParalyzed() / 10), 1, 6)
		var/anim = 0
		if (dots != current_dots)
			anim = 1
			current_dots = dots
		indicator.overlays.len = 0
		indicator = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', loc = victim, icon_state = "")
		SET_PLANE_EXPLICIT(indicator, GAME_PLANE_UPPER, victim)
		indicator.pixel_y = 8
		for (var/i = 1 to dots)
			var/state = "stun_dot1"
			if (current_dots == i)
				if (anim)
					state = "stun_dot2-flick"
					var/image/I = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', icon_state = "stun_dot-gone")
					SET_PLANE_EXPLICIT(I, GAME_PLANE_UPPER, victim)
					I = place_indicator(I, i+1)
					indicator.overlays += I
				else
					state = "stun_dot2"
			var/image/I = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', icon_state = state)
			SET_PLANE_EXPLICIT(I, GAME_PLANE_UPPER, victim)
			I = place_indicator(I, i)
			indicator.overlays += I
		for (var/client/C in viewers)
			C.images += indicator
		sleep(10)
	qdel(src)

/obj/effect/stun_indicator/proc/place_indicator(image/I, dot)
	switch (dot)
		if (2, 3)
			I.pixel_x = -8
		if (5, 6)
			I.pixel_x = 8
	switch (dot)
		if (2, 6)
			I.pixel_y = 4
		if (3, 5)
			I.pixel_y = -4
		if (1)
			I.pixel_y = 8
		if (4)
			I.pixel_y = -8
	return I



/obj/effect/stun_indicator/Destroy()
	for (var/client/C in viewers)
		C.images -= indicator
	indicator = null
	victim = null
	..()

/obj/effect/stun_indicator/narsie_act()
	return

/obj/effect/stun_indicator/ex_act()
	return

/obj/effect/stun_indicator/emp_act()
	return

/obj/effect/stun_indicator/blob_act()
	return

/obj/effect/stun_indicator/singularity_act()
	return
