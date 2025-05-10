/obj/effect/cult_shortcut
	name = "sigil"
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "sigil"
	anchored = 1
	mouse_opacity = 1
	plane = ABOVE_LIGHTING_PLANE
	var/persist = 0//so mappers can make permanent sigils

/obj/effect/cult_shortcut/New(turf/loc, atom/model)
	..()
	if (!persist)
		spawn (60 SECONDS)
			qdel(src)

/obj/effect/cult_shortcut/attack_hand(mob/living/user)
	if (!IS_CULTIST(user))
		to_chat(user, span_warning("The markings on this wall are peculiar. You don't feel comfortable staring at them.") )
		return
	var/turf/T = get_turf(user)
	if (T == loc)
		return
	var/jump_dir = get_dir(T, loc)
	shadow(loc, T, "sigil_jaunt")
	spawn(1)
		new /obj/effect/afterimage/red(T, user)
		user.forceMove(loc)
		var/steps = 0
		var/turf/last_turf = get_turf(src)
		while(steps < 255)//at most we check for the entire world
			if(isopenturf(get_turf(user)))
				var/turf/open/open_turf = get_turf(user)
				if(!open_turf.check_blocking_content(TRUE))
					break
			steps++
			sleep(1)
			new /obj/effect/afterimage/red(last_turf, user)
			user.forceMove(get_step(last_turf, jump_dir))
			shadow(get_turf(user), get_step(last_turf, jump_dir), "sigil_jaunt")
			last_turf = get_step(last_turf, jump_dir)

/obj/effect/cult_shortcut/narsie_act()
	return

/obj/effect/cult_shortcut/ex_act()
	return

/obj/effect/cult_shortcut/emp_act()
	return

/obj/effect/cult_shortcut/blob_act()
	return

/obj/effect/cult_shortcut/singularity_act()
	return
