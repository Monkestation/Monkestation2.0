/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "\improper Nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = CALIBER_N762
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "\improper Russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_357
	max_ammo = 6
	multiload = FALSE

/obj/item/ammo_box/magazine/internal/rus357/Initialize(mapload)
	stored_ammo += new ammo_type(src)
	. = ..()

/obj/item/ammo_box/magazine/internal/cylinder/c35sol
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/cylinder/c585trappiste
	ammo_type = /obj/item/ammo_casing/c585trappiste
	caliber = CALIBER_585TRAPPISTE
	max_ammo = 5

/obj/item/ammo_box/magazine/internal/cylinder/handcannon
	ammo_type = /obj/item/ammo_casing/a500
	caliber = CALIBER_500
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev45l
	name = ".45 Long revolver cylinder"
	ammo_type = /obj/item/ammo_casing/g45l
	caliber = CALIBER_45L
	max_ammo = 6


// Shotgun revolver's cylinder

/obj/item/ammo_box/magazine/internal/cylinder/rev12ga
	name = "\improper 12 GA revolver cylinder"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = CALIBER_SHOTGUN
	max_ammo = 4
	multiload = FALSE


// Mining revolver cylinder

/obj/item/ammo_box/magazine/internal/cylinder/govmining
	name = "Really Big Revolver Cylinder"
	desc = "Hey BUB howdja do that, dont BREAK the expensive equipment. (REPORT ME)"
	ammo_type = /obj/item/ammo_casing/govmining
	caliber = CALIBER_GOV_MINING
	max_ammo = 6

//Once again the casings wont just fall out, you gotta eject them all
/obj/item/ammo_box/magazine/internal/cylinder/govmining/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	if(!R || !(caliber ? (caliber == R.caliber) : (ammo_type == R.type)))
		return FALSE

	for(var/i in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet) // found a spent ammo
			stored_ammo[i] = R
			R.forceMove(src)
			return TRUE

	return FALSE

