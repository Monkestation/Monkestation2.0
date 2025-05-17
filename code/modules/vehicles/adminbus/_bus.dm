///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////

//RELEASE PASSENGERS

/obj/vehicle/ridden/adminbus/proc/release_passengers(mob/bususer)


	unloading = 1

	for(var/i = passengers.len;i>0;i--)
		var/atom/A = passengers[i]
		if(isliving(A))
			var/mob/living/L = A
			freed(L)
		sleep(3)

	unloading = 0

	return

/obj/vehicle/ridden/adminbus/proc/freed(var/mob/living/L)
	L.forceMove(get_step(src, turn(src.dir, -90)))
	L.anchored = 0
	L.pixel_x = 0
	L.pixel_y = 0
	to_chat(L, span_notice("Thank you for riding with \the [src], have a secure day.") )
	passengers -= L
	update_rearview()

//MOB SPAWNING
/obj/vehicle/ridden/adminbus/proc/spawn_mob(mob/bususer, var/mob_type, var/count)
	var/turflist[] = list()
	for(var/turf/T in orange(src, 1))
		if((T.density == 0) && (T!= src.loc))
			turflist += T

	var/invocnum = min(count, turflist.len)

	for(var/i = 0;i<invocnum;i++)
		var/turf/T = pick(turflist)
		turflist -= T
		switch(mob_type)
			if(1)
				var/mob/living/basic/clown/M = new /mob/living/basic/clown(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#FFC0FF", anim_plane = ABOVE_GAME_PLANE)
			if(2)
				var/mob/living/basic/carp/M = new /mob/living/basic/carp(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#C70AF5", anim_plane = ABOVE_GAME_PLANE)
			if(3)
				if(prob(10))
					var/mob/living/basic/trooper/russian/M = new /mob/living/basic/trooper/russian(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				else
					var/mob/living/basic/bear/M = new /mob/living/basic/bear(T)
					M.faction = "adminbus mob"
					spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#454545", anim_plane = ABOVE_GAME_PLANE)
			if(4)
				var/mob/living/basic/tree/M = new /mob/living/basic/tree(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#232B2C", anim_plane = ABOVE_GAME_PLANE)
			if(5)
				var/mob/living/basic/spider/giant/M = new /mob/living/basic/spider/giant(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#3B2D1C", anim_plane = ABOVE_GAME_PLANE)
			if(6)
				var/mob/living/basic/alien/queen/large/M = new /mob/living/basic/alien/queen/large(T)
				M.faction = "adminbus mob"
				spawned_mobs += M
				T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -16, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', "#525288", anim_plane = ABOVE_GAME_PLANE)
		sleep(5)

/obj/vehicle/ridden/adminbus/proc/remove_mobs(mob/bususer)
	for(var/mob/M in spawned_mobs)
		var/xoffset = -32
		if(istype(M, /mob/living/basic/alien/queen/large))
			xoffset = -16
		var/turf/T = get_turf(M)
		if(T)
			T.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", xoffset, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', anim_plane = ABOVE_GAME_PLANE)
		qdel(M)
	spawned_mobs.len = 0

//SINGULARITY/NARSIE HOOK&CHAIN

/obj/vehicle/ridden/adminbus/proc/capture_singulo(var/obj/singularity/S)
	for(var/atom/A in hookshot)																//first we remove the hookshot and its chain
		qdel(A)
	hookshot.len = 0

	singulo = S
	S.on_capture()
	var/obj/structure/singulo_chain/parentchain = null
	var/obj/structure/singulo_chain/anchor/A = new /obj/structure/singulo_chain/anchor(loc)	//then we spawn the invisible anchor on top of the bus,
	while(get_dist(A, S) > 0)																//it then travels toward the singulo while creating chains on its path,
		A.forceMove(get_step_towards(A, S))													//and parenting them together
		var/obj/structure/singulo_chain/C = new /obj/structure/singulo_chain(A.loc)
		chain += C
		C.dir = get_dir(src, S)
		if(!parentchain)
			chain_base = C
		else
			parentchain.child = C
		parentchain = C
	if(!parentchain)
		chain_base = A
	else
		parentchain.child = A
	chain += A																				//once the anchor has reached the singulo, it parents itself to the last element in the chain
	A.target = singulo																		//and stays on top of the singulo.

/obj/vehicle/ridden/adminbus/proc/throw_hookshot(mob/bususer)


	if(!hook && !singulo)
		return

	if(singulo)
		var/obj/structure/singulo_chain/anchor/A = locate(/obj/structure/singulo_chain/anchor) in chain
		if(A)
			qdel(A)//so we don't drag the singulo back to us along with the rest of the chain.
		singulo.on_release()
		singulo = null
		bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
		while(chain_base)
			var/obj/structure/singulo_chain/C = chain_base
			C.move_child(get_turf(src))
			chain_base = C.child
			qdel(C)
			sleep(2)

		for(var/obj/structure/singulo_chain/N in chain)//Just in case some bits of the chain were detached from the bus for whatever reason
			qdel(N)
		chain.len = 0

		if(!singulo)
			hook = 1
			bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
	else if(hook)
		hook = 0
		bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)
		var/obj/structure/hookshot/claw/C = new/obj/structure/hookshot/claw(get_step(src, src.dir))	//First we spawn the claw
		hookshot += C
		C.abus = src

		var/obj/singularity/S = C.hook_throw(src.dir)							//The claw moves forward, spawning hookshot-chains on its path
		if(S)
			capture_singulo(S)
			bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/hoverable/adminbus_hook)														//If the claw hits a singulo, we remove the hookshot-chains and replace them with singulo-chains
		else
			for(var/obj/structure/hookshot/A in hookshot)								//If it doesn't hit anything, all the elements of the chain come back toward the bus,
				spawn()//so they all return at once										//deleting themselves when they reach it.
					A.hook_back()

/////////////////

/obj/vehicle/ridden/adminbus/proc/mass_rejuvenate(mob/bususer)
	for(var/mob/living/M in orange(src, 3))
		M.revive(1)
		M.set_suicide(0)
		to_chat(M, span_notice("THE ADMINBUS IS LOVE. THE ADMINBUS IS LIFE.") )
		sleep(2)
	update_rearview()

/obj/vehicle/ridden/adminbus/proc/toggle_lights(mob/bususer, var/lightpower = 0)


	if(lightpower == roadlights)
		return
	var/image/roadlights_image = image(icon, "roadlights")
	roadlights_image.plane = ABOVE_LIGHTING_PLANE
	roadlights = lightpower
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_low)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_mid)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_roadlights_high)
	switch(lightpower)
		if(0)
			lightsource.set_light(0)
			if(roadlights == 1 || roadlights == 2)
				overlays["roadlights"] = null
		if(1)
			lightsource.set_light(2)
			if(roadlights == 0)
				overlays["roadlights"] = roadlights_image
		if(2)
			lightsource.set_light(3)
			if(roadlights == 0)
				overlays["roadlights"] = roadlights_image

	update_lightsource()

