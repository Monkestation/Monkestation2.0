// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 30
	wound_bonus = 20 ///monke -10 -> 20
	wound_falloff_tile = -10

/obj/projectile/bullet/c45/rubber
	name = ".45 rubber bullet"
	damage = 15
	stamina = 22.5
	weak_against_armour = TRUE
	ricochets_max = 3
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 1
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/c45/ap
	name = ".45 armor-piercing bullet"
	armour_penetration = 75

/obj/projectile/bullet/incendiary/c45
	name = ".45 incendiary bullet"
	damage = 15
	fire_stacks = 2

/obj/projectile/bullet/c45/hp
	name = ".45 hollow-point bullet"
	damage = 40
	weak_against_armour = TRUE

/obj/projectile/bullet/c45/caseless
	damage = 26 //parent damage var is 30


// 4.6x30mm (Autorifles)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 20
	wound_bonus = -5
	bare_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 15
	armour_penetration = 40
	embedding = null

/obj/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1

/obj/projectile/bullet/c46x30mm/salt
	name = "4.6x30mm saltshot bullet"
	damage = 0
	stamina = 20
	embedding = null
	sharpness = NONE

/obj/projectile/bullet/c46x30mm/rub
	name = "4.6x30mm rubber bullet"
	damage = 4
	stamina = 25
	embedding = null
	sharpness = NONE


// .27-54 Cesarzowa
// Low-caliber crew SMG round

/obj/projectile/bullet/c27_54cesarzowa
	name = ".27-54 Cesarzowa piercing bullet"
	damage = 15
	armour_penetration = 30
	wound_bonus = -10

/obj/projectile/bullet/c27_54cesarzowa/rubber
	name = ".27-54 Cesarzowa rubber bullet"
	stamina = 15
	damage = 6
	weak_against_armour = TRUE
	wound_bonus = -30
	bare_wound_bonus = -10
