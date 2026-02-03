// 9mm (Makarov and Stechkin APS)

/obj/projectile/bullet/c9mm
	name = "9mm bullet"
	damage = 30
	embedding = list(embed_chance=15, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/projectile/bullet/c9mm/ap
	name = "9mm armor-piercing bullet"
	damage = 27
	armour_penetration = 75
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/c9mm/hp
	name = "9mm hollow-point bullet"
	damage = 40
	weak_against_armour = TRUE

/obj/projectile/bullet/incendiary/c9mm
	name = "9mm incendiary bullet"
	damage = 15
	fire_stacks = 2


// 10mm

/obj/projectile/bullet/c10mm
	name = "10mm bullet"
	damage = 40

/obj/projectile/bullet/c10mm/ap
	name = "10mm armor-piercing bullet"
	damage = 35
	armour_penetration = 60

/obj/projectile/bullet/c10mm/hp
	name = "10mm hollow-point bullet"
	damage = 50
	weak_against_armour = TRUE

/obj/projectile/bullet/incendiary/c10mm
	name = "10mm incendiary bullet"
	damage = 20
	fire_stacks = 3


///.35 sol short, weak crew pistol/smg round

/obj/projectile/bullet/c35sol ///Yes yes, fits in both pistols and revolvers. I'm putting it here
	name = ".35 Sol Short bullet"
	damage = 15
	wound_bonus = -5 // Normal bullets are 20
	bare_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c35sol/incapacitator // .35 Sol's equivalent to a rubber bullet
	name = ".35 Sol Short incapacitator bullet"
	damage = 5
	stamina = 15
	wound_bonus = -40
	bare_wound_bonus = -20
	weak_against_armour = TRUE

	// The stats of the ricochet are a nerfed version of detective revolver rubber ammo
	// This is due to the fact that there's a lot more rounds fired quickly from weapons that use this, over a revolver
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/c35sol/ripper // .35 Sol ripper, similar to the detective revolver's dumdum rounds, causes slash wounds and is weak to armor
	name = ".35 Sol ripper bullet"
	damage = 12
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 20
	bare_wound_bonus = 20
	embedding = list(
		embed_chance = 75,
		fall_chance = 3,
		jostle_chance = 4,
		ignore_throwspeed_threshold = TRUE,
		pain_stam_pct = 0.4,
		pain_mult = 5,
		jostle_pain_mult = 6,
		rip_time = 1 SECONDS,
	)

	embed_falloff_tile = -15

/obj/projectile/bullet/c35sol/pierce // What it says on the tin, AP rounds
	name = ".35 Sol Short armor piercing bullet"
	damage = 13
	bare_wound_bonus = -30
	armour_penetration = 30


///.585 Trappiste, heavy crew pistol/smg round

/obj/projectile/bullet/c585trappiste
	name = ".585 Trappiste bullet"
	damage = 25
	wound_bonus = -10

/obj/projectile/bullet/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet"
	damage = 9
	stamina = 30
	wound_bonus = -20
	weak_against_armour = TRUE
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet"
	damage = 25
	weak_against_armour = TRUE
	wound_bonus = 10
	bare_wound_bonus = 20


///.35 Auto, sec standard carry round

/obj/projectile/bullet/c35
	name = ".35 Auto bullet"
	damage = 20
	wound_bonus = -5

/obj/projectile/bullet/c35/rubber
	name = ".35 Auto rubber bullet"
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "rubber_bullet"
	damage = 4
	stamina = 24
	sharpness = NONE
	embedding = null