/obj/vehicle/ridden/adminbus/proc/toggle_bumpers(mob/bususer, var/bumperpower = 1)


	if(bumperpower == bumpers)
		return

	bumpers = bumperpower
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_low)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_mid)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_bumpers_high)


/obj/vehicle/ridden/adminbus/proc/toggle_door(mob/bususer, var/doorstate = 0)


	if(doorstate == door_mode)
		return

	door_mode = doorstate
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_door_closed)
	bususer.UpdateUIElementIcon(/obj/abstract/mind_ui_element/adminbus_door_open)
	if (door_mode)
		overlays += image(icon, "opendoor")
	else
		overlays -= image(icon, "opendoor")

/obj/vehicle/ridden/adminbus/proc/loadsa_goodies(mob/bususer, var/goodie_type)
	switch(goodie_type)
		if(1)
			visible_message(span_notice("All Access for Everyone!") )
		if(2)
			visible_message(span_notice("Loads of Money!") )

	var/joy_sound = list('monkestation/code/modules/bloody_cult/sound/SC4Mayor1.ogg', 'monkestation/code/modules/bloody_cult/sound/SC4Mayor2.ogg', 'monkestation/code/modules/bloody_cult/sound/SC4Mayor3.ogg')
	playsound(src, pick(joy_sound), 50, 0, 0)
	var/throwzone = list()
	for(var/i = 1;i<= 5;i++)
		throwzone = list()
		for(var/turf/T in range(src, 5))
			throwzone += T
		switch(goodie_type)
			if(1)
				var/obj/item/card/id/advanced/gold/captains_spare/S = new/obj/item/card/id/advanced/gold/captains_spare(src.loc)
				S.throw_at(pick(throwzone), rand(2, 5), 5)
			if(2)
				var/obj/item/fuckingmoney = null
				fuckingmoney = pick(
				50;/obj/item/coin/gold,
				50;/obj/item/coin/silver,
				50;/obj/item/coin/diamond,
				40;/obj/item/coin/iron,
				50;/obj/item/coin/plasma,
				40;/obj/item/coin/uranium,
				30;/obj/item/coin/adamantine,
				30;/obj/item/coin/mythril,
				200;/obj/item/stack/spacecash,
				200;/obj/item/stack/spacecash/c10,
				200;/obj/item/stack/spacecash/c100,
				300;/obj/item/stack/spacecash/c1000
				)
				var/obj/item/C = new fuckingmoney(src.loc)
				C.throw_at(pick(throwzone), rand(2, 5), 5)

