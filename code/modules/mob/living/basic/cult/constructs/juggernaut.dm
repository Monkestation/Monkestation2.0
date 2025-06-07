/mob/living/basic/construct/juggernaut
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
	icon_state = "juggernaut"
	icon_living = "juggernaut"
	maxHealth = 150
	health = 150
	response_harm_continuous = "harmlessly punches"
	response_harm_simple = "harmlessly punch"
	obj_damage = 90
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "smashes their armored gauntlet into"
	attack_verb_simple = "smash your armored gauntlet into"
	speed = 2.5
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = NONE
	mob_size = MOB_SIZE_LARGE
	force_threshold = 10
	construct_spells = list(
		/datum/action/cooldown/spell/forcewall/cult,
		/datum/action/cooldown/spell/basic_projectile/juggernaut,
		/datum/action/innate/cult/create_rune/wall,
	)
	playstyle_string = span_bold("You are a Juggernaut. Though slow, your shell can withstand heavy punishment, create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.")

	smashes_walls = TRUE
	construct_type = "Juggernaut"

/// Hostile NPC version. Pretty dumb, just attacks whoever is near.
/mob/living/basic/construct/juggernaut/hostile
	ai_controller = /datum/ai_controller/basic_controller/juggernaut
	smashes_walls = FALSE
	melee_attack_cooldown = 2 SECONDS

/mob/living/basic/construct/juggernaut/bullet_act(obj/projectile/bullet)
	if(!istype(bullet, /obj/projectile/energy) && !istype(bullet, /obj/projectile/beam))
		return ..()
	if(!prob(40 - round(bullet.damage / 3))) // reflect chance
		return ..()

	apply_damage(bullet.damage * 0.5, bullet.damage_type)
	visible_message(
		span_danger("The [bullet.name] is reflected by [src]'s armored shell!"),
		span_userdanger("The [bullet.name] is reflected by your armored shell!"),
	)

	bullet.reflect(src)

	return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

// Alternate juggernaut themes
/mob/living/basic/construct/juggernaut/angelic
	theme = THEME_HOLY

/mob/living/basic/construct/juggernaut/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/basic/construct/juggernaut/mystic
	theme = THEME_WIZARD


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
