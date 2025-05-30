/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus rifle."
	icon_state = "75-full"
	base_icon_state = "75"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/m556
	name = "toploader magazine (5.56mm)"
	icon_state = "5.56m"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = CALIBER_A556
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m556/phasic
	name = "toploader magazine (5.56mm Phasic)"
	ammo_type = /obj/item/ammo_casing/a556/phasic

/obj/item/ammo_box/magazine/rostokov10mm
	name = "Rostokov magazine (10mm)"
	icon_state = "rostokov-1"
	base_icon_state = "rostokov"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = CALIBER_10MM
	max_ammo = 32

/obj/item/ammo_box/magazine/rostokov10mm/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[ammo_count() ? 1 : 0]"
