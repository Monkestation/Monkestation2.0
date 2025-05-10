
/obj/effect/bloodcult_jaunt
	mouse_opacity = 0
	icon = 'monkestation/code/modules/bloody_cult/icons/96x96.dmi'
	icon_state ="cult_jaunt"
	invisibility = SEE_INVISIBLE_LIVING
	alpha = 127
	plane = ABOVE_LIGHTING_PLANE
	pixel_x = -32
	pixel_y = -32
	animate_movement = 0
	var/atom/movable/rider = null//lone user?
	var/list/packed = list()//moving a lot of stuff?

	var/turf/starting = null
	var/turf/target = null

	var/dist_x = 0
	var/dist_y = 0
	var/dx = 0
	var/dy = 0
	var/error = 0
	var/target_angle = 0

	var/override_starting_X = 0
	var/override_starting_Y = 0
	var/override_target_X = 0
	var/override_target_Y = 0

	//update_pixel stuff
	var/PixelX = 0
	var/PixelY = 0

	var/initial_pixel_x = 0
	var/initial_pixel_y = 0

	var/obj/effect/abstract/landing_animation = null
	var/landing = 0

	var/force_jaunt = FALSE

	var/failsafe = 100

/obj/effect/bloodcult_jaunt/New(turf/loc, mob/user, turf/destination, turf/packup, mob/activator)
	..()
	if (!user && !packup && !force_jaunt)
		qdel(src)
		return
	if (user)
		var/muted = FALSE
		if (user.anchored)
			to_chat(user, span_warning("The blood jaunt fails to grasp you as you are currently anchored.") )
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			if (C.occult_muted())
				muted = TRUE
				to_chat(C, span_warning("The holy energies upon your body repel the blood jaunt.") )
		if (!muted && !user.anchored)
			user.forceMove(src)
			rider = user
			if (ismob(rider))
				var/mob/M = rider
				M.see_invisible = SEE_INVISIBLE_LIVING
	if (packup)
		var/list/noncult_victims = list()
		for (var/atom/movable/AM in packup)
			if (AM.anchored)
				if (ismob(AM))
					var/mob/M = AM
					to_chat(M, span_warning("The blood jaunt fails to grasp you as you are currently anchored.") )
				continue
			var/muted = FALSE
			if (iscarbon(AM))
				var/mob/living/carbon/C = AM
				if (C.occult_muted())
					muted = TRUE
					to_chat(C, span_warning("The holy energies upon your body repel the blood jaunt.") )
				if(!IS_CULTIST(C))
					noncult_victims += C
			if (!AM.anchored && !muted)
				AM.forceMove(src)
				packed.Add(AM)
				if (ismob(AM))
					var/mob/M = AM
					M.see_invisible = SEE_INVISIBLE_LIVING
	starting = loc
	target = destination
	initial_pixel_x = pixel_x
	initial_pixel_y = pixel_y
	//first of all, if our target is off Z-Level, we're immediately teleporting to the edge of the map closest to the target
	if (target?.z != z)
		move_to_edge()
	//quickly making sure that we're not jaunting to where we are
	bump_target_check()
	if (!src||!loc)
		return
	//calculating how many tiles we should have to cross so we can abort the jaunt if we go off-track
	failsafe = abs(starting.x - target.x) + abs(starting.y - target.y)
	//next, let's rotate the jaunter's sprite to face our destination
	init_angle()
	//now, let's launch the jaunter at our target
	init_jaunt()

/obj/effect/bloodcult_jaunt/Destroy()
	if (rider)
		QDEL_NULL(rider)
	if (packed.len > 0)
		for(var/atom/A in packed)
			qdel(A)
	packed = list()
	..()

/obj/effect/bloodcult_jaunt/narsie_act()
	return

/obj/effect/bloodcult_jaunt/ex_act()
	return

/obj/effect/bloodcult_jaunt/emp_act()
	return

/obj/effect/bloodcult_jaunt/blob_act()
	return

/obj/effect/bloodcult_jaunt/singularity_act()
	return

/obj/effect/bloodcult_jaunt/Bump(atom/bumped_atom)
	. = ..()
	forceMove(get_step(loc, dir))
	bump_target_check()

/obj/effect/bloodcult_jaunt/proc/move_to_edge()
	var/target_x
	var/target_y
	var/dx = abs(target.x - world.maxx/2)
	var/dy = abs(target.y - world.maxy/2)
	if (dx > dy)
		target_y = world.maxy/2 + rand(-4, 4)
		if (target.x > world.maxx/2)
			target_x = world.maxx - TRANSITIONEDGE - rand(16, 20)
		else
			target_x = TRANSITIONEDGE + rand(16, 20)
	else
		target_x = world.maxx/2 + rand(-4, 4)
		if (target.y > world.maxy/2)
			target_y = world.maxy - TRANSITIONEDGE - rand(16, 20)
		else
			target_y = TRANSITIONEDGE + rand(16, 20)

	var/turf/T = locate(target_x, target_y, target.z)
	starting = T
	forceMove(T)

