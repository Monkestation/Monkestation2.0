// 7.62 (Nagant Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_A762
	projectile_type = /obj/projectile/bullet/a762

/obj/item/ammo_casing/a762/surplus
	name = "7.62 surplus bullet casing"
	desc = "A surplus 7.62 bullet casing."
	projectile_type = /obj/projectile/bullet/a762/surplus

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/projectile/bullet/a762/enchanted

// 5.56mm (M-90gl Carbine)

/obj/item/ammo_casing/a556
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	caliber = CALIBER_A556
	projectile_type = /obj/projectile/bullet/a556

/obj/item/ammo_casing/a556/phasic
	name = "5.56mm phasic bullet casing"
	desc = "A 5.56mm phasic bullet casing."
	projectile_type = /obj/projectile/bullet/a556/phasic

/obj/item/ammo_casing/a556/weak
	projectile_type = /obj/projectile/bullet/a556/weak

/obj/item/ammo_casing/a223
	name = ".223 bullet casing"
	desc = "A .223 bullet casing."
	caliber = CALIBER_A223
	projectile_type = /obj/projectile/bullet/a223

/obj/item/ammo_casing/a223/phasic
	name = ".223 phasic bullet casing"
	desc = "A .223 phasic bullet casing."
	projectile_type = /obj/projectile/bullet/a223/phasic

/obj/item/ammo_casing/a223/weak
	projectile_type = /obj/projectile/bullet/a223/weak

// .40 Sol Long, caseless rifle bullets

/obj/item/ammo_casing/c40sol
	name = ".40 Sol Long lethal bullet casing"
	desc = "A SolFed standard caseless lethal rifle round."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40sol"
	caliber = CALIBER_SOL40LONG
	projectile_type = /obj/projectile/bullet/c40sol

/obj/item/ammo_casing/c40sol/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c40sol/fragmentation  ///.40 Sol fragmentation rounds, embeds shrapnel in the target almost every time at close to medium range. Teeeechnically less lethals.
	name = ".40 Sol Long fragmentation bullet casing"
	desc = "A SolFed standard caseless fragmentation rifle round. Shatters upon impact, ejecting sharp shrapnel that can potentially incapacitate targets."
	icon_state = "40sol_disabler"
	projectile_type = /obj/projectile/bullet/c40sol/fragmentation
	advanced_print_req = TRUE
	harmful = FALSE

/obj/item/ammo_casing/c40sol/pierce   ///Bouncy and overpen
	name = ".40 Sol Long match bullet casing"
	desc = "A SolFed standard caseless match grade rifle round. Fires at a higher pressure and thus fires slightly faster projectiles. \
		Rumors say you can do sick ass wall bounce trick shots with these, though the official suggestion is to just shoot your target and \
		not the wall next to them."
	icon_state = "40sol_pierce"
	projectile_type = /obj/projectile/bullet/c40sol/pierce
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c40sol/incendiary
	name = ".40 Sol Long incendiary bullet casing"
	desc = "A SolFed standard caseless incendiary rifle round. Leaves no flaming trail, only igniting targets on impact."
	icon_state = "40sol_flame"
	projectile_type = /obj/projectile/bullet/c40sol/incendiary
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE


///.310 Strilka, quite similar to 7.62 nagant in effect. Caseless

/obj/item/ammo_casing/strilka310
	name = ".310 Strilka bullet casing"
	desc = "A .310 Strilka bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder."
	icon_state = "310-casing"
	caliber = CALIBER_STRILKA310
	projectile_type = /obj/projectile/bullet/strilka310

/obj/item/ammo_casing/strilka310/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/strilka310/surplus
	name = ".310 Strilka surplus bullet casing"
	desc = "A surplus .310 Strilka bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder. Damp red powder at that."
	projectile_type = /obj/projectile/bullet/strilka310/surplus

/obj/item/ammo_casing/strilka310/rubber
	name = ".310 Strilka rubber bullet casing"
	desc = "A .310 rubber bullet casing. Casing is a bit of a fib, there isn't one.\
	<br><br>\
	<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-rubber"
	projectile_type = /obj/projectile/bullet/strilka310/rubber
	harmful = FALSE

/obj/item/ammo_casing/strilka310/ap
	name = ".310 Strilka armor-piercing bullet casing"
	desc = "A .310 armor-piercing bullet casing. Note, does not actually contain a casing.\
	<br><br>\
	<i>ARMOR-PIERCING: Improved armor-piercing capabilities, in return for less outright damage.</i>"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-ap"
	projectile_type = /obj/projectile/bullet/strilka310/ap
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE


///Mining heavy rifle

/obj/item/ammo_casing/minerjdj
	name = ".950 JDJ kinetic casing"
	desc = "A monster of a round for the 'Thor' Rifle, weighing over half a pound and capable of generating over 50,000 Joules of force. You might assume almost nothing could survive a round like this... but..."
	icon_state = ".950"
	caliber = CALIBER_MINER_950
	projectile_type = /obj/projectile/plasma/minerjdj

