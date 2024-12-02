////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawns next to blood stones
//    OBSIDIAN PILLAR    //
//                       //
///////////////////////////

/obj/structure/cult/pillar
	name = "obsidian pillar"
	icon_state = "pillar-enter"
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	pixel_x = -16 * 1
	max_integrity = 200
	plane = GAME_PLANE
	var/alt = 0

/obj/structure/cult/pillar/New()
	..()
	var/turf/T = loc
	if (!T)
		qdel(src)
		return
	for (var/obj/O in loc)
		if (istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			if (!W.fulltile)//reduces breaches ever so slightly
				continue
		if(O == src)
			continue
		O.ex_act(2)
		if(!QDELETED(O) && (istype(O, /obj/structure) || istype(O, /obj/machinery)))
			qdel(O)
	T.ChangeTurf(/turf/open/floor/engine/cult)
	T.turf_animation('monkestation/code/modules/bloody_cult/icons/effects.dmi', "cultfloor", 0, 0, MOB_LAYER-1, anim_plane = GAME_PLANE)

/obj/structure/cult/pillar/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	..()


/obj/structure/cult/pillar/alt
	icon_state = "pillaralt-enter"
	alt = 1

/obj/structure/cult/pillar/update_icon()
	. = ..()
	icon_state = "pillar[alt ? "alt": ""]2"
	set_light(1.5, 2.5, COLOR_FIRE_LIGHT_RED)
	overlays.len = 0
	if (atom_integrity < max_integrity/3)
		icon_state = "pillar[alt ? "alt": ""]0"
	else if (atom_integrity < 2*max_integrity/3)
		icon_state = "pillar[alt ? "alt": ""]1"

/obj/structure/cult/pillar/conceal()
	return

/obj/structure/cult/pillar/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(200)
		if (2)
			takeDamage(100)
		if (3)
			takeDamage(20)
