// 7.12x82mm (SAW)

/obj/item/ammo_casing/mm712x82
	name = "7.12x82mm bullet casing"
	desc = "A 7.12x82mm bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_712X82MM
	projectile_type = /obj/projectile/bullet/mm712x82

/obj/item/ammo_casing/mm712x82/ap
	name = "7.12x82mm armor-piercing bullet casing"
	desc = "A 7.12x82mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/projectile/bullet/mm712x82/ap

/obj/item/ammo_casing/mm712x82/hollow
	name = "7.12x82mm hollow-point bullet casing"
	desc = "A 7.12x82mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/projectile/bullet/mm712x82/hp

/obj/item/ammo_casing/mm712x82/incen
	name = "7.12x82mm incendiary bullet casing"
	desc = "A 7.12x82mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames."
	projectile_type = /obj/projectile/bullet/incendiary/mm712x82

/obj/item/ammo_casing/mm712x82/match
	name = "7.12x82mm match bullet casing"
	desc = "A 7.12x82mm bullet casing manufactured to unfailingly high standards, you could pull off some cool trickshots with this."
	projectile_type = /obj/projectile/bullet/mm712x82/match

/obj/item/ammo_casing/mm712x82/bouncy
	name = "7.12x82mm rubber bullet casing"
	desc = "A 7.12x82mm rubber bullet casing manufactured to unfailingly disastrous standards, you could piss off a lot of people spraying this down a hallway."
	projectile_type = /obj/projectile/bullet/mm712x82/bouncy


///.22LR (Minigun)

/obj/item/ammo_casing/minigun22
	name = ".22LR bullet casing"
	desc = "A .22LR bullet casing"
	icon_state = "s-casing"
	caliber = CALIBER_22LR
	projectile_type = /obj/projectile/bullet/peashooter/minigun


///6.5 Anti-Xeno (Quarad)

/obj/item/ammo_casing/c65xeno
	name = "6.5mm Anti-Xeno frangible bullet casing"
	desc = "An unusual 6.5mm caseless round, designed for minimum property damage, maximum xenomorph shredding"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40sol"
	caliber = CALIBER_C65XENO
	projectile_type = /obj/projectile/bullet/c65xeno

/obj/item/ammo_casing/c65xeno/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c65xeno/evil
	name = "6.5mm FMJ bullet casing"
	desc = "A 6.5mm caseless frangible round with the projectile replaced by a terrestial military round. Much more effective against armor, and at breaking windows."
	caliber = CALIBER_C65XENO
	projectile_type = /obj/projectile/bullet/c65xeno/evil
	can_be_printed = FALSE

/obj/item/ammo_casing/c65xeno/pierce
	name = "6.5mm Subcaliber tungsten sabot round"
	desc = "A 6.5mm caseless round loaded with a subcaliber tungsten penetrator. Designed to punch straight through targets."
	projectile_type = /obj/projectile/bullet/c65xeno/pierce

	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c65xeno/pierce/evil
	name = "6.5mm UDS"
	desc = "A 6.5mm Uranium Discarding Sabot. No, NOT depleted uranium. Prepare to be irradiated."
	projectile_type = /obj/projectile/bullet/c65xeno/pierce/evil

	can_be_printed = FALSE

/obj/item/ammo_casing/c65xeno/incendiary
	name = "6.5mm Subcaliber incendiary round"
	desc = "A 6.5mm caseless round tipped with an extremely flammable compound. Leaves no flaming trail, only igniting targets on impact."
	projectile_type = /obj/projectile/bullet/c65xeno/incendiary

	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c65xeno/incendiary/evil
	name = "6.5mm Inferno round"
	desc = "A 6.5mm caseless round designed to leave a trail of EXTREMLY flammable substance behind it in flight. Do not smoke within 30 meters of these."
	projectile_type = /obj/projectile/bullet/c65xeno/incendiary/evil

	can_be_printed = FALSE


/// Mining LMG

/obj/item/ammo_casing/a762/kinetic
	name = "Kinetic 7.62 bullet casing"
	desc = "A kinetic 7.62 bullet casing for use in the 'Hellhound' LMG."
	icon_state = "762kinetic-casing"
	caliber = CALIBER_A762_KINETIC
	projectile_type = /obj/projectile/bullet/a762/kinetic

