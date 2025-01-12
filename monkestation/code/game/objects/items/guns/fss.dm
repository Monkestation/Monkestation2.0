/obj/item/gun/ballistic/automatic/wt550/fss //Slightly worse printable WT-550
	name = "\improper FSS-550"
	desc = "A modified version of the WT-550 autorifle, in order to be printed by an autolathe, some sacrifices had to be made. Used by Syndicate agents and rebels in more than 50 galaxies."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "fss550"
	inhand_icon_state = "fss"
	spread = 1
	projectile_damage_multiplier = 0.9

/obj/item/disk/design_disk/fss
	name = "FSS-550 Design Disk"
	desc = "A disk that allows an autolathe to print the FSS-550 and associated ammo."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/fss/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/fss
	blueprints += new /datum/design/mag_autorifle_fss
	blueprints += new /datum/design/mag_autorifle_fss/ap_mag
	blueprints += new /datum/design/mag_autorifle_fss/ic_mag
	blueprints += new /datum/design/mag_autorifle_fss/rub_mag
	blueprints += new /datum/design/mag_autorifle_fss/salt_mag

/datum/design/fss
	name = "FSS-550"
	desc = "FSS-550 autorifle."
	id = "fss"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 1000)
	build_path = /obj/item/gun/ballistic/automatic/wt550/fss
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss //WT-550 ammo but printable in autolathe and you get it from a design disk.
	name = "WT-550 Autorifle Magazine (4.6x30mm) (Lethal)"
	desc = "A 20 round magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_fss"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/ap_mag
	name = "WT-550 Autorifle Armour Piercing Magazine (4.6x30mm AP) (Lethal)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ap_fss"
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/ic_mag
	name = "WT-550 Autorifle Incendiary Magazine (4.6x30mm IC) (Lethal/Highly Destructive)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ic_fss"
	materials = list(/datum/material/iron = 15000, /datum/material/silver = 600, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/rub_mag
	name = "WT-550 Autorifle Rubber Magazine (4.6x30mm R) (Lethal)"
	desc = "A 20 round rubber magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_rub_fss"
	materials = list(/datum/material/iron = 6000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtrub
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/salt_mag
	name = "WT-550 Autorifle Saltshot Magazine (4.6x30mm SALT) (Non-Lethal)"
	desc = "A 20 round saltshot magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_salt_fss"
	materials = list(/datum/material/iron = 6000, /datum/material/plasma = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtsalt
	category = list(RND_CATEGORY_IMPORTED)
