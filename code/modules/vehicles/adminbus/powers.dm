///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

/obj/vehicle/ridden/adminbus//Fucking release the passengers and unbuckle yourself from the bus before you delete it.
	name = "\improper Adminbus"
	desc = "Shit just got fucking real."
	icon = 'monkestation/code/modules/bloody_cult/icons/bus.dmi'
	icon_state = "adminbus"
	plane = ABOVE_GAME_PLANE
	pass_flags = PASSMOB
	pixel_x = -32
	pixel_y = -32
	max_buckled_mobs = 16
	max_occupants = 16
	var/can_move = 1
	var/list/passengers = list()
	var/unloading = 0
	var/bumpers = 1//1 = capture mobs 2 = roll over mobs(deals light brute damage and push them down) 3 = gib mobs
	var/door_mode = 0//0 = closed door, players cannot climb or leave on their own 1 = openned door, players can climb and leave on their own
	var/list/spawned_mobs = list()//keeps track of every mobs spawned by the bus, so we can remove them all with the push of a button in needed
	var/hook = 1
	var/list/hookshot = list()
	var/obj/structure/singulo_chain/chain_base = null
	var/list/chain = list()
	var/obj/singularity/singulo = null
	var/roadlights = 0
	var/obj/structure/buslight/lightsource = null
	var/list/spawnedbombs = list()
	var/list/spawnedlasers = list()
	var/obj/structure/teleportwarp/warp = null

/obj/vehicle/ridden/adminbus/New()
	..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/adminbus)
	var/turf/T = get_turf(src)
	T.turf_animation('monkestation/code/modules/bloody_cult/icons/160x160.dmi', "busteleport", -64, -32, MOB_LAYER+1, 'monkestation/code/modules/bloody_cult/sound/busteleport.ogg', anim_plane = ABOVE_GAME_PLANE)
	var/image/underbus = image(icon, "underbus", MOB_LAYER-1)
	underbus.plane = GAME_PLANE
	overlays += underbus
	overlays += image(icon, "ad")
	src.dir = EAST
	playsound(src, 'monkestation/code/modules/bloody_cult/sound/adminbus.ogg', 50, 0, 0)
	lightsource = new/obj/structure/buslight(src.loc)
	update_lightsource()
	warp = new/obj/structure/teleportwarp(src.loc)

