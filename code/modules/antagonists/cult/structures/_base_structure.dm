
/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	max_integrity = 50
	obj_flags = CAN_BE_HIT
	var/sound_damaged = null
	var/sound_destroyed = null
	var/conceal_cooldown = 0
	var/timeleft = 0
	var/timetotal = 0
	var/list/contributors = list()// list of cultists currently participating in the ritual
	var/min_contributors = 1 	  // how many cultists we need for the current ritual
	var/image/progbar = null//progress bar
	var/cancelling = 3//check to abort the ritual if interrupted
	var/custom_process = 0
	//if we have a map id we create a holomap marker
	var/map_id
	var/marker_icon = 'monkestation/code/modules/bloody_cult/icons/holomap_markers.dmi'
	var/marker_icon_state

/obj/structure/cult/Initialize(mapload)
	. = ..()
	if(map_id)
		var/datum/holomap_marker/holomarker = new(src)
		holomarker.id = map_id
		holomarker.filter = HOLOMAP_FILTER_CULT
		holomarker.x = src.x
		holomarker.y = src.y
		holomarker.z = src.z
		holomarker.icon = marker_icon
		holomarker.icon_state = marker_icon_state

/obj/structure/cult/get_cult_power()
	return 1//light emitted by those won't be reduced during the eclipse

/obj/structure/cult/proc/conceal()
	var/obj/structure/cult/concealed/C = new(loc)
	C.pixel_x = pixel_x
	C.pixel_y = pixel_y
	forceMove(C)
	C.held = src
	C.icon = icon
	C.icon_state = icon_state

/obj/structure/cult/proc/reveal()
	conceal_cooldown = 1
	spawn (100)
		if(src && loc)
			conceal_cooldown = 0

/obj/structure/cult/concealed
	density = 0
	anchored = 1
	alpha = 127
	invisibility = INVISIBILITY_OBSERVER
	var/obj/structure/cult/held = null

/obj/structure/cult/concealed/reveal()
	if(held)
		held.forceMove(loc)
		held.reveal()
		held = null
	qdel(src)

/obj/structure/cult/concealed/conceal()
	return

/obj/structure/cult/concealed/takeDamage(damage)
	return

//if you want indestructible buildings, just make a custom takeDamage() proc
/obj/structure/cult/proc/takeDamage(damage)
	atom_integrity -= damage
	if(atom_integrity <= 0)
		if(sound_destroyed)
			playsound(src, sound_destroyed, 100, 1)
		qdel(src)
	else
		update_appearance()

//duh
/obj/structure/cult/narsie_act()
	. = ..()
	return

/obj/structure/cult/ex_act(severity)
	switch(severity)
		if(1)
			takeDamage(100)
		if(2)
			takeDamage(20)
		if(3)
			takeDamage(4)

/obj/structure/cult/blob_act()
	playsound(src, sound_damaged, 75, 1)
	takeDamage(20)

/obj/structure/cult/bullet_act(obj/projectile/Proj)
	takeDamage(Proj.damage)
	return ..()

/obj/structure/cult/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon))
		if(!(user.istate & ISTATE_HARM )|| weapon.force == 0)
			visible_message(span_warning("\The [user] gently taps \the [src] with \the [weapon].") )
		else
			user.do_attack_animation(src, weapon)
			if(sound_damaged)
				playsound(src, sound_damaged, 75, 1)
			if(isholyweapon(weapon))
				takeDamage(weapon.force*2)
			else
				takeDamage(weapon.force)
			visible_message(span_warning("\The [user] hits \the [src] with \the [weapon].") )
			..()


/obj/structure/cult/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/cult/attack_hand(mob/living/user)
	if(user.istate & ISTATE_HARM)
		user.visible_message(span_danger("[user.name] [pick("kicks", "punches")] \the [src]!") , \
							span_danger("You strike at \the [src]!") , \
							"You hear stone cracking.")
		user.adjustBruteLoss(3)
		if(sound_damaged)
			playsound(src, sound_damaged, 75, 1)
	else if(IS_CULTIST(user))
		cultist_act(user)
	else
		noncultist_act(user)

/obj/structure/cult/proc/cultist_act(mob/user)
	return 1

/obj/structure/cult/proc/noncultist_act(mob/user)
	to_chat(user, span_cult("You feel madness taking its toll, trying to figure out \the [name]'s purpose") )
	//might add some hallucinations or brain damage later, checks for cultist chaplains, etc
	return 1

