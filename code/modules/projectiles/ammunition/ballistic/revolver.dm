// .357 (Syndie Revolver) /obj/item/ammo_box/magazine/internal/cylinder/mech357

/obj/item/ammo_casing/a357
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357

/obj/item/ammo_casing/a357/mecha357 ///Because the mech damage test doesn't like AP
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357/mecha_unit_test
	can_be_printed = FALSE

/obj/item/ammo_casing/a357/match
	name = ".357 match bullet casing"
	desc = "A .357 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/a357/match
	can_be_printed = FALSE

/obj/item/ammo_casing/a357/nutcracker
	name = ".357 Nutcracker bullet casing"
	desc = "A .357 Nutcracker bullet casing."
	projectile_type = /obj/projectile/bullet/a357/nutcracker

/obj/item/ammo_casing/a357/heartpiercer
	name = ".357 Heartpiercer bullet casing"
	desc = "A .357 Heartpiercer bullet casing."
	projectile_type = /obj/projectile/bullet/dart/a357
	can_be_printed = FALSE

/obj/item/ammo_casing/a357/heartpiercer/Initialize(mapload)
	. = ..()
	create_reagents(18, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/cyanide, 2)
	reagents.add_reagent(/datum/reagent/toxin/amanitin, 4)

/obj/item/ammo_casing/a357/heartpiercer/attackby()
	return

/obj/item/ammo_casing/a357/wallstake
	name = ".357 Wallstake bullet casing"
	desc = "A .357 Wallstake bullet casing."
	projectile_type = /obj/projectile/bullet/a357/wallstake
	can_be_printed = FALSE

/obj/item/ammo_casing/a357/wallstake/admeme
	name = ".357 Wallstake bullet casing"
	desc = "An unusually hefty .357 Wallstake bullet casing."
	projectile_type = /obj/projectile/bullet/a357/wallstake/admeme
	can_be_printed = FALSE

// 7.62x38mmR (Nagant Revolver)

/obj/item/ammo_casing/n762
	name = "7.62x38mmR bullet casing"
	desc = "A 7.62x38mmR bullet casing."
	caliber = CALIBER_N762
	projectile_type = /obj/projectile/bullet/n762

// .38 (Detective's Gun)

/obj/item/ammo_casing/c38
	name = ".38 bullet casing"
	desc = "A .38 bullet casing."
	caliber = CALIBER_38
	projectile_type = /obj/projectile/bullet/c38

/obj/item/ammo_casing/c38/trac
	name = ".38 TRAC bullet casing"
	desc = "A .38 \"TRAC\" bullet casing."
	projectile_type = /obj/projectile/bullet/c38/trac

/obj/item/ammo_casing/c38/match
	name = ".38 Match bullet casing"
	desc = "A .38 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/c38/match

/obj/item/ammo_casing/c38/match/bouncy
	name = ".38 Rubber bullet casing"
	desc = "A .38 rubber bullet casing, manufactured to exceedingly bouncy standards."
	projectile_type = /obj/projectile/bullet/c38/match/bouncy

/obj/item/ammo_casing/c38/dumdum
	name = ".38 DumDum bullet casing"
	desc = "A .38 DumDum bullet casing."
	projectile_type = /obj/projectile/bullet/c38/dumdum

/obj/item/ammo_casing/c38/hotshot
	name = ".38 Hot Shot bullet casing"
	desc = "A .38 Hot Shot bullet casing."
	projectile_type = /obj/projectile/bullet/c38/hotshot

/obj/item/ammo_casing/c38/iceblox
	name = ".38 Iceblox bullet casing"
	desc = "A .38 Iceblox bullet casing."
	projectile_type = /obj/projectile/bullet/c38/iceblox


///.45 Long Revolver + Brush Gun ammo

/obj/item/ammo_casing/g45l
	name = ".45 Long bullet casing "
	desc = "A .45 Long bullet casing."
	caliber = CALIBER_45L
	projectile_type = /obj/projectile/bullet/g45l

/obj/item/ammo_casing/g45l/rubber
	name = ".45 Long rubber bullet casing"
	desc = "A .45 Long rubber bullet casing."
	caliber = CALIBER_45L
	projectile_type = /obj/projectile/bullet/g45l/rubber


///.45-70 mining

/obj/item/ammo_casing/govmining
	name = ".45-70 Gov Kinetic Magnum Casing"
	desc = "An absolute beast of a round that will probably only fit in the 'Duster' Revolver."
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = ".45-70"
	caliber = CALIBER_GOV_MINING
	projectile_type = /obj/projectile/bullet/govmining



