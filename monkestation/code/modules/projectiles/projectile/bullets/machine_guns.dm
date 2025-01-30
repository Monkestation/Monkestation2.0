/obj/projectile/bullet/c65xeno
	name = "6.5mm frangible round"
	damage = 10
	wound_bonus = -10
	bare_wound_bonus = 15
	demolition_mod = 0.5
	var/biotype_damage_multiplier = 3

/obj/projectile/bullet/c65xeno/on_hit(atom/target, blocked, pierce_hit)
	var/mob/living/target_mob = target
	if(!(MOB_HUMANOID in target_mob.mob_biotypes))
		damage *= biotype_damage_multiplier
	return ..()

/obj/projectile/bullet/c65xeno/evil
	name = "6.5mm FMJ round"
	damage = 15
	wound_bonus = 0
	bare_wound_bonus = 0
	armour_penetration = 30
	demolition_mod = 10
	var/biotype_damage_multiplier = 3

/obj/projectile/bullet/c65xeno/pierce
	name = "6.5mm subcaliber tungsten sabot round"

	icon_state = "gaussphase"

	speed = 0.3
	damage = 5
	armour_penetration = 60
	wound_bonus = 5
	bare_wound_bonus = 0

	demolition_mod = 20  ///This WILL break windows
	projectile_piercing = PASSMOB
	biotype_damage_multiplier = 6

/obj/projectile/bullet/c65xeno/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		// If the bullet has already gone through 3 people, stop it on this hit
		if(pierces > 3)
			projectile_piercing = NONE

	return ..()

/obj/projectile/bullet/c65xeno/pierce/evil
	name = "6.5mm UDS"

	icon_state = "gaussphase"

	speed = 0.3
	damage = 5
	armour_penetration = 60
	wound_bonus = 10
	bare_wound_bonus = 0

	demolition_mod = 30  ///This WILL break windows
	projectile_piercing = PASSMOB
	biotype_damage_multiplier = 6
	var/radiation_chance = 50

/obj/projectile/bullet/c65xeno/pierce/evil/on_hit(atom/target, blocked = 0, pierce_hit)
	if(ishuman(target) && prob(radiation_chance))
		radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)
	..()

/obj/projectile/bullet/c65xeno/incendiary
	name = "6.5mm caseless incendiary bullet"
	icon_state = "redtrac"
	damage = 5
	bare_wound_bonus = 0
	speed = 0.7 ///half of standard
	/// How many firestacks the bullet should impart upon a target when impacting
	biotype_damage_multiplier = 4
	var/firestacks_to_give = 1


/obj/projectile/bullet/c65xeno/incendiary/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/gaslighter = target
		gaslighter.adjust_fire_stacks(firestacks_to_give)
		gaslighter.ignite_mob()


/obj/projectile/bullet/c65xeno/incendiary/evil
	name = "6.5mm inferno round"
	icon_state = "redtrac"
	damage = 5
	bare_wound_bonus = 0
	speed = 0.7 ///half of standard
	/// How many firestacks the bullet should impart upon a target when impacting
	biotype_damage_multiplier = 4
	var/firestacks_to_give = 2

/obj/projectile/bullet/c65xeno/incendiary/evil/Move()
	. = ..()

	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)