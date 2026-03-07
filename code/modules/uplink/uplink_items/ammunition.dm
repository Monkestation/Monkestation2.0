/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 7

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 20

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol."
	progression_minimum = 10 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm
	cost = 1
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistolap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolhp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 3
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolfire
	name = "9mm Incendiary Magazine"
	desc = "An additional 8-round 9mm magazine, compatible with the Makarov pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/fire
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/whispering_jester_45_magazine
	name = "Whispering-Jester .45 ACP magazine"
	desc = "A .45 pistol magazine for the Whispering Jester handgun. Holds 18 Rounds. Chambered with caseless 45 ACP."
	item = /obj/item/ammo_box/magazine/whispering_jester_45_magazine
	cost = 3
	surplus = 5

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
			For when you really need a lot of things dead."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/a357
	cost = 4
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS) //monkestation edit: adds UPLINK_GANGS
	illegal_tech = FALSE


/datum/uplink_item/ammo/lighttankammo
	name = "40mm cannon ammo"
	desc = "5 crated shells for use with the Devitt Mk3 light tank."
	item = /obj/item/mecha_ammo/makeshift/lighttankammo
	cost = 4

/datum/uplink_item/ammo/lighttankmgammo
	name = "12.7x70mm tank mg ammo"
	desc = "60 rounds of 12.7x70mm for use with the Devitt Mk3 light tank."
	item = /obj/item/mecha_ammo/makeshift/lighttankmg
	cost = 2

/datum/uplink_item/ammo/a40mm
	name = "Box of 40mm HE Grenades"
	desc = "A box of four 40mm HE grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/rubber
	name = "Box of 40mm Rubber Slug Shells"
	desc = "A box of four 40mm rubber slug shells. For use with a grenade launcher."
	cost = 2
	item = /obj/item/storage/fancy/a40mm_box/rubber
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/incendiary
	name = "Box of 40mm Incendiary Grenades"
	desc = "A box of four 40mm incendiary grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/incendiary
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/smoke
	name = "Box of 40mm Smoke Grenades"
	desc = "A box of four 40mm smoke grenades. For use with a grenade launcher."
	cost = 1
	item = /obj/item/storage/fancy/a40mm_box/smoke
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/stun
	name = "Box of 40mm Stun Grenades"
	desc = "A box of four 40mm stun grenades. For use with a grenade launcher."
	cost = 3
	item = /obj/item/storage/fancy/a40mm_box/stun
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/hedp
	name = "Box of 40mm HEDP Grenades"
	desc = "A box of four 40mm HEDP grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/hedp
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/ammo/a40mm/frag
	name = "Box of 40mm Fragmentation Grenades"
	desc = "A box of four 40mm fragmentation grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/frag
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)
