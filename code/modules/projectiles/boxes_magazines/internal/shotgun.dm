/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = CALIBER_SHOTGUN
	max_ammo = 4
	multiload = FALSE

/obj/item/ammo_box/magazine/internal/shot/tube
	name = "dual feed shotgun internal tube"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/shot/tube/fire
	ammo_type = /obj/projectile/bullet/incendiary/shotgun/no_trail

/obj/item/ammo_box/magazine/internal/shot/lethal
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/com
	name = "combat shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/com/compact
	name = "compact shotgun internal magazine"
	max_ammo = 6 //Monkestation edit

/obj/item/ammo_box/magazine/internal/shot/dual
	name = "double-barrel shotgun internal magazine"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/shot/dual/slugs
	name = "double-barrel shotgun internal magazine (slugs)"
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/internal/shot/dual/breacherslug
	name = "double-barrel shotgun internal magazine (breacher)"
	ammo_type = /obj/item/ammo_casing/shotgun/breacher

/obj/item/ammo_box/magazine/internal/shot/riot
	name = "riot shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/riot/evil
	name = "syndicate renoster shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/shot/bounty
	name = "triple-barrel shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/incapacitate
	max_ammo = 3

/obj/item/ammo_box/magazine/internal/shot/buckshotroulette
	name = "buckshotroulette shotgun internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag/blank
	max_ammo = 10 //WOW THATS A LOT OF BULLETS you might say, however when the gun cant fire at an enemy more than once, i think its ok.

/obj/item/ammo_box/magazine/internal/shot/levergun
	name = "brush gun internal magazine"
	ammo_type = /obj/item/ammo_casing/g45l
	caliber = CALIBER_45L
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot/six
	name = "six-barrel shotgun internal magazine"
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/six

/obj/item/ammo_box/magazine/internal/shot/hundred
	name = "hundred-barrel shotgun internal magazine"
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/hundred

/obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	name = "kinetic double barrel shotgun internal magazine"
	desc = "how did you break my gun like this, please report whatever you did then feel bad!!!"
	ammo_type = /obj/item/ammo_casing/shotgun/kinetic
	caliber = MINER_SHOTGUN
	max_ammo = 2

//You cant just pry these shells out with your fingers, youll have to eject them by breaking open the shotgun
/obj/item/ammo_box/magazine/internal/shot/dual/kinetic/give_round(obj/item/ammo_casing/R)
	if(!R || !(caliber ? (caliber == R.caliber) : (ammo_type == R.type)))
		return FALSE

	else if (stored_ammo.len < max_ammo)
		stored_ammo += R
		R.forceMove(src)
		return TRUE
	return FALSE

