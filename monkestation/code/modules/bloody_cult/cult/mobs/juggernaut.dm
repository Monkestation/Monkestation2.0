/mob/living/basic/construct
	var/construct_type = "Unknown"

/mob/living/basic/construct/juggernaut/perfect
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	icon_state = "juggernaut2"
	icon_living = "juggernaut2"
	icon_dead = "juggernaut2"
	new_glow = TRUE
	construct_spells = list(
		/datum/action/cooldown/spell/forcewall/cult,
		/datum/action/cooldown/spell/basic_projectile/juggernaut,
		/datum/action/innate/cult/create_rune/wall,
		/datum/action/cooldown/spell/juggerdash,
		)
	see_in_dark = 7
	var/dash_dir = null
	var/turf/crashing = null


/mob/living/basic/construct/juggernaut/perfect/Bump(atom/obstacle)
	. = ..()
	if(src.throwing)
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window/))
			var/obj/structure/window/W = obstacle
			W.take_damage(1000)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.take_damage(G.max_integrity * 0.25)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			qdel(T)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/rack_parts(obstacle.loc)
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /turf/closed/wall))
			var/turf/closed/wall/W = obstacle
			if (W.hardness <= 60)
				//playsound(W, 'sound/weapons/heavysmash.ogg', 75, 1)
				W.dismantle_wall(1)
				breakthrough = 1
			else
				src.throwing = 0
				src.crashing = null

		else if(istype(obstacle, /obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/R = obstacle
			qdel(R)

		else if(istype(obstacle, /mob/living))
			var/mob/living/L = obstacle
			if (!(L.status_flags & CANKNOCKDOWN) || istype(L, /mob/living/silicon))
				//can't be knocked down? you'll still take the damage.
				src.throwing = 0
				src.crashing = null
				L.take_overall_damage(5, 0)
				if(L.buckled)
					L.buckled.unbuckle_mob(L)
			else
				L.take_overall_damage(5, 0)
				if(L.buckled)
					L.buckled.unbuckle_mob(L)
				L.Stun(2)
				L.Knockdown(2)
				//playsound(src, 'sound/weapons/heavysmash.ogg', 50, 0, 0)
				breakthrough = 1
		else
			src.throwing = 0
			src.crashing = null

		if(breakthrough)
			if(crashing && !istype(crashing, /turf/open/space))
				spawn(1)
					src.throw_at(crashing, 50, src.throw_speed)
			else
				spawn(1)
					crashing = get_distant_turf(get_turf(src), dash_dir, 2)
					src.throw_at(crashing, 50, src.throw_speed)

	if(istype(obstacle, /obj))
		var/obj/O = obstacle
		if(!O.anchored)
			step(obstacle, src.dir)
		else
			obstacle.Bumped(src)
	else if(istype(obstacle, /mob))
		step(obstacle, src.dir)
	else
		obstacle.Bumped(src)

/datum/action/cooldown/spell/juggerdash
	name = "Jugger-Dash"
	desc = "Charge in a line and knock down anything in your way, even some walls."
	var/range = 4

	cooldown_time = 40 SECONDS
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/juggerdash/cast(atom/cast_on)
	. = ..()
	//playsound(owner, 'sound/effects/juggerdash.ogg', 100, 1)
	var/mob/living/basic/construct/juggernaut/perfect/jugg = owner
	jugg.crashing = null
	var/landing = get_distant_turf(get_turf(owner), jugg.dir, range)
	jugg.throw_at(landing, range , 2)
