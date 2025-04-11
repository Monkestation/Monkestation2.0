/obj/projectile/boomerang
	name = "boomerang"
	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "boomerang-spin"
	damage = 20
	damage_type = BRUTE
	speed = 0.66
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()


/obj/projectile/boomerang/Bump(atom/A)
	. = ..()
	if (!(A in hit_atoms))
		hit_atoms += A
		if (boomerang)
			boomerang.throw_impact(A, null)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return
			else if (iscarbon(A))
				boomerang.apply_status_effects(A)
				forceMove(A.loc)
				A.Bumped(boomerang)
				qdel(src)
				return
			A.Bumped(boomerang)
	return ..(A)

/obj/projectile/boomerang/Destroy()
	if(boomerang)
		return_to_sender()
	. = ..()

/obj/projectile/boomerang/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!boomerang)
		qdel(src)

/obj/projectile/boomerang/proc/return_to_sender()
	if (!boomerang)
		qdel(src)
		return
	var/turf/T = get_turf(src)
	if (!boomerang.return_check())
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang = null
		return

	var/atom/return_target
	if (firer)
		if (isturf(firer.loc) && (firer.z == z) && (get_dist(firer,src) <= 26))
			return_target = firer

	if (!return_target)
		return_target = starting

	var/obj/effect/tracker/boomerang/Tr = new (T)
	Tr.target = return_target
	Tr.appearance = appearance
	Tr.refresh = speed
	Tr.luminosity = luminosity
	Tr.boomerang = boomerang
	Tr.hit_atoms = hit_atoms.Copy()
	boomerang.forceMove(Tr)
	boomerang = null

/obj/effect/tracker/boomerang
	name = "boomerang"
	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "boomerang-spin"
	mouse_opacity = 1
	density = 1
	pass_flags = PASSTABLE
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()

/obj/effect/tracker/boomerang/Destroy()
	var/turf/T = get_turf(src)
	if (T && boomerang)
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang.originator = null
		boomerang = null
	..()

/obj/effect/tracker/boomerang/on_step()
	if (boomerang && !QDELETED(boomerang))
		boomerang.on_step(src)
	else
		qdel(src)

/obj/effect/tracker/boomerang/Bumped(var/atom/movable/AM)
	make_contact(AM)

/obj/effect/tracker/boomerang/proc/make_contact(var/atom/Obstacle)
	if (boomerang)
		if (!(Obstacle in hit_atoms))
			hit_atoms += Obstacle
			if (Obstacle == boomerang.originator)
				if (on_expire(FALSE))
					qdel(src)
					return TRUE
			boomerang.throw_impact(Obstacle,boomerang.throw_speed,boomerang.originator)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return TRUE
			else if (iscarbon(Obstacle))
				boomerang.apply_status_effects(Obstacle)
				return FALSE
			Obstacle.Bumped(boomerang)
			if (!ismob(Obstacle))
				on_expire(TRUE)
				qdel(src)
				return TRUE
		return FALSE
	else
		qdel(src)
		return FALSE

/obj/effect/tracker/boomerang/on_expire(var/bumped_atom = FALSE)
	if (boomerang && boomerang.originator && Adjacent(boomerang.originator))
		if (boomerang.on_return())
			if (boomerang)
				boomerang.originator = null
			boomerang = null
			return TRUE
	return FALSE

/obj/item/nullrod/cross_boomerang
	name = "battle cross"
	desc = "A holy silver cross that dispels evil and smites unholy creatures."
	throwforce = 20

	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "cross_modern"
	worn_icon = null
	var/thrown = FALSE

	var/flickering = 0
	var/classic = FALSE
	var/mob/living/carbon/originator
	COOLDOWN_DECLARE(last_sound_loop)

	var/sound_throw = 'monkestation/code/modules/bloody_cult/sound/boomerang_cross_start.ogg'
	var/sound_loop = 'monkestation/code/modules/bloody_cult/sound/boomerang_cross_loop.ogg'

/obj/item/nullrod/cross_boomerang/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/nullrod/cross_boomerang/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]-moody", src)

/obj/item/nullrod/cross_boomerang/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart)
	thrown = TRUE
	playsound(loc, sound_throw, 70, 0)
	if (thrower)
		originator = thrower

	SET_PLANE_EXPLICIT(src, ABOVE_LIGHTING_PLANE, thrower)

	var/turf/starting = get_turf(src)
	target = get_turf(target)
	var/obj/projectile/boomerang/rang = new (starting)
	rang.boomerang = src
	rang.firer = thrower
	rang.def_zone = ran_zone(thrower.zone_selected)
	rang.preparePixelProjectile(target, thrower)
	rang.icon_state = "[icon_state]-spin"
	rang.overlays += overlays
	rang.plane = plane
	rang.stun = 1 SECONDS

	forceMove(rang)
	rang.fire()
	rang.process()

/obj/item/nullrod/cross_boomerang/proc/on_step(var/obj/O)
	if (COOLDOWN_FINISHED(src, last_sound_loop))
		COOLDOWN_START(src, last_sound_loop, 1 SECONDS)
		playsound(loc,sound_loop, 35, 0)
	dir = turn(dir, 45)
	var/obj/effect/afterimage/A = new(O.loc, O, fadout = 5, initial_alpha = 100, pla = ABOVE_LIGHTING_PLANE)
	A.layer = O.layer - 1
	A.color = "#1E45FF"
	if (istype(O,/obj/effect/tracker))//only display those particles on the way back
		A.add_particles(PS_CROSS_DUST)
		A.add_particles(PS_CROSS_ORB)

	flickering = (flickering + 1) % 4
	if (flickering > 1)
		O.color = "#53A6FF"
	else
		O.color = null

/obj/item/nullrod/cross_boomerang/proc/return_check()//lets you add conditions for the boomerang to come back
	return TRUE

/obj/item/nullrod/cross_boomerang/proc/apply_status_effects(var/mob/living/carbon/C, var/minimal_effect = 0)
	C.Stun(max(minimal_effect, 1 SECONDS))

/obj/item/nullrod/cross_boomerang/proc/on_return()
	return (istype(originator) && originator.put_in_hands(src))

/obj/item/nullrod/cross_boomerang/pickup(mob/user)
	. = ..()
	thrown = FALSE

/obj/item/nullrod/cross_boomerang/dropped(mob/user, silent)
	. = ..()
	SET_PLANE_EXPLICIT(src, initial(plane), user)

/obj/item/nullrod/cross_boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(hit_atom,/obj/machinery/computer/arcade))
		playsound(hit_atom,'monkestation/code/modules/bloody_cult/sound/boomerang_cross_transform.ogg', 30, 0)
		classic = !classic
		icon_state = "[classic ? "cross_classic" : "cross_modern"]"
		if (istype(loc,/obj))
			var/obj/O = loc
			O.icon_state = "[icon_state]-spin"
		update_appearance()
	. = ..()