/obj/vehicle/ridden/adminbus/Destroy()
	for(var/i = passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			freed(L)

	delete_bombs()
	delete_lasers()
	remove_mobs()

	for(var/obj/structure/singulo_chain/N in chain)
		chain -= N
		qdel(N)

	for(var/obj/structure/hookshot/H in hookshot)
		hookshot -= H
		qdel(H)

	QDEL_NULL(warp)
	QDEL_NULL(lightsource)
	QDEL_NULL(singulo)

	var/turf/T = get_turf(src)
	T.turf_animation('monkestation/code/modules/bloody_cult/icons/160x160.dmi', "busteleport", -32*2, -32, MOB_LAYER+1, 'monkestation/code/modules/bloody_cult/sound/busteleport.ogg', anim_plane = ABOVE_GAME_PLANE)

	..()

/*
/obj/vehicle/ridden/adminbus/update_mob()
	if(occupant)
		if(iscorgi(occupant))//Hail Ian
			switch(dir)
				if(SOUTH)
					occupant.pixel_x = 6 * 1
					occupant.pixel_y = -4 * 1
				if(WEST)
					occupant.pixel_x = -16 * 1
					occupant.pixel_y = 9 * 1
				if(NORTH)
					occupant.pixel_x = 0
					occupant.pixel_y = 0
				if(EAST)
					occupant.pixel_x = 16 * 1
					occupant.pixel_y = 9 * 1
		else
			switch(dir)
				if(SOUTH)
					occupant.pixel_x = 7 * 1
					occupant.pixel_y = -12 * 1
				if(WEST)
					occupant.pixel_x = -25 * 1
					occupant.pixel_y = 1 * 1
				if(NORTH)
					occupant.pixel_x = 0
					occupant.pixel_y = 0
				if(EAST)
					occupant.pixel_x = 25 * 1
					occupant.pixel_y = 1 * 1

	for(var/i = 1;i< = passengers.len;i++)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			switch(i)
				if(1, 5, 9, 13)
					switch(dir)
						if(SOUTH)
							L.pixel_x = -6 * 1
							L.pixel_y = 0
						if(WEST)
							L.pixel_x = -13 * 1
							L.pixel_y = 4 * 1
						if(NORTH)
							L.pixel_x = -6 * 1
							L.pixel_y = 0
						if(EAST)
							L.pixel_x = 12 * 1
							L.pixel_y = 4 * 1
				if(2, 6, 10, 14)
					switch(dir)
						if(SOUTH)
							L.pixel_x = 6 * 1
							L.pixel_y = 0
						if(WEST)
							L.pixel_x = -1 * 1
							L.pixel_y = 4 * 1
						if(NORTH)
							L.pixel_x = 6 * 1
							L.pixel_y = 0
						if(EAST)
							L.pixel_x = 1 * 1
							L.pixel_y = 4 * 1
				if(3, 7, 11, 15)
					switch(dir)
						if(SOUTH)
							L.pixel_x = -3 * 1
							L.pixel_y = 8 * 1
						if(WEST)
							L.pixel_x = 11 * 1
							L.pixel_y = 4 * 1
						if(NORTH)
							L.pixel_x = -3 * 1
							L.pixel_y = 8 * 1
						if(EAST)
							L.pixel_x = -11 * 1
							L.pixel_y = 4 * 1
				if(4, 8, 12, 16)
					switch(dir)
						if(SOUTH)
							L.pixel_x = 7 * 1
							L.pixel_y = -12 * 1
						if(WEST)
							L.pixel_x = 22 * 1
							L.pixel_y = 4 * 1
						if(NORTH)
							L.pixel_x = -3 * 1
							L.pixel_y = 8 * 1
						if(EAST)
							L.pixel_x = -22 * 1
							L.pixel_y = 4 * 1
			L.dir = dir
*/

/obj/vehicle/ridden/adminbus/Move(atom/newloc, direction, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = get_turf(src)
	. = ..()
	update_lightsource()
	handle_mob_bumping()
	if(warp)
		warp.forceMove(loc)

	if(chain_base)
		chain_base.move_child(T)
	for(var/obj/structure/hookshot/H in hookshot)
		H.forceMove(get_step(H, src.dir))

/obj/vehicle/ridden/adminbus/proc/update_lightsource()
	var/turf/T = get_step(src, src.dir)
	if(T.opacity)
		lightsource.forceMove(T)
		switch(roadlights)							//if the bus is right against a wall, only the wall's tile is lit
			if(0)
				if(lightsource.light_outer_range != 0)
					lightsource.set_light(0)
			if(1, 2)
				if(lightsource.light_outer_range != 1)
					lightsource.set_light(1)
	else
		T = get_step(T, src.dir)						//if there is a wall two tiles in front of the bus, the lightsource is right in front of the bus, though weaker
		if(T.opacity)
			lightsource.forceMove(get_step(src, src.dir))
			switch(roadlights)
				if(0)
					if(lightsource.light_outer_range != 0)
						lightsource.set_light(0)
				if(1)
					if(lightsource.light_outer_range != 1)
						lightsource.set_light(1)
				if(2)
					if(lightsource.light_outer_range != 2)
						lightsource.set_light(2)
		else
			lightsource.forceMove(T)
			switch(roadlights)						//otherwise, the lightsource position itself two tiles in front of the bus and with regular light_range
				if(0)
					if(lightsource.light_outer_range != 0)
						lightsource.set_light(0)
				if(1)
					if(lightsource.light_outer_range != 2)
						lightsource.set_light(2)
				if(2)
					if(lightsource.light_outer_range != 3)
						lightsource.set_light(3)


/obj/vehicle/ridden/adminbus/proc/handle_mob_bumping()
	var/turf/S = get_turf(src)
	switch(bumpers)
		if(1)
			for(var/mob/living/L in S)
				if(!ishuman(L))
					continue
				if(L in occupants)
					continue
				if(!L.client)
					continue
				if(passengers.len < 16)
					capture_mob(L)
				else
					var/mob/living/occupant = occupants[1]
					if(occupant)
						to_chat(occupant, span_warning("There is no place in the bus for any additional passenger.") )
		if(2)
			var/hit_sound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			for(var/mob/living/L in S)
				if(L in occupants)
					continue
				L.take_overall_damage(5, 0)
				if(L.buckled)
					L.buckled = 0
				L.Stun(5)
				L.Knockdown(5)
				playsound(src, pick(hit_sound), 50, 0, 0)
		if(3)
			for(var/mob/living/L in S)
				if(L in occupants)
					continue
				L.gib()
				//playsound(src, 'monkestation/code/modules/bloody_cult/sound/bloodyslice.ogg', 50, 0, 0)

/obj/vehicle/ridden/adminbus/proc/capture_mob(atom/A, var/selfclimb = 0)
	if(passengers.len >= 16)
		to_chat(A, span_warning("\The [src] is full!") )
		return
	if(unloading)
		return
	if(isliving(A))
		var/mob/living/M = A
		if(M.faction == "adminbus mob")
			return
		M.forceMove(loc)
		M.setDir(dir)
		passengers += M
		buckle_mob(M, TRUE)
		if(!selfclimb)
			to_chat(M, span_warning("\The [src] picks you up!") )
			var/mob/living/occupant = occupants[1]
			if(occupant)
				to_chat(occupant, "[M.name] captured!")
		to_chat(M, span_notice("Welcome aboard \the [src]. Please keep your hands and arms inside the bus at all times.") )
		src.add_fingerprint(M)
	update_rearview()

/obj/vehicle/ridden/adminbus/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(get_dist(src, M) > 1|| M.buckled || M.stat|| M.buckled|| istype(M, /mob/living/silicon))
		return
	var/list/drivers = return_drivers()
	if(!(check_rights_for(M.client, R_ADMIN)) && !length(drivers))
		to_chat(M, span_notice("You're a god alright, but you don't seem to have your Adminbus driver license!") )
		return
	. = ..()
/*
/obj/vehicle/ridden/adminbus/manual_unbuckle(mob/user, var/resisting = FALSE)
	if(occupant && occupant == user)	//Are you the driver?
		var/mob/living/M = occupant
		M.visible_message(
			span_notice("[M.name] unbuckles \himself!") ,
			"You unbuckle yourself from \the [src].")
		unlock_atom(M)
		src.add_fingerprint(user)
	else
		if(door_mode)
			if(locate(user) in passengers)
				freed(user)
				return
			else
				capture_mob(user, 1)
				return
		else
			if(istype(user, /mob/living/carbon/human/dummy) || istype(user, /mob/living/simple_animal/corgi/Ian))
				if(locate(user) in passengers)
					freed(user)
					return
				else
					capture_mob(user, 1)
					return
			else
				if(locate(user) in passengers)
					to_chat(user, span_notice("You may not leave the Adminbus at the current time.") )
					return
				else
					to_chat(user, span_notice("You may not climb into \the [src] while its door is closed.") )
					return
*/

/obj/vehicle/ridden/adminbus/proc/add_HUD(var/mob/user)
	user.DisplayUI("Adminbus")

/obj/vehicle/ridden/adminbus/proc/remove_HUD(var/mob/M)
	M.HideUI("Adminbus")

/obj/vehicle/ridden/adminbus/proc/update_rearview()
	var/mob/living/occupant = occupants[1]
	if(occupant)
		occupant.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_top_panel)

/obj/vehicle/ridden/adminbus/emp_act(severity)
	return

/obj/vehicle/ridden/adminbus/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	visible_message(span_warning("The projectile harmlessly bounces off the bus.") )
	return ..()

/obj/vehicle/ridden/adminbus/ex_act(severity)
	visible_message(span_warning("The bus withstands the explosion with no damage.") )
	return

/obj/vehicle/ridden/adminbus/blob_act()
	return

/obj/vehicle/ridden/adminbus/singularity_act()
	return 0

/obj/vehicle/ridden/adminbus/singularity_pull()
	return 0

/////HOOKSHOT/////////

/obj/structure/hookshot
	name = "admin chain"
	desc = "Who knows what these chains can hold..."
	icon = 'monkestation/code/modules/bloody_cult/icons/singulo_chain.dmi'
	icon_state = "chain"
	pixel_x = -32
	pixel_y = -32
	density = 0
	plane = ABOVE_LIGHTING_PLANE
	var/max_distance = 7
	var/obj/vehicle/ridden/adminbus/abus = null
	var/dropped = 0

/obj/structure/hookshot/claw
	name = "admin claw"
	icon = 'monkestation/code/modules/bloody_cult/icons/96x96.dmi'
	icon_state = "singulo_catcher"
	pixel_x = -32
	pixel_y = -32

/obj/structure/hookshot/claw/proc/hook_throw(var/toward)
	max_distance--
	var/obj/singularity/S = locate(/obj/singularity) in src.loc
	if(S)
		return S
	else
		var/obj/structure/hookshot/H = new/obj/structure/hookshot(src.loc)
		abus.hookshot += H
		H.dir = toward
		H.max_distance = max_distance
		H.abus = abus
	if(max_distance > 0)
		forceMove(get_step(src, toward))
		sleep(2)
		var/obj/singularity/S2 = hook_throw(toward)
		if(S2)
			return S2
		else
			return null
	else
		return null

/obj/structure/hookshot/proc/hook_back()
	forceMove(get_step_towards(src, abus))
	max_distance++
	if(max_distance >= 7)
		abus.hookshot -= src
		qdel(src)
		return
	sleep(2)
	.()

/obj/structure/hookshot/claw/hook_back()
	if(!dropped)
		var/obj/singularity/S = locate(/obj/singularity) in src.loc
		if(S)
			abus.capture_singulo(S)
			if(length(abus.occupants))
				var/mob/living/M = abus.occupants[1]
				M.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
			return
	forceMove(get_step_towards(src, abus))
	max_distance++
	if(max_distance >= 7)
		abus.hookshot -= src
		abus.hook = 1
		if(length(abus.occupants))
			var/mob/living/M = abus.occupants[1]
			M.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
		qdel(src)
		return
	sleep(2)
	.()

/obj/structure/hookshot/ex_act(severity)
	return

/obj/structure/hookshot/singularity_act()
	return 0

/obj/structure/hookshot/singularity_pull()
	return 0

/////SINGULO CHAIN/////////

/obj/structure/singulo_chain
	name = "singularity chain"
	desc = "Admins are above all logic."
	icon = 'monkestation/code/modules/bloody_cult/icons/singulo_chain.dmi'
	icon_state = "chain"
	pixel_x = -32
	pixel_y = -32
	density = 0
	var/obj/structure/singulo_chain/child = null

/obj/structure/singulo_chain/anchor
	icon_state = ""
	var/obj/singularity/target = null

/obj/structure/singulo_chain/ex_act(severity)
	return

/obj/structure/singulo_chain/proc/move_child(var/turf/parent)
	var/turf/T = get_turf(src)
	if(parent)//I don't see how this could be null but a sanity check won't hurt
		forceMove(parent)
	if(child)
		if(get_dist(src, child) > 1)
			child.move_child(T)
		dir = get_dir(child, src)
	else
		dir = get_dir(T, src)

/obj/structure/singulo_chain/anchor/move_child(var/turf/parent)
	var/turf/T = get_turf(src)
	if(parent)
		forceMove(parent)
	else
		dir = get_dir(T, src)
	if(target)
		target.forceMove(loc)


/obj/structure/singulo_chain/singularity_act()
	return 0

/obj/structure/singulo_chain/singularity_pull()
	return 0

/////ROADLIGHTS/////////

/obj/structure/buslight//the things you have to do to pretend that your bus has directional lights...
	name = ""
	desc = ""
	icon = null
	icon_state = null
	anchored = 1
	density = 0
	opacity = 0
	mouse_opacity = 0

/obj/structure/buslight/ex_act(severity)
	return

/obj/structure/buslight/singularity_act()
	return 0

/obj/structure/buslight/singularity_pull()
	return 0


/////TELEPORT WARP/////////

/obj/structure/teleportwarp
	name = "teleportation warp"
	desc = "The bus is about to jump..."
	icon = 'monkestation/code/modules/bloody_cult/icons/160x160.dmi'
	icon_state = ""
	pixel_x = -64
	pixel_y = -64
	anchored = 1
	density = 0
	mouse_opacity = 0

/obj/structure/teleportwarp/ex_act(severity)
	return

/obj/structure/teleportwarp/singularity_pull()
	return 0

/*
/datum/locking_category/adminbus/lock(var/atom/movable/AM)
	. = ..()
	if (isliving(AM))
		var/mob/living/M = AM
		var/obj/vehicle/ridden/adminbus/bus = owner
		M.flags |= INDESTRUCTIBLE
		bus.add_HUD(M)
		M.register_event(/event/living_login, bus, /obj/vehicle/ridden/adminbus/proc/add_HUD)

/datum/locking_category/adminbus/unlock(var/atom/movable/AM)
	. = ..()
	if (isliving(AM))
		var/mob/living/M = AM
		var/obj/vehicle/ridden/adminbus/bus = owner
		M.flags &= ~INDESTRUCTIBLE
		bus.remove_HUD(M)
		M.unregister_event(/event/living_login, bus, /obj/vehicle/ridden/adminbus/proc/add_HUD)

/obj/vehicle/ridden/adminbus/dissolvable()
	return 0
*/

/obj/vehicle/ridden/adminbus/add_occupant(mob/M, control_flags)
	. = ..()
	M.store_position()
	ADD_TRAIT(M, TRAIT_GODMODE, type)
	if(!(M in passengers))
		capture_mob(M)
	var/list/drivers = return_drivers()
	for(var/mob/living/driver as anything in drivers)
		if(driver.mind)
			if("Adminbus" in driver.mind.active_uis)
				continue
			add_HUD(driver)

/obj/vehicle/ridden/adminbus/remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_GODMODE, type)
	freed(M)
	var/list/drivers = return_drivers()
	if(!(M in drivers))
		return
	remove_HUD(M)

