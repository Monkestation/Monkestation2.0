// .45 (M1911 + C20r + Whispering Jester pistol)

/obj/item/ammo_casing/c45
	name = ".45 bullet casing"
	desc = "A .45 bullet casing."
	caliber = CALIBER_45
	projectile_type = /obj/projectile/bullet/c45

/obj/item/ammo_casing/c45/rubber
	name = ".45 rubber bullet casing"
	desc = "A .45 rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c45/rubber

/obj/item/ammo_casing/c45/ap
	name = ".45 armor-piercing bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/c45/ap

/obj/item/ammo_casing/c45/inc
	name = ".45 incendiary bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c45

/obj/item/ammo_casing/c45/hp
	name = ".45 hollow-point bullet casing"
	desc = "A .45 bullet casing"
	projectile_type = /obj/projectile/bullet/c45/hp
	advanced_print_req = TRUE

/obj/item/ammo_casing/caseless/c45_caseless ///Yes yes caseless parent, it belongs here.
	name = "caseless .45 bullet"
	desc = "A .45 bullet casing. This one is caseless!"
	caliber = CALIBER_45
	projectile_type = /obj/projectile/bullet/c45/caseless

/obj/item/ammo_box/c45/caseless
	name = "ammo box (caseless .45)"
	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "caseless_45box"
	ammo_type = /obj/item/ammo_casing/caseless/c45_caseless
	multiple_sprites = AMMO_BOX_FULL_EMPTY


// 4.6x30mm (Autorifles)

/obj/item/ammo_casing/c46x30mm
	name = "4.6x30mm bullet casing"
	desc = "A 4.6x30mm bullet casing."
	caliber = CALIBER_46X30MM
	projectile_type = /obj/projectile/bullet/c46x30mm

/obj/item/ammo_casing/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet casing"
	desc = "A 4.6x30mm armor-piercing bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/ap

/obj/item/ammo_casing/c46x30mm/inc
	name = "4.6x30mm incendiary bullet casing"
	desc = "A 4.6x30mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c46x30mm

/obj/item/ammo_casing/c46x30mm/rub
	name = "4.6x30mm rubber bullet casing"
	desc = "A 4.6x30mm rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/rub

/obj/item/ammo_casing/c46x30mm/salt
	name = "4.6x30mm saltshot bullet casing"
	desc = "A 4.6x30mm saltshot bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/salt



// .27-54 Cesarzowa
// Low-caliber crew SMG round

/obj/item/ammo_casing/c27_54cesarzowa
	name = ".27-54 Cesarzowa piercing bullet casing"
	desc = "A purple-bodied caseless cartridge home to a small projectile with a fine point."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "27-54cesarzowa"
	caliber = CALIBER_CESARZOWA
	projectile_type = /obj/projectile/bullet/c27_54cesarzowa

/obj/item/ammo_casing/c27_54cesarzowa/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/c27_54cesarzowa/rubber
	name = ".27-54 Cesarzowa rubber bullet casing"
	desc = "A purple-bodied caseless cartridge home to a small projectile with a flat rubber tip."
	icon_state = "27-54cesarzowa_rubber"
	projectile_type = /obj/projectile/bullet/c27_54cesarzowa/rubber

