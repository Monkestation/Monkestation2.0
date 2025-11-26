// 10mm

/obj/item/ammo_casing/c10mm
	name = "10mm bullet casing"
	desc = "A 10mm bullet casing."
	caliber = CALIBER_10MM
	projectile_type = /obj/projectile/bullet/c10mm

/obj/item/ammo_casing/c10mm/ap
	name = "10mm armor-piercing bullet casing"
	desc = "A 10mm armor-piercing bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm/ap

/obj/item/ammo_casing/c10mm/hp
	name = "10mm hollow-point bullet casing"
	desc = "A 10mm hollow-point bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm/hp

/obj/item/ammo_casing/c10mm/fire
	name = "10mm incendiary bullet casing"
	desc = "A 10mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c10mm


// 9mm (Makarov, Stechkin APS, PP-95)

/obj/item/ammo_casing/c9mm
	name = "9mm bullet casing"
	desc = "A 9mm bullet casing."
	caliber = CALIBER_9MM
	projectile_type = /obj/projectile/bullet/c9mm

/obj/item/ammo_casing/c9mm/ap
	name = "9mm armor-piercing bullet casing"
	desc = "A 9mm armor-piercing bullet casing."
	projectile_type =/obj/projectile/bullet/c9mm/ap

/obj/item/ammo_casing/c9mm/hp
	name = "9mm hollow-point bullet casing"
	desc = "A 9mm hollow-point bullet casing."
	projectile_type = /obj/projectile/bullet/c9mm/hp

/obj/item/ammo_casing/c9mm/fire
	name = "9mm incendiary bullet casing"
	desc = "A 9mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c9mm


// .50AE (Desert Eagle)

/obj/item/ammo_casing/a50ae
	name = ".50AE bullet casing"
	desc = "A .50AE bullet casing."
	caliber = CALIBER_50
	projectile_type = /obj/projectile/bullet/a50ae


// .35 Sol Short
// Pistol caliber caseless round used almost exclusively by SolFed weapons
//CASELESS VAR IS ADDED SO THAT REVOLVER CHAMBERS KNOW WHAT TO DO WITH IT

/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short lethal bullet casing"
	desc = "A SolFed standard caseless lethal pistol round."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "35sol"
	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol

/obj/item/ammo_casing/c35sol/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c35sol/incapacitator
	name = ".35 Sol Short incapacitator bullet casing"
	desc = "A SolFed standard caseless less-lethal pistol round. Exhausts targets on hit, has a tendency to bounce off walls at shallow angles."
	icon_state = "35sol_disabler"
	projectile_type = /obj/projectile/bullet/c35sol/incapacitator
	harmful = FALSE

/obj/item/ammo_casing/c35sol/ripper
	name = ".35 Sol Short ripper bullet casing"
	desc = "A SolFed standard caseless ripper pistol round. Causes slashing wounds on targets, but is weak to armor."
	icon_state = "35sol_shrapnel"
	projectile_type = /obj/projectile/bullet/c35sol/ripper
	custom_materials = AMMO_MATS_RIPPER
	advanced_print_req = TRUE

/obj/item/ammo_casing/c35sol/pierce
	name = ".35 Sol Short armor piercing bullet casing"
	desc = "A SolFed standard caseless armor piercing pistol round. Penetrates armor, but is rather weak against un-armored targets."
	icon_state = "35sol_shrapnel"
	projectile_type = /obj/projectile/bullet/c35sol/pierce


// .585 Trappiste
// High caliber round used in large pistols and revolvers

/obj/item/ammo_casing/c585trappiste
	name = ".585 Trappiste lethal bullet casing"
	desc = "A white polymer cased high caliber round commonly used in handguns."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585trappiste"
	caliber = CALIBER_585TRAPPISTE
	projectile_type = /obj/projectile/bullet/c585trappiste

/obj/item/ammo_casing/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet casing"
	desc = "A white polymer cased high caliber round with a relatively soft, flat tip. Designed to flatten against targets and usually not penetrate on impact."
	icon_state = "585trappiste_disabler"
	projectile_type = /obj/projectile/bullet/c585trappiste/incapacitator
	harmful = FALSE

/obj/item/ammo_casing/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet casing"
	desc = "A white polymer cased high caliber round with a hollowed tip. Designed to cause as much damage on impact to fleshy targets as possible."
	icon_state = "585trappiste_shrapnel"
	projectile_type = /obj/projectile/bullet/c585trappiste/hollowpoint
	advanced_print_req = TRUE


//.35 Auto, NOT the same as .35 sol short. Chambers in the PACO security pistol
/obj/item/ammo_casing/c35
	name = ".35 Auto bullet casing"
	desc = "A .35 Auto bullet casing."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35_casing"
	caliber = CALIBER_35
	projectile_type = /obj/projectile/bullet/c35

/obj/item/ammo_casing/c35/rubber
	name = ".35 Auto rubber bullet casing"
	desc = "A .35 Auto rubber bullet casing."
	icon_state = "35r_casing"
	projectile_type = /obj/projectile/bullet/c35/rubber

