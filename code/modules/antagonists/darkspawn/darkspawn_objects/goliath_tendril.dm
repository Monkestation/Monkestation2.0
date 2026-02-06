/obj/effect/goliath_tentacle/darkspawn
	name = "darkspawn tendril"
	desc = "OOOOOOOOOOOOOOOO spooky"
	grapple_time = 7 SECONDS
	min_damage = 15
	max_damage = 25
	light_power = -1
	light_outer_range = 1
	light_color = COLOR_VELVET

/obj/effect/goliath_tentacle/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)
	if (!isopenturf(loc) || isspaceturf(loc) || isopenspaceturf(loc))
		return INITIALIZE_HINT_QDEL
	for (var/obj/effect/goliath_tentacle/tentacle in loc)
		if (tentacle != src)
			return INITIALIZE_HINT_QDEL
	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(animate_grab)), 0.7 SECONDS, TIMER_STOPPABLE)

/obj/effect/goliath_tentacle/darkspawn/original/Initialize(mapload)
	. = ..()
	var/list/turf/turfs = circle_range_turfs(get_turf(src), 2)
	for(var/i in 1 to 9)
		if(!LAZYLEN(turfs)) //sanity check
			break
		var/turf/extraboi = pick_n_take(turfs)
		new /obj/effect/goliath_tentacle/darkspawn(extraboi)

/obj/effect/goliath_tentacle/darkspawn/grab()
	for (var/mob/living/victim in loc)
		if (victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_TENTACLE_IMMUNE) || IS_TEAM_DARKSPAWN(victim))
			continue
		balloon_alert(victim, "grabbed")
		visible_message(span_danger("[src] grabs hold of [victim]!"))
		victim.adjustBruteLoss(rand(min_damage, max_damage))
		if (victim.apply_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled, grapple_time, src))
			buckle_mob(victim, TRUE)
			SEND_SIGNAL(victim, COMSIG_GOLIATH_TENTACLED_GRABBED)
	if (!has_buckled_mobs())
		retract()
		return
	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(retract)), grapple_time, TIMER_STOPPABLE)
