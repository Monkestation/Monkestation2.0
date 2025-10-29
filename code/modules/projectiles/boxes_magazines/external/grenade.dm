///Gyrojet

/obj/item/ammo_box/magazine/m75
	name = "specialized magazine (.75)"
	icon_state = "75"
	ammo_type = /obj/item/ammo_casing/caseless/a75
	caliber = CALIBER_75
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	max_ammo = 8

// ignifist rocket
/obj/item/ammo_box/magazine/ignifist
	name = "Ignifist 30 Rocket"
	icon_state = "ignifist"
	ammo_type = /obj/item/ammo_casing/caseless/ignifist
	caliber = CALIBER_60MM
	max_ammo = 1
	multiple_sprites = AMMO_BOX_FULL_EMPTY

// .980 grenade magazines

/obj/item/ammo_box/magazine/c980_grenade
	name = "\improper Kiboko grenade box"
	desc = "A standard size box for .980 grenades, holds four shells."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "granata_standard"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/c980grenade
	caliber = CALIBER_980TYDHOUER
	max_ammo = 4

/obj/item/ammo_box/magazine/c980_grenade/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum
	name = "\improper Kiboko grenade drum"
	desc = "A drum for .980 grenades, holds six shells."
	icon_state = "granata_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 6

/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_fire
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_shrapnel
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_smoke
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_gas
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

