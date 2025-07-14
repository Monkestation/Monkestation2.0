/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45
	name = "\improper Whispering-Jester .45"
	desc = "A .45 handgun that is designed by Rayne Corp for various people such as jesters, insurgents, and even stealth operatives. The handgun has a built in holosight, suppressor, and laser sight."
	icon = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/item.dmi'
	icon_state = "jester"
	lefthand_file = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/lefthand.dmi'
	righthand_file = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/righthand.dmi'
	inhand_icon_state = "jester"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/whispering_jester_45_magazine
	can_bayonet = FALSE
	can_suppress = FALSE
	can_unsuppress = FALSE
	suppressed = TRUE
	bolt_type = BOLT_TYPE_OPEN
	bolt_wording = "firearm"
	fire_delay = 1
	fire_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_fire.ogg' //Unused, just in case it some how gets un-suppressed.
	suppressed_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_fire.ogg'
	suppressed_volume = 60
	dry_fire_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	rack_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	lock_back_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	bolt_drop_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_clicky.ogg'
	load_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_in.ogg'
	load_empty_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_in.ogg'
	eject_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_out.ogg'
	eject_empty_sound = 'monkestation/sound/weapons/gun/whispering_jester_45/jester_mag_out.ogg'

/obj/item/ammo_box/magazine/whispering_jester_45_magazine
	name = "Whispering-Jester pistol magazine (.45)"
	desc = "A .45 pistol magazine for the Whispering-Jester handgun. Normaly chambered with caseless 45."
	icon = 'monkestation/icons/obj/weapons/guns/whispering_jester_45/item.dmi'
	icon_state = "mag_jester"
	multiple_sprites = AMMO_BOX_PER_BULLET
	ammo_type = /obj/item/ammo_casing/caseless/c45_caseless
	caliber = CALIBER_45
	max_ammo = 18

//Uplink
/datum/uplink_item/dangerous/whispering_jester_45
	name = "Whispering-Jester .45 ACP Handgun"
	desc = "A .45 handgun that is designed by Rayne Corp. The handgun has a built in suppressor. It's magazines contain 18 rounds."
	item = /obj/item/gun/ballistic/automatic/pistol/whispering_jester_45
	cost = 11
	surplus = 50

/datum/uplink_item/ammo/whispering_jester_45_magazine
	name = "Whispering-Jester .45 ACP magazine"
	desc = "A .45 pistol magazine for the Whispering Jester handgun. Holds 18 Rounds. Chambered with caseless 45 ACP."
	item = /obj/item/ammo_box/magazine/whispering_jester_45_magazine
	cost = 3
	surplus = 5

//april fools edition

/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota
	name = "\improper Screaming-Hilux .45"
	desc = "A three-way weapon design project by Rayne Corp, Toyota, and Johnson & Co Architecture, sold under the Toyne Group. Designed as a fully-automatic alternative to the Whispering Jester, it trades all forms of stealth for delivering a lethal punch to hearing first, targets second. Do not trust the onboard suppressor. Wear hearing protection."
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/whispering_jester_45_magazine/big_lmao
	can_bayonet = FALSE
	can_suppress = FALSE
	can_unsuppress = TRUE
	suppressed = FALSE
	bolt_type = BOLT_TYPE_OPEN
	bolt_wording = "firearm"
	fire_delay = 0.1
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 150 //abraxis this is a bad idea
	recoil = 5 //it's a pistol firing full-auto, fuck your wrist lmao
	wield_recoil = 0.75
	spread = 12.5

/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota/Initialize(mapload)
	. = ..()

	give_autofire()


//why did i steal code from the qarad for this fucking thing
/obj/item/gun/ballistic/automatic/pistol/whispering_jester_45/toyota/proc/give_autofire()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/ammo_box/magazine/whispering_jester_45_magazine/big_lmao
	name = "screaming hilux magazine"
	desc = "Why oh god fucking why?"
	max_ammo = 45
