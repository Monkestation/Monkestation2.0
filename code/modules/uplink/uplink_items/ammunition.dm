/datum/uplink_category/ammo
	name = "Ammunition"
	weight = 7

/datum/uplink_item/ammo
	category = /datum/uplink_category/ammo
	surplus = 40

/datum/uplink_item/ammo/toydarts
	name = "Donksoft Riot Pistol Ammunition Case"
	desc = "A case containing three spare magazines for the Donksoft riot pistol, along with a box of loose riot darts."
	item = /obj/item/storage/toolbox/guncase/traitor/ammunition/donksoft
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/ammo/pistol
	name = "9mm Magazine Case"
	desc = "A case containing three additional 12-round 9mm magazines, compatible with the Makarov pistol, as well as \
		a box of loose 9mm ammunition."
	item = /obj/item/storage/toolbox/guncase/traitor/ammunition
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistolap
	name = "9mm Armour Piercing Magazine"
	desc = "An additional 12-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/ap
	cost = 2
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolhp
	name = "9mm Hollow Point Magazine"
	desc = "An additional 12-round 9mm magazine, compatible with the Makarov pistol. \
			These rounds are more damaging but ineffective against armour."
	progression_minimum = 30 MINUTES
	item = /obj/item/ammo_box/magazine/m9mm/hp
	cost = 3
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/ammo/pistolfire
	name = "9mm Incendiary Magazine"
	desc = "An additional 12-round 9mm magazine, compatible with the Makarov pistol. \
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
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE


/datum/uplink_item/ammo/lighttankammo
	name = "40mm cannon ammo"
	desc = "5 crated shells for use with the Devitt Mk3 light tank."
	item = /obj/item/mecha_ammo/makeshift/lighttankammo
	cost = 4
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/ammo/lighttankmgammo
	name = "12.7x70mm tank mg ammo"
	desc = "60 rounds of 12.7x70mm for use with the Devitt Mk3 light tank."
	item = /obj/item/mecha_ammo/makeshift/lighttankmg
	cost = 2
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/ammo/autoshotgun_buckshot_case
	name = "Syndicate Auto Shotgun Buckshot Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with buckshot shells. A lethal high damage spread of pellets."
	cost = 3
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition

/datum/uplink_item/ammo/autoshotgun_slugs_case
	name = "Syndicate Auto Shotgun Slugs Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with slug shells. A lethal high damage accurate slug."
	cost = 3
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition/slug

/datum/uplink_item/ammo/autoshotgun_rubbershot_case
	name = "Syndicate Auto Shotgun Rubbershot Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with rubber shells. A less-lethal high stamina damage spread of rubber pellets."
	cost = 2
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition/rubbershot

/datum/uplink_item/ammo/autoshotgun_beanbags_case
	name = "Syndicate Auto Shotgun Beanbags Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with beanbag shells. A less-lethal high stamina damage accurate rubber slug."
	cost = 2
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition/beanbag

/datum/uplink_item/ammo/autoshotgun_trickshot_case
	name = "Syndicate Auto Shotgun Trickshot Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with trickshot shells. Capable of bouncing up to five times, they are made for the most talented trickshooters around."
	cost = 3
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition/trickshot

/datum/uplink_item/ammo/autoshotgun_uraniumpen_case
	name = "Syndicate Auto Shotgun Uranium Magazine Case"
	desc = "A case with 2 auto shotgun magazines loaded with uranium penetrator shells. Capable to penetrating walls and objects, but not people. Works best with thermals!"
	cost = 3
	item = /obj/item/storage/toolbox/guncase/traitor/autoshotgun/ammunition/uraniumpen

/datum/uplink_item/ammo/beeshot
	name = "Beeshot Auto Shotgun Magazine"
	desc = "An auto shotgun magazine 12 beeshot shells. Creates very angry bees upon impact. Not as strong as buckshot."
	cost = 3
	item = /obj/item/ammo_box/magazine/autoshotgun/beeshot