/obj/effect/bloodcult_jaunt/proc/init_angle()
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)

	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y

	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

	target_angle = round(get_angle(starting, target))
	var/transform_matrix = turn(matrix(), target_angle+45)
	transform = transform_matrix

/obj/effect/bloodcult_jaunt/proc/update_pixel()
	if(src && starting && target)
		var/AX = (override_starting_X - src.x)*32
		var/AY = (override_starting_Y - src.y)*32
		var/BX = (override_target_X - src.x)*32
		var/BY = (override_target_Y - src.y)*32
		var/XXcheck = ((BX-AX)*(BX-AX))+((BY-AY)*(BY-AY))
		if(!XXcheck)
			return
		var/XX = (((BX-AX)*(-BX))+((BY-AY)*(-BY)))/XXcheck

		PixelX = round(BX+((BX-AX)*XX))
		PixelY = round(BY+((BY-AY)*XX))

		PixelX += initial_pixel_x
		PixelY += initial_pixel_y

		pixel_x = PixelX
		pixel_y = PixelY

/obj/effect/bloodcult_jaunt/proc/bresenham_step(distA, distB, dA, dB)
	var/dist = get_dist(src, target)
	if (dist > 135)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist > 45)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist > 15)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist < 10 && !landing)
		landing = 1
		playsound(src.target, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_prepare.ogg', 75, 0, -3)
		landing_animation = anim(target = src.target, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", plane = GAME_PLANE_UPPER)
	return make_bresenham_step(distA, distB, dA, dB)

/obj/effect/bloodcult_jaunt/proc/make_bresenham_step(var/distA, distB, dA, dB)
	if(error < 0)
		var/atom/step = get_step(src, dB)
		if(!step)
			qdel(src)
		src.Move(step)
		failsafe--
		error += distA
		bump_target_check()
		return 0//so that we don't move twice slower in diagonals
	else
		var/atom/step = get_step(src, dA)
		if(!step)
			qdel(src)
		src.Move(step)
		failsafe--
		error -= distB
		dir = dA
		if(error < 0)
			dir = dA + dB
		bump_target_check()
		return 1

/obj/effect/bloodcult_jaunt/proc/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(dist_x > dist_y)
			sleeptime = bresenham_step(dist_x, dist_y, dx, dy)
		else
			sleeptime = bresenham_step(dist_y, dist_x, dy, dx)
		update_pixel()
		sleep(sleeptime)

/obj/effect/bloodcult_jaunt/proc/init_jaunt()
	set waitfor = 0
	if (!rider && packed.len <= 0 && !force_jaunt)
		qdel(src)
		return
	spawn while(loc)
		if (ismob(rider))
			var/mob/M = rider
			M.next_click += 3
		for(var/mob/M in packed)
			M.next_click += 3
		process_step()

/obj/effect/bloodcult_jaunt/proc/bump_target_check()
	if (loc == target || failsafe <= 0)
		playsound(target, 'monkestation/code/modules/bloody_cult/sound/cultjaunt_land.ogg', 30, 0, -3)
		if (force_jaunt)
			playsound(target, 'monkestation/code/modules/bloody_cult/sound/convert_failure.ogg', 30, 0, -1)
		if (rider)
			rider.forceMove(target)
			if (ismob(rider))
				var/mob/M = rider
				M.see_invisible = 0
				var/jaunter = FALSE
				for (var/obj/effect/cult_ritual/seer/seer_ritual in seer_rituals)
					if (seer_ritual.caster == M)
						jaunter = TRUE
						break
				if (!jaunter)
					M.see_invisible = 0
				if (iscarbon(rider))
					var/mob/living/carbon/C = rider
					if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult))
						to_chat(C, span_danger("Traveling through the veil seems to have a recharging effect on the ghastly bindings as they begin to hurt you anew.") )
			rider = null
		if (packed.len > 0)
			for(var/atom/movable/AM in packed)
				AM.forceMove(target)
				if (ismob(AM))
					var/mob/M = AM
					M.see_invisible = SEE_INVISIBLE_LIVING
					for (var/obj/effect/cult_ritual/seer/seer_ritual in seer_rituals)
						if (seer_ritual.caster == M)
							break
					if (iscarbon(AM))
						var/mob/living/carbon/C = AM
						if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult))
							to_chat(C, span_danger("Traveling through the veil seems to have a recharging effect on the ghastly bindings as they begin to hurt you anew.") )
			packed = list()

		if (landing_animation)
			flick("cult_jaunt_land", landing_animation)
		qdel(src)

/obj/effect/bloodcult_jaunt/traitor
	invisibility = 0
	alpha = 200
	force_jaunt = TRUE

/obj/effect/bloodcult_jaunt/traitor/init_jaunt()
	animate(src, alpha = 0, time = 3)
	..()

/obj/effect/bloodcult_jaunt/visible
	invisibility = 0
	alpha = 255
