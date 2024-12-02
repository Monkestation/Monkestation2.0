/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_outer_range = 5
	light_color = COLOR_FIRE_LIGHT_RED
	max_integrity = 50
	sound_damaged = 'sound/effects/Glasshit.ogg'
	plane = GAME_PLANE_UPPER
	/// Length of the cooldown in between tile corruptions. Doubled if no turfs are found.
	var/corruption_cooldown_duration = 5 SECONDS
	/// The cooldown for corruptions.
	COOLDOWN_DECLARE(corruption_cooldown)

/obj/structure/cult/pylon/attack_hand(var/mob/M)
	attackpylon(M, 5)

/*
/obj/structure/cult/pylon/attack_basic_mob(mob/user, list/modifiers)
	. = ..()
	if(istype(user, /mob/living/basic/construct/artificer))
		if(broken)
			repair(user)
			return
	attackpylon(user, user.melee_damage_upper)
*/

/obj/structure/cult/pylon/attackby(var/obj/item/W, var/mob/user)
	attackpylon(user, W.force)

/obj/structure/cult/pylon/proc/attackpylon(mob/user as mob, var/damage)
	if(!broken)
		if(prob(1+ damage * 5))
			to_chat(user, "You hit the pylon, and its crystal breaks apart!")
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the pylon!", 1, "You hear a tinkle of crystal shards.", 2)
			playsound(src, 'sound/effects/Glassbr3.ogg', 75, 1)
			broken = TRUE
			density = FALSE
			icon_state = "pylon-broken"
			set_light(0)
		else
			to_chat(user, "You hit the pylon!")
			playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
	else
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
		if(prob(damage * 2))
			to_chat(user, "You pulverize what was left of the pylon!")
			qdel(src)
		else
			to_chat(user, "You hit the pylon!")

/obj/structure/cult/pylon/proc/repair(var/mob/user)
	if(broken)
		to_chat(user, "You repair the pylon.")
		broken = FALSE
		density = TRUE
		icon_state = "pylon"
		sound_damaged = 'sound/effects/Glasshit.ogg'
		set_light(5)

/obj/structure/cult/pylon/takeDamage()
	..()
	if(atom_integrity <= 20 && !broken)
		playsound(src, 'sound/effects/Glassbr3.ogg', 75, 1)
		visible_message(span_warning("\The [src] breaks apart!") )
		icon_state = "pylon-broken"
		set_light(0)
		density = FALSE
		broken = TRUE

/obj/structure/cult/pylon/New()
	..()
	flick("[icon_state]-spawn", src)

/obj/structure/cult/pylon/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		brute_heal = 0.4, \
		burn_heal = 0.4, \
		blood_heal = 0.4, \
		simple_heal = 1.2, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HEALS_FROM_CULT_PYLONS, \
		healing_color = COLOR_CULT_RED, \
	)

	START_PROCESSING(SSfastprocess, src)

/obj/structure/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/cult/pylon/process()
	if(!anchored)
		return
	if(!COOLDOWN_FINISHED(src, corruption_cooldown))
		return

	var/list/validturfs = list()
	var/list/cultturfs = list()
	for(var/nearby_turf in circle_view_turfs(src, 5))
		if(istype(nearby_turf, /turf/open/floor/engine/cult))
			cultturfs |= nearby_turf
			continue
		var/static/list/blacklisted_pylon_turfs = typecacheof(list(
			/turf/closed,
			/turf/open/floor/engine/cult,
			/turf/open/space,
			/turf/open/lava,
			/turf/open/chasm,
			/turf/open/misc/asteroid,
		))
		if(is_type_in_typecache(nearby_turf, blacklisted_pylon_turfs))
			continue
		validturfs |= nearby_turf

	if(length(validturfs))
		var/turf/converted_turf = pick(validturfs)
		var/datum/team/cult/cult = locate_team(/datum/team/cult)
		var/datum/mind/mind = pick(cult.members)
		var/datum/antagonist/cult/cultist = mind?.has_antag_datum(/datum/antagonist/cult)
		if(isplatingturf(converted_turf))
			converted_turf.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			converted_turf.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		cultist?.gain_devotion(0, DEVOTION_TIER_0, "convert_floor")
	else if (length(cultturfs))
		var/turf/open/floor/engine/cult/cult_turf = pick(cultturfs)
		new /obj/effect/temp_visual/cult/turf/floor(cult_turf)

	else
		// Are we in space or something? No cult turfs or convertable turfs? Double the cooldown
		COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration * 2)
		return

	COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration)

/obj/structure/cult/pylon/conceal()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/cult/pylon/reveal()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
