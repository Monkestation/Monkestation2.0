
/obj/effect/cult_ritual/dance_platform
	anchored = 1
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "blank"
	layer = ABOVE_OBJ_LAYER
	plane = ABOVE_GAME_PLANE
	alpha = 0
	var/moving = FALSE
	var/mob/living/dancer = null
	var/datum/rune_spell/tearreality/source = null
	var/prisoner = FALSE
	var/obj/effect/cult_ritual/dance/dance_manager

	var/static/list/dance_platform_prisoners = list()

/obj/effect/cult_ritual/dance_platform/New(turf/loc, datum/rune_spell/tearreality/runespell)
	..()
	if (!runespell)
		qdel(src)
		return

	var/image/I_circle = image(icon, src, "dance_platform_empty")
	SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
	I_circle.appearance_flags |= RESET_COLOR
	overlays += I_circle
	transform *= 0.3
	source = runespell
	START_PROCESSING(SSobj, src)
	idle_pulse()

	spawn(5)
		animate(src, alpha = 255, transform = matrix(), time = 4)

/obj/effect/cult_ritual/dance_platform/Destroy()
	if (dancer && prisoner)
		dancer.SetStun(-4)
	dancer = null
	source = null
	dance_manager = null
	STOP_PROCESSING(SSobj, src)
	..()

/obj/effect/cult_ritual/dance_platform/process()
	if (dancer && prisoner)
		dancer.SetStun(4)

	if (dancer)
		if (dancer.loc != loc)
			dancer = null
			source.lost_dancer()
			prisoner = FALSE
			overlays.len = 0
			var/image/I_circle = image(icon, src, "dance_platform_empty")
			SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
			I_circle.appearance_flags |= RESET_COLOR
			overlays += I_circle
		else
			source.dance_increment(dancer)
	else
		for (var/mob/living/carbon/C in loc)
			if (valid_dancer(C))
				break
		for(var/mob/living/basic/basic in loc)
			if(valid_dancer(basic))
				break

/obj/effect/cult_ritual/dance_platform/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	valid_dancer(arrived)

/obj/effect/cult_ritual/dance_platform/proc/valid_dancer(atom/movable/mover)
	if (!dancer && !moving)
		if (iscarbon(mover))
			var/mob/living/carbon/C = mover
			if (C.mind && C.stat != DEAD)
				if (IS_CULTIST(C))
					dancer = C
					overlays.len = 0
					var/image/I_circle = image(icon, src, "dance_platform_full")
					SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
					I_circle.appearance_flags |= RESET_COLOR
					var/image/I_markings = image(icon, src, "dance_platform_markings")
					SET_PLANE_EXPLICIT(I_markings, GAME_PLANE, dancer)
					overlays += I_circle
					overlays += I_markings
					source.dancer_check(C)
					return TRUE
				else
					if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult))
						dancer = C
						prisoner = TRUE
						dancer.SetStun(4)
						overlays.len = 0
						var/image/I_circle = image(icon, src, "dance_platform_full")
						SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
						I_circle.appearance_flags |= RESET_COLOR
						var/image/I_markings = image(icon, src, "dance_platform_markings")
						SET_PLANE_EXPLICIT(I_markings, GAME_PLANE, dancer)
						overlays += I_circle
						overlays += I_markings
						var/image/I = image('monkestation/code/modules/bloody_cult/icons/cult.dmi', src, "dance_prisoner")
						SET_PLANE_EXPLICIT(I, GAME_PLANE, dancer)
						overlays += I
						var/mob_ref = "\ref[C]"
						if (!(mob_ref in dance_platform_prisoners))//prevents chat spamming by dragging the prisoner across all the dance platforms
							dance_platform_prisoners += mob_ref
							to_chat(C, span_danger("Dark tentacles emerge from the rune and trap your legs in place. The occult bindings on your arms seem to react to them. You will need to resist out of those or get some outside help if you are to escape this circle.") )
							spawn(20 SECONDS)
								dance_platform_prisoners -= mob_ref
						source.dancer_check(C)
						return TRUE
		else if (isshade(mover) || isconstruct(mover))
			var/mob/living/basic/SA = mover
			if (SA.mind && SA.stat != DEAD)
				dancer = SA
				overlays.len = 0
				var/image/I_circle = image(icon, src, "dance_platform_full")
				SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
				I_circle.appearance_flags |= RESET_COLOR
				var/image/I_markings = image(icon, src, "dance_platform_markings")
				SET_PLANE_EXPLICIT(I_markings, GAME_PLANE, dancer)
				overlays += I_circle
				overlays += I_markings
				source.dancer_check(SA)
				return TRUE
	return FALSE

/obj/effect/cult_ritual/dance_platform/Exit(atom/movable/mover, direction)
	. = ..()
	if (!moving && dancer && mover == dancer)
		overlays.len = 0
		var/image/I_circle = image(icon, src, "dance_platform_empty")
		SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, dancer)
		I_circle.appearance_flags |= RESET_COLOR
		overlays += I_circle
		if (prisoner)
			dancer.SetStun(0)
			prisoner = FALSE
			anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', flick_anim = "dancer_prisoner-stop", plane = ABOVE_LIGHTING_PLANE)
		if (dance_manager)
			dance_manager.dancers -= dancer
		dancer = null
		source.lost_dancer()

/obj/structure/dance_check
	icon = 'icons/effects/effects.dmi'
	icon_state = "blank"
	density = 0
	mouse_opacity = 0
	invisibility = 101
	var/datum/rune_spell/tearreality/source

/obj/structure/dance_check/New(turf/loc, _source)
	..()
	if (_source)
		source = _source
	else
		qdel(src)

/obj/structure/dance_check/Bump(atom/bumped_atom)
	. = ..()
	source.blocker = bumped_atom//So we can tell the rune's activator exactly what is blocking the dance path

