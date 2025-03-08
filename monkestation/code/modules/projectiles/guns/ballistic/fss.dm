/obj/item/gun/ballistic/automatic/wt550/fss //Slightly worse printable WT-550
	name = "\improper FSS-550"
	desc = "A modified printable version of the WT-550 autorifle, in order to be printed by an autolathe, some sacrifices had to be made. Not only does this gun have less stopping power, the magazine doesn't entirely fit, and it takes a bit of force to jam it in or rip it out. Used by Syndicate agents and rebels in more than 50 systems."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "fss550"
	inhand_icon_state = "fss"
	spread = 2
	projectile_damage_multiplier = 0.9
	///How long does it take to add or remove a magazine from this gun.
	var/magazine_time = 4 SECONDS

///Modify proc so it takes time to add or remove the magazine.
/obj/item/gun/ballistic/automatic/wt550/fss/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	if(!istype(AM, accepted_magazine_type))
		balloon_alert(user, "[AM.name] doesn't fit!")
		return FALSE
	if(!do_after(user, magazine_time, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(user.transferItemToLoc(AM, src))
		magazine = AM
		if (display_message)
			balloon_alert(user, "[magazine_wording] loaded")
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			chamber_round(TRUE)
		update_appearance()
		return TRUE
	else
		to_chat(user, span_warning("You cannot seem to get [src] out of your hands!"))
		return FALSE

///Modify proc so it takes time to add or remove the magazine.
/obj/item/gun/ballistic/automatic/wt550/fss/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(!do_after(user, magazine_time, target = src))
		balloon_alert(user, "interrupted!")
		return FALSE
	if(bolt_type == BOLT_TYPE_OPEN)
		chambered = null
	if (magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine.forceMove(drop_location())
	var/obj/item/ammo_box/magazine/old_mag = magazine
	if (tac_load)
		if (insert_magazine(user, tac_load, FALSE))
			balloon_alert(user, "[magazine_wording] swapped")
		else
			to_chat(user, span_warning("You dropped the old [magazine_wording], but the new one doesn't fit. How embarassing."))
			magazine = null
	else
		magazine = null
	user.put_in_hands(old_mag)
	old_mag.update_appearance()
	if (display_message)
		balloon_alert(user, "[magazine_wording] unloaded")
	update_appearance()

/obj/item/gun/ballistic/automatic/wt550/fss/no_mag
	spawnwithmagazine = FALSE

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
	build_path = /obj/item/gun/ballistic/automatic/wt550/fss/no_mag
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