/obj/vehicle/ridden/adminbus/proc/give_bombs(mob/bususer)

	var/distributed = 0

	if(length(occupants))
		var/mob/living/M = occupants[1]
		if(iscarbon(M))
			for(var/i = 1 to M.held_items.len)
				if(M.held_items[i] == null)
					var/obj/item/grenade/B = new /obj/item/grenade(M)
					spawnedbombs += B
					if(!M.put_in_hands(B))
						qdel(B)

					to_chat(M, span_warning("Lit and throw!") )
					break

	for(var/mob/living/carbon/C in passengers)
		for(var/i = 1 to C.held_items.len)
			if(C.held_items[i] == null)
				var/obj/item/grenade/B = new /obj/item/grenade(C)
				spawnedbombs += B
				if(!C.put_in_hands(B))
					qdel(B)

				to_chat(C, span_warning("Our benefactors have provided you with a bomb. Lit and throw!") )
				distributed++
				break

	update_rearview()
	to_chat(bususer, "[distributed] bombs distributed to passengers.</span>")

/obj/vehicle/ridden/adminbus/proc/delete_bombs(mob/bususer)

	if(spawnedbombs.len == 0)
		to_chat(bususer, "No bombs to delete.</span>")
		return

	var/distributed = 0

	for(var/i = spawnedbombs.len;i>0;i--)
		var/obj/item/grenade/B = spawnedbombs[i]
		if(B)
			if(istype(B.loc, /mob/living/carbon))
				var/mob/living/carbon/C = B.loc
				qdel(B)
				C.regenerate_icons()
			else
				qdel(B)
			distributed++
		spawnedbombs -= spawnedbombs[i]

	update_rearview()
	to_chat(bususer, "Deleted all [distributed] bombs.</span>")


/obj/vehicle/ridden/adminbus/proc/give_lasers(mob/bususer)

	var/distributed = 0

	if(length(occupants))
		var/mob/living/M = occupants[1]
		if(iscarbon(M))
			var/obj/item/gun/energy/laser/hellgun/L = new /obj/item/gun/energy/laser/hellgun(M)

			if(M.put_in_hands(L))
				spawnedlasers += L
				to_chat(M, span_warning("Spray and /pray!") )
			else
				qdel(L)

	for(var/mob/living/carbon/C in passengers)
		var/obj/item/gun/energy/laser/hellgun/L = new /obj/item/gun/energy/laser/hellgun(C)

		if(C.put_in_hands(L))
			spawnedlasers += L
			to_chat(C, span_warning("Our benefactors have provided you with an infinite laser gun. Spray and /pray!") )
			distributed++
		else
			qdel(L)

	update_rearview()
	to_chat(bususer, "[distributed] infinite laser guns distributed to passengers.</span>")