/obj/structure/cult/proc/safe_space()
	for(var/turf/turf in range(5, src))
		var/dist = cheap_pythag(turf.x - src.x, turf.y - src.y)
		if(dist <= 2.5)
			turf.ChangeTurf(/turf/open/floor/engine/cult)
			turf.turf_animation('monkestation/code/modules/bloody_cult/icons/effects.dmi', "cultfloor", 0, 0, MOB_LAYER-1, anim_plane = GAME_PLANE)
			for(var/obj/structure/structure in turf)
				if(!istype(structure, /obj/structure/cult))
					qdel(structure)
			for(var/obj/machinery/machine in turf)
				qdel(machine)
		else if(dist <= 4.5)
			if(istype(turf, /turf/open/space))
				turf.ChangeTurf(/turf/open/floor/engine/cult)
				turf.turf_animation('monkestation/code/modules/bloody_cult/icons/effects.dmi', "cultfloor", 0, 0, MOB_LAYER-1, anim_plane = GAME_PLANE)
			else
				turf.narsie_act()
		else if(dist <= 5.5)
			if(istype(turf, /turf/open/space))
				turf.ChangeTurf(/turf/closed/wall/mineral/cult)
				turf.turf_animation('monkestation/code/modules/bloody_cult/icons/effects.dmi', "cultwall", 0, 0, MOB_LAYER-1, anim_plane = GAME_PLANE)
			else
				turf.narsie_act()

//inspired from LoZ:Oracle of Seasons
/obj/structure/cult/proc/dance_start()
	while(timeleft > 0)
		for(var/mob/contributor in contributors)
			if(!IS_CULTIST(contributor) || get_dist(src, contributor) > 1 || contributor.incapacitated() || contributor.occult_muted())
				if(contributor.client)
					contributor.client.images -= progbar
				contributors.Remove(contributor)
				continue
		if(contributors.len <= 0)
			return 0
		if(contributors.len < min_contributors)
			sleep(10)
			continue
		timeleft -= 1 + round(contributors.len/2)//Additional dancers will complete the ritual faster
		update_progbar()
		dance_step()
		sleep(3)
		dance_step()
		sleep(3)
		dance_step()
		sleep(6)
	for(var/mob/contributor in contributors)
		if(contributor.client)
			contributor.client.images -= progbar
		ritual_reward(contributor)
		contributors.Remove(contributor)
	return 1

/obj/structure/cult/proc/ritual_reward(mob/contributor)
	return

/obj/structure/cult/proc/dance_step()
	var/dance_move = pick("clock", "counter", "spin")

	switch(dance_move)
		if("clock")
			for(var/mob/contributor in contributors)
				switch(get_dir(src, contributor))
					if(NORTHWEST, NORTH)
						contributor.forceMove(get_step(contributor, EAST))
						contributor.dir = EAST
					if(NORTHEAST, EAST)
						contributor.forceMove(get_step(contributor, SOUTH))
						contributor.dir = SOUTH
					if(SOUTHEAST, SOUTH)
						contributor.forceMove(get_step(contributor, WEST))
						contributor.dir = WEST
					if(SOUTHWEST, WEST)
						contributor.forceMove(get_step(contributor, NORTH))
						contributor.dir = NORTH
		if("counter")
			for(var/mob/contributor in contributors)
				switch(get_dir(src, contributor))
					if(NORTHEAST, NORTH)
						contributor.forceMove(get_step(contributor, WEST))
						contributor.dir = WEST
					if(SOUTHEAST, EAST)
						contributor.forceMove(get_step(contributor, NORTH))
						contributor.dir = NORTH
					if(SOUTHWEST, SOUTH)
						contributor.forceMove(get_step(contributor, EAST))
						contributor.dir = EAST
					if(NORTHWEST, WEST)
						contributor.forceMove(get_step(contributor, SOUTH))
						contributor.dir = SOUTH
		if("spin")
			for(var/mob/contributor in contributors)
				spawn()
					contributor.dir = SOUTH
					sleep(0.75)
					contributor.dir = EAST
					sleep(0.75)
					contributor.dir = NORTH
					sleep(0.75)
					contributor.dir = WEST
					sleep(0.75)
					contributor.dir = SOUTH

