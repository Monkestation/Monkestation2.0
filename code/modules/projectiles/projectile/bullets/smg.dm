// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 30
	wound_bonus = 20 ///monke -10 -> 20
	wound_falloff_tile = -10
/// Monkestation edit start

/obj/projectile/bullet/c45/rubber
	name = ".45 bullet"
	damage = 15
	stamina = 45
	weak_against_armour = TRUE
	ricochets_max = 3
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 1
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/// Monkestation edit end

/obj/projectile/bullet/c45/ap
	name = ".45 armor-piercing bullet"
	armour_penetration = 50

/obj/projectile/bullet/incendiary/c45
	name = ".45 incendiary bullet"
	damage = 15
	fire_stacks = 2

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
