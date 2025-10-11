// C3D (Borgs)

/obj/projectile/bullet/c3d
	generic_name = "bullet"
	damage = 20

// Mech LMG

/obj/projectile/bullet/lmg
	generic_name = "bullet"
	damage = 20

// Mech FNX-99

/obj/projectile/bullet/incendiary/fnx99
	generic_name = "bullet"
	damage = 20

// Turrets

/obj/projectile/bullet/manned_turret
	generic_name = "bullet"
	damage = 20

/obj/projectile/bullet/manned_turret/hmg
	generic_name = "bullet"
	icon_state = "redtrac"

/obj/projectile/bullet/syndicate_turret
	generic_name = "bullet"
	damage = 20

// 7.12x82mm (SAW)

/obj/projectile/bullet/mm712x82
	name = "7.12x82mm bullet"
	damage = 45
	armour_penetration = 10
	armour_ignorance = 10
	wound_bonus = -50
	wound_falloff_tile = 0

/obj/projectile/bullet/mm712x82/ap
	name = "7.12x82mm armor-piercing bullet"
	armour_penetration = 85
	speed = 0.3 //monke edit

/obj/projectile/bullet/mm712x82/hp
	name = "7.12x82mm hollow-point bullet"
	damage = 50
	sharpness = SHARP_EDGED
	weak_against_armour = TRUE
	wound_bonus = -40
	bare_wound_bonus = 30
	wound_falloff_tile = -8

/obj/projectile/bullet/incendiary/mm712x82
	name = "7.12x82mm incendiary bullet"
	damage = 15
	fire_stacks = 3
	speed = 0.6 //monke edit

/obj/projectile/bullet/mm712x82/match
	name = "7.12x82mm match bullet"
	ricochets_max = 2
	ricochet_chance = 60
	ricochet_auto_aim_range = 4
	ricochet_incidence_leeway = 55
	speed = 0.3 //monke edit

/obj/projectile/bullet/mm712x82/bouncy
	name = "7.12x82mm rubber bullet"
	damage = 20
	ricochets_max = 40
	ricochet_chance = 500 // will bounce off anything and everything, whether they like it or not
	ricochet_auto_aim_range = 4
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9
	speed = 0.6 //monke edit


// 12.7x70mm (Malone / tank MG)

/obj/projectile/bullet/mm127x70
	name = "12.7x70mm bullet"
	damage = 15
	armour_penetration = 5
	wound_bonus = -50
	wound_falloff_tile = 0


///6.5 Anti-Xeno, Quarad light machine gun

/obj/projectile/bullet/c65xeno
	name = "6.5mm frangible round"
	damage = 10
	wound_bonus = -10
	bare_wound_bonus = 15
	demolition_mod = 0.5
	var/biotype_damage_multiplier = 2.5
	var/biotype_we_look_for = MOB_HUMANOID

/obj/projectile/bullet/c65xeno/on_hit(atom/target, blocked, pierce_hit)
	var/mob/living/target_mob = target
	if(isliving(target))
		if(!((target_mob.mob_biotypes & biotype_we_look_for) || ishuman(target_mob) || issilicon(target_mob)))
			damage *= biotype_damage_multiplier
	return ..()


/obj/projectile/bullet/c65xeno/evil
	name = "6.5mm FMJ round"
	damage = 10
	wound_bonus = 10
	bare_wound_bonus = 10
	armour_penetration = 30
	demolition_mod = 2

/obj/projectile/bullet/c65xeno/pierce
	name = "6.5mm subcaliber tungsten sabot round"
	icon_state = "gaussphase"
	speed = 0.3
	damage = 6
	armour_penetration = 60
	wound_bonus = 5
	bare_wound_bonus = 0
	demolition_mod = 1.5  ///This WILL break windows
	projectile_piercing = PASSMOB
	biotype_damage_multiplier = 3
	var/object_damage = 30

/obj/projectile/bullet/c65xeno/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
	var/obj/thing_to_break = target
	if(isliving(target) && pierces > 3)
		// If the bullet has already gone through 3 people, stop it on this hit
		projectile_piercing = NONE
	if(isobj(target))
		thing_to_break.take_damage(object_damage, BRUTE, BULLET, FALSE)
	return ..()


/obj/projectile/bullet/c65xeno/pierce/evil
	name = "6.5mm UDS"
	icon_state = "gaussphase"
	speed = 0.3
	damage = 7
	armour_penetration = 60
	wound_bonus = 10
	bare_wound_bonus = 0
	demolition_mod = 3  ///This WILL break windows
	projectile_piercing = PASSMOB
	biotype_damage_multiplier = 6

/obj/projectile/bullet/c65xeno/pierce/evil/on_hit(atom/target, blocked = 0, pierce_hit)
	if(ishuman(target))
		radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)
	return ..()


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
	damage = 10
	bare_wound_bonus = 0
	speed = 0.7 ///half of standard
	/// How many firestacks the bullet should impart upon a target when impacting
	biotype_damage_multiplier = 4
	projectile_piercing = PASSMOB

/obj/projectile/bullet/c65xeno/incendiary/evil/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target) && pierces > 1)
		projectile_piercing = NONE

/obj/projectile/bullet/c65xeno/incendiary/evil/Move()
	. = ..()

	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)


///.22 LR minigun

/obj/projectile/bullet/peashooter
	name = ".22 LR \"peashooter\" round"
	damage = 4
	wound_bonus = -10

/obj/projectile/bullet/peashooter/minigun
	name = ".22 LR round"
	damage = 10
	wound_bonus = -10


///Mining machinegun

/obj/projectile/bullet/a762/kinetic
	name = "kinetic 7.62 projectile"
	damage = 15 //somehow does less damage than the SMG, uh... dont ask why?
	armour_ignorance = 0
	icon_state = "gaussweak"

/obj/projectile/bullet/a762/kinetic/on_hit(atom/target, Firer, blocked = 0, pierce_hit) //its not meant to tear through walls like a plasma cutter, but will still at least bust down a wall if it hits one.
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)
	. = ..()

