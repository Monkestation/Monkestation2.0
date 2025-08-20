// 5.56mm (M-90gl Carbine)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	armour_penetration = 75
	wound_bonus = -40

/obj/projectile/bullet/a556/weak //centcom
	damage = 20

/obj/projectile/bullet/a556/phasic
	name = "5.56mm phasic bullet"
	icon_state = "gaussphase"
	damage = 20
	armour_penetration = 80
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

// 7.62 (Nagant Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 60
	armour_penetration = 0
	armour_ignorance = 10
	wound_bonus = -45
	wound_falloff_tile = 0

/obj/projectile/bullet/a762/surplus
	name = "7.62 surplus bullet"
	weak_against_armour = TRUE //this is specifically more important for fighting carbons than fighting noncarbons. Against a simple mob, this is still a full force bullet
	armour_ignorance = 0

/obj/projectile/bullet/a762/enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80

/obj/projectile/bullet/a223
	name = ".223 bullet"
	damage = 35
	armour_penetration = 40
	wound_bonus = -40

/obj/projectile/bullet/a223/weak //centcom
	damage = 20

/obj/projectile/bullet/a223/phasic
	name = ".223 phasic bullet"
	icon_state = "gaussphase"
	damage = 30
	armour_penetration = 100
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