/datum/component/riding/vehicle/adminbus
	vehicle_move_delay = 1
	override_allow_spacemove = TRUE


/datum/component/riding/vehicle/adminbus/handle_specials()
	. = ..()
	set_vehicle_offsets(list(TEXT_NORTH = list(-32, -32), TEXT_SOUTH = list(-32, -32), TEXT_EAST = list(-32, -32), TEXT_WEST = list(-32, -32)))
	set_riding_offsets(1, list(TEXT_NORTH = list(-0, -0), TEXT_SOUTH = list(7, -12), TEXT_EAST = list(25, 1), TEXT_WEST = list(-25, 1)))

	set_riding_offsets(2, list(TEXT_NORTH = list(-6, 0), TEXT_SOUTH = list(-6, 0), TEXT_EAST = list(12, 4), TEXT_WEST = list(-13, 4)))
	set_riding_offsets(6, list(TEXT_NORTH = list(-6, 0), TEXT_SOUTH = list(-6, 0), TEXT_EAST = list(12, 4), TEXT_WEST = list(-13, 4)))
	set_riding_offsets(10, list(TEXT_NORTH = list(-6, 0), TEXT_SOUTH = list(-6, 0), TEXT_EAST = list(12, 4), TEXT_WEST = list(-13, 4)))
	set_riding_offsets(14, list(TEXT_NORTH = list(-6, 0), TEXT_SOUTH = list(-6, 0), TEXT_EAST = list(12, 4), TEXT_WEST = list(-13, 4)))

	set_riding_offsets(3, list(TEXT_NORTH = list(6, 0), TEXT_SOUTH = list(6, 0), TEXT_EAST = list(1, 4), TEXT_WEST = list(-1, 4)))
	set_riding_offsets(7, list(TEXT_NORTH = list(6, 0), TEXT_SOUTH = list(6, 0), TEXT_EAST = list(1, 4), TEXT_WEST = list(-1, 4)))
	set_riding_offsets(11, list(TEXT_NORTH = list(6, 0), TEXT_SOUTH = list(6, 0), TEXT_EAST = list(1, 4), TEXT_WEST = list(-1, 4)))
	set_riding_offsets(15, list(TEXT_NORTH = list(6, 0), TEXT_SOUTH = list(6, 0), TEXT_EAST = list(1, 4), TEXT_WEST = list(-1, 4)))

	set_riding_offsets(4, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(-3, 8), TEXT_EAST = list(-11, 4), TEXT_WEST = list(11, 4)))
	set_riding_offsets(8, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(-3, 8), TEXT_EAST = list(-11, 4), TEXT_WEST = list(11, 4)))
	set_riding_offsets(12, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(-3, 8), TEXT_EAST = list(-11, 4), TEXT_WEST = list(11, 4)))
	set_riding_offsets(16, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(-3, 8), TEXT_EAST = list(-11, 4), TEXT_WEST = list(11, 4)))

	set_riding_offsets(5, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(7, -12), TEXT_EAST = list(-22, 4), TEXT_WEST = list(22, 4)))
	set_riding_offsets(9, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(7, -12), TEXT_EAST = list(-22, 4), TEXT_WEST = list(22, 4)))
	set_riding_offsets(13, list(TEXT_NORTH = list(-3, 8), TEXT_SOUTH = list(7, -12), TEXT_EAST = list(-22, 4), TEXT_WEST = list(22, 4)))