/obj/vehicle/ridden/adminbus/proc/delete_lasers(mob/bususer)

	if(spawnedlasers.len == 0)
		to_chat(bususer, "No laser guns to delete.</span>")
		return

	var/distributed = 0

	for(var/i = spawnedlasers.len;i>0;i--)
		var/obj/item/gun/energy/laser/hellgun/L = spawnedlasers[i]
		if(L)
			if(istype(L.loc, /mob/living/carbon))
				var/mob/living/carbon/C = L.loc
				qdel(L)
				C.regenerate_icons()
			else
				qdel(L)
			distributed++
		spawnedlasers -= spawnedlasers[i]

	update_rearview()
	to_chat(bususer, "Deleted all [distributed] laser guns.</span>")

/obj/vehicle/ridden/adminbus/proc/Mass_Repair(mob/bususer, var/turf/centerloc = null, var/repair_range = 3)//the proc can be called by others, doing (null, <center of the area you want to repair>, <radius of the area you want to repair>)

	visible_message(span_notice("WE BUILD!") )

	if(!centerloc)
		centerloc = src.loc

	for(var/obj/machinery/M in range(centerloc, repair_range))
		if(istype(M, /obj/machinery/door/window))//for some reason it makes the windoors' sprite disapear (until you bump into it)
			continue
		if(istype(M, /obj/machinery/light))
			var/obj/machinery/light/L = M
			L.fix()
			continue
		M.update_icon()


	for(var/turf/T in range(centerloc, repair_range))
		if(istype(T, /turf/open/space))
			if(isspaceturf(T.loc))
				continue
			var/obj/item/stack/tile/iron/P = new /obj/item/stack/tile/iron
			P.place_tile(T)
		else if(istype(T, /turf/open/floor))
			var/turf/open/floor/F = T
			if(F.broken || F.burnt)
				if(istype(F, /turf/open/floor/plating))
					F.icon_state = "plating"
					F.burnt = 0
					F.broken = 0
				else
					F.make_plating()

	for(var/obj/structure/girder/G in range(centerloc, repair_range))
		var/turf/T = get_turf(G)
		if(istype(G, /obj/structure/girder/reinforced))
			T.ChangeTurf(/turf/closed/wall/r_wall)
		else
			T.ChangeTurf(/turf/closed/wall)
		qdel(G)

	for(var/obj/item/shard/S in range(centerloc, repair_range))
		if(istype(S, /obj/item/shard/plasma))
			new/obj/item/stack/sheet/plasmaglass(S.loc)
		else
			new/obj/item/stack/sheet/glass(S.loc)
		qdel(S)

/obj/vehicle/ridden/adminbus/proc/Teleportation(mob/bususer)


	if(warp.icon_state == "warp_activated")
		return

	warp.icon_state = "warp_activated"

	var/A
	A = input(bususer, "Area to jump to", "Teleportation Warp", A) as null|anything in get_sorted_areas()
	var/area/thearea = A
	if(!thearea)
		warp.icon_state = ""
		return

	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		L+= T

	if(!L || !L.len)
		to_chat(bususer, "No area available.")
		warp.icon_state = ""
		return

	var/turf/T1 = get_turf(src)
	var/turf/T2 = pick(L)
	warp.icon_state = ""
	forceMove(T2)
	T1.turf_animation('monkestation/code/modules/bloody_cult/icons/160x160.dmi', "busteleport", -32*2, -32, MOB_LAYER+1, 'monkestation/code/modules/bloody_cult/sound/busteleport.ogg', anim_plane = ABOVE_GAME_PLANE)
	T2.turf_animation('monkestation/code/modules/bloody_cult/icons/160x160.dmi', "busteleport", -32*2, -32, MOB_LAYER+1, 'monkestation/code/modules/bloody_cult/sound/busteleport.ogg', anim_plane = ABOVE_GAME_PLANE)




/obj/item/packobelongings
	name = "Unknown's belongings"
	desc = "Full of stuff."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "belongings"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = parent_type::item_flags | ABSTRACT

/obj/item/packobelongings/New()
	..()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

