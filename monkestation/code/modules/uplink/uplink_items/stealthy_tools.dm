/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping and skillchips are sold separately. \
			The chameleon technology can be locked and unlocked using a multitool, hiding it from others."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS //clown ops are allowed to buy this kit, since it's basically a costume

/datum/uplink_item/stealthy_weapons/dndknife
	name = "Dungeoneer's Dagger"
	desc = "A very stealthy weapon that allows for powerful sneak attacks, but only from behind and against the unawares. Very random. Use with extreme lack of caution."
	item = /obj/item/toy/toy_dagger/dnd
	cost = 8
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)
