/obj/projectile/bullet/c65xeno
	name = "6.5mm frangible round"
	damage = 10
	wound_bonus = -10
	bare_wound_bonus = 15
	demolition_mod = 0.5
	var/biotype_damage_multiplier = 3

/obj/projectile/bulletbullet/c65xeno/on_hit(atom/target, blocked, pierce_hit)
	var/mob/living/target_mob = target
	if(target_mob.mob_biotypes != istype(target_mob, /mob/living/carbon/human/))
		damage *= biotype_damage_multiplier
	return ..()


/obj/projectile/bullet/c65xeno/pierce
	name = "6.5mm subcaliber tungsten sabot round"

	icon_state = "gaussphase"

	speed = 0.2 ///double standard
	damage = 5
	armour_penetration = 45
	wound_bonus = 5
	bare_wound_bonus = 0

	demolition_mod = 5  ///This WILL break windows
	projectile_piercing = PASSMOB
	biotype_damage_multiplier = 6


/obj/projectile/bullet/c65xeno/incendiary
	name = "6.5mm caseless incendiary bullet"
	icon_state = "redtrac"
	damage = 5
	speed = 0.8 ///half of standard
	/// How many firestacks the bullet should impart upon a target when impacting
	biotype_damage_multiplier = 4
	var/firestacks_to_give = 1


/obj/projectile/bullet/c65xeno/incendiary/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/gaslighter = target
		gaslighter.adjust_fire_stacks(firestacks_to_give)
		gaslighter.ignite_mob()