/obj/item/packobelongings/attack_self(mob/user as mob)
	var/turf/T = get_turf(user)
	for(var/obj/O in src)
		O.forceMove(T)
	qdel(src)

/obj/item/packobelongings/green
	icon_state = "belongings-green"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/item/packobelongings/red
	icon_state = "belongings-red"
	desc = "Items belonging to one of the Thunderdome contestants."

/obj/vehicle/ridden/adminbus/proc/Send_Home(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, span_warning("There are no passengers to send.") )
		return

	if(alert(bususer, "Send all mobs among the passengers back where they first appeared? (Risky: This sends them back where their \"object\" was created. If they were cloned they will teleport back at genetics, If they had their species changed they'll spawn back where it happenned, etc...)", "Adminbus", "Yes", "No") != "Yes")
		return

	var/turf/T1 = get_turf(src)
	if(T1)
		T1.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', anim_plane = ABOVE_GAME_PLANE)

	for(var/mob/M in passengers)
		unbuckle_mob(M, TRUE)
		freed(M)
		M.send_back()

		var/turf/T2 = get_turf(M)
		if(T2)
			T2.turf_animation('monkestation/code/modules/bloody_cult/icons/96x96.dmi', "beamin", -32, 0, MOB_LAYER+1, 'sound/weapons/emitter2.ogg', anim_plane = ABOVE_GAME_PLANE)
/*
/obj/vehicle/ridden/adminbus/proc/Make_Antag(mob/bususer)


	if(passengers.len == 0)
		to_chat(bususer, span_warning("There are no passengers to make antag.") )
		return

	var/list/delays = list("CANCEL", "No Delay", "10 seconds", "30 seconds", "1 minute", "5 minutes", "15 minutes")
	var/delay = input("How much delay before the transformation occurs?", "Antag Madness") in delays

	switch(delay)
		if("CANCEL")
			return
		if("No Delay")
			for(var/mob/M in passengers)
				spawn()
					to_chat(M, span_danger("YOU JUST REMEMBERED SOMETHING IMPORTANT!") )
					sleep(20)
					antag_madness_adminbus(M)
		if("10 seconds")
			antagify_passengers(100)
		if("30 seconds")
			antagify_passengers(300)
		if("1 minute")
			antagify_passengers(600)
		if("5 minutes")
			antagify_passengers(3000)
		if("15 minutes")
			antagify_passengers(9000)


/obj/vehicle/ridden/adminbus/proc/antagify_passengers(var/delay)
	for(var/mob/M in passengers)
		spawn()
			Delay_Antag(M, delay)

/obj/vehicle/ridden/adminbus/proc/Delay_Antag(var/mob/M, var/delay = 100)
	if(!M.mind)
		return
	if(!ishuman(M) && !ismonkey(M))
		return

	to_chat(M, span_rose("You feel like you forgot something important!") )

	sleep(delay/2)

	to_chat(M, span_rose("You're starting to remember...") )

	sleep(delay/2)

	to_chat(M, span_danger("OH THAT'S RIGHT!") )

	sleep(20)

	antag_madness_adminbus(M)
*/
/obj/vehicle/ridden/adminbus/proc/Adminbus_Deletion(mob/bususer)//make sure to always use this proc when deleting an adminbus
	if(bususer)
		if(alert(bususer, "This will free all passengers, remove any spawned mobs/laserguns/bombs, [singulo ? "free the captured singularity" : ""], and remove all the entities associated with the bus(chains, roadlights, jukebox, ...) Are you sure?", "Adminbus Deletion", "Yes", "No") != "Yes")
			return

	qdel(src)//RIP ADMINBUS

/mob
	//Keeps track of where the mob was spawned. Mostly for teleportation purposes. and no, using initial() doesn't work.
	var/origin_x = 0
	var/origin_y = 0
	var/origin_z = 0

/mob/proc/store_position()
	//updates the players' origin_ vars so they retain their location when the round starts.
	origin_x = x
	origin_y = y
	origin_z = z

/mob/proc/send_back()
	x = origin_x
	y = origin_y
	z = origin_z
