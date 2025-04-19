////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Re-added as a cosmetic structure by admin request
//      BLOOD STONE      //
//                       //
///////////////////////////

/obj/structure/cult/bloodstone
	name = "blood stone"
	icon_state = "bloodstone-enter1"
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	pixel_x = -16 * 1
	max_integrity = 1800
	plane = GAME_PLANE_UPPER
	light_color = "#FF0000"

	var/ready = FALSE
	var/image/image_base
	var/image/image_circle
	var/image/image_stones
	var/image/image_lights
	var/image/image_damage
	var/datum/team/cult/cult
	var/list/pillars = list()

/obj/structure/cult/bloodstone/New()
	..()
	set_light(3)
	cult = locate_team(/datum/team/cult)
	image_base = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "bloodstone-base-old")
	image_base.appearance_flags |= RESET_COLOR
	image_damage = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "bloodstone_damage0")

	image_circle = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "large_circle")
	SET_PLANE_EXPLICIT(image_circle, GAME_PLANE_UPPER, src)
	image_circle.appearance_flags |= RESET_COLOR
	image_circle.pixel_y = -16
	image_stones = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "tear_stones")
	SET_PLANE_EXPLICIT(image_stones, GAME_PLANE, src)
	image_stones.appearance_flags |= RESET_COLOR
	image_stones.pixel_y = -16
	image_lights = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "tear_stones_light")
	SET_PLANE_EXPLICIT(image_lights, GAME_PLANE_UPPER, src)
	image_lights.pixel_y = -16

/obj/structure/cult/bloodstone/proc/overlays_pre()
	overlays += image_base
	overlays += image_circle
	overlays += image_stones
	overlays += image_lights

/obj/structure/cult/bloodstone/admin/overlays_pre()
	overlays += image_base

/obj/structure/cult/bloodstone/proc/overlays_post()
	overlays -= image_base
	image_base.icon_state = "bloodstone-base"
	overlays += image_base

/obj/structure/cult/bloodstone/admin/overlays_post()
	return

/obj/structure/cult/bloodstone/proc/flashy_entrance(var/datum/rune_spell/tearreality/TR)
	for (var/obj/O in loc)
		if (O != src && !istype(O, /obj/item/melee/soulblade))
			O.ex_act(2)
	safe_space()
	overlays_pre()
	explosion_sound(TR)
	TR?.pillar_update(1)

	spawn(10)
		pillars = list()
		icon_state = "bloodstone-enter2"
		explosion_sound(TR)
		TR?.pillar_update(2)
		var/turf/T1 = locate(x-2, y-2, z)
		pillars += new /obj/structure/cult/pillar(T1)
		var/turf/T2 = locate(x+2, y-2, z)
		pillars += new /obj/structure/cult/pillar/alt(T2)
		var/turf/T3 = locate(x-2, y+2, z)
		pillars += new /obj/structure/cult/pillar(T3)
		var/turf/T4 = locate(x+2, y+2, z)
		pillars += new /obj/structure/cult/pillar/alt(T4)
		sleep(10)
		icon_state = "bloodstone-enter3"
		explosion_sound(TR)
		TR?.pillar_update(3)
		for (var/obj/structure/cult/pillar/P in pillars)
			P.update_icon()
		sleep(10)
		ready = TRUE
		overlays_post()
		set_animate()

/obj/structure/cult/bloodstone/proc/explosion_sound(var/datum/rune_spell/tearreality/TR)
	for(var/mob/M in GLOB.player_list)
		if (M.z == z && M.client)
			if (TR || (get_dist(M, src)<= 20))//If there's a tear reality rune, then spires should be appearing all over the station, so no point not having it be loud
				M.playsound_local(src, get_sfx("explosion"), 50, 1)
				shake_camera(M, 4, 1)
			else
				M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
				shake_camera(M, 1, 1)


/obj/structure/cult/bloodstone/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	if (cult && (cult.bloodstone == src))
		cult.bloodstone = null
		spawn()
			cult.stage(BLOODCULT_STAGE_DEFEATED)
	for (var/obj/effect/new_rune/R in src)
		R.active_spell?.abort()
	..()

/*
/obj/structure/cult/bloodstone/cultist_act(var/mob/user)
	. = ..()
	if (!.)
		return
	if(isliving(user))
		var/obj/effect/cult_ritual/dance/dance_center = locate() in loc
		if (dance_center)
			dance_center.add_dancer(user)
		else
			dance_center = new(loc, user)

		if (prob(5))
			user.say("Let me show you the dance of my people!", "C")
		else
			user.say("Tok-lyr rqa'nap g'lt-ulotf!", "C")
*/

/obj/structure/cult/bloodstone/conceal()
	return

/obj/structure/cult/bloodstone/takeDamage(var/damage)
	if (cult && (cult.stage == BLOODCULT_STAGE_NARSIE))
		return
	atom_integrity -= damage
	if (atom_integrity <= 0)
		if (sound_destroyed)
			playsound(src, sound_destroyed, 100, 1)
		qdel(src)
	else
		update_icon()

/obj/structure/cult/bloodstone/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(250)
		if (2)
			takeDamage(50)
		if (3)
			takeDamage(10)

/obj/structure/cult/bloodstone/singularity_pull(S, current_size, repel = FALSE)//we don't want that one to come unanchored
	return

/obj/structure/cult/bloodstone/update_icon()
	. = ..()
	if (!ready)
		return
	icon_state = "bloodstone-0"
	if (cult)
		icon_state = "bloodstone-[clamp(round(9*(world.time - cult.bloodstone_rising_time) / (cult.bloodstone_target_time - cult.bloodstone_rising_time)), 0, 9)]"
	overlays -= image_damage
	if (atom_integrity < max_integrity/3)
		image_damage.icon_state = "bloodstone_damage2"
	else if (atom_integrity < 2*max_integrity/3)
		image_damage.icon_state = "bloodstone_damage1"
	else
		image_damage.icon_state = "bloodstone_damage0"
	overlays += image_damage

/obj/structure/cult/bloodstone/admin/update_icon()
	. = ..()
	icon_state = "bloodstone-9-old"
	overlays -= image_damage
	if (atom_integrity < max_integrity/3)
		image_damage.icon_state = "bloodstone_damage2"
	else if (atom_integrity < 2*max_integrity/3)
		image_damage.icon_state = "bloodstone_damage1"
	else
		image_damage.icon_state = "bloodstone_damage0"
	overlays += image_damage


/obj/structure/cult/bloodstone/proc/set_animate()
	animate(src, color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 10, loop = -1)
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	update_icon()
