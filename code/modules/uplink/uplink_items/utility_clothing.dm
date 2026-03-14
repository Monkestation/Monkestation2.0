// File ordered by progression

/datum/uplink_category/utility_clothing
	name = "Utility Clothing"
	weight = 4

/datum/uplink_item/utility_clothing
	category = /datum/uplink_category/utility_clothing
	surplus = 40

/datum/uplink_item/utility_clothing/infiltrator_bundle
	name = "Infiltrator MODsuit"
	desc = "Developed by the Roseus Galactic Actors Guild in conjunction with the Gorlex Marauders to produce a functional suit for urban operations, \
			this suit proves to be cheaper than your standard issue MODsuit, with none of the movement restrictions of the space suits employed by the company. \
			However, this greater mobility comes at a cost, and the suit is ineffective at protecting the wearer from the vacuum of space. \
			The suit does come pre-equipped with a special psi-emitter stealth module that makes it impossible to recognize the wearer \
			as well as causing significant demoralization amongst Nanotrasen crew."
	item = /obj/item/mod/control/pre_equipped/infiltrator
	cost = 6
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/utility_clothing/noslip
	name = "MODsuit Anti-Slip Module"
	desc = "A MODsuit module preventing the user from slipping on water."
	item = /obj/item/mod/module/noslip
	cost = 2

/datum/uplink_item/utility_clothing/space_suit
	name = "Syndicate Space Suit"
	desc = "This red Syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Nanotrasen crew members are trained to report red space suit \
			sightings, however." //monkestation edit
	item = /obj/item/storage/box/syndie_kit/space
	cost = 2

/datum/uplink_item/utility_clothing/modsuit
	name = "Syndicate MODsuit"
	desc = "The feared MODsuit of a Syndicate agent. Features armoring and a set of inbuilt modules."
	item = /obj/item/mod/control/pre_equipped/traitor
	cost = 8
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS) //you can't buy it in nuke, because the elite modsuit costs the same while being better

/datum/uplink_item/utility_clothing/thermal
	name = "MODsuit Thermal Visor Module"
	desc = "A visor for a MODsuit. Lets you see living beings through walls."
	item = /obj/item/mod/module/visor/thermal
	cost = 3

/datum/uplink_item/utility_clothing/night
	name = "MODsuit Night Visor Module"
	desc = "A visor for a MODsuit. Lets you see clearer in the dark."
	item = /obj/item/mod/module/visor/night
	cost = 2

/datum/uplink_item/utility_clothing/chameleon
	name = "MODsuit Chameleon Module"
	desc = "A MODsuit module that lets the suit disguise itself as other objects."
	item = /obj/item/mod/module/chameleon
	cost = 2

/datum/uplink_item/utility_clothing/plate_compression
	name = "MODsuit Plate Compression Module"
	desc = "A MODsuit module that lets the suit compress into a smaller size. Not compatible with storage modules or the Infiltrator MODsuit."
	item = /obj/item/mod/module/plate_compression
	cost = 2


/datum/uplink_item/utility_clothing/noslip
	name = "MODsuit Anti-Slip Module"
	desc = "A MODsuit module preventing the user from slipping on water."
	item = /obj/item/mod/module/noslip
	cost = 2

/datum/uplink_item/utility_clothing/modsuit/elite_traitor
	name = "Elite Syndicate MODsuit"
	desc = "An upgraded, elite version of the Syndicate MODsuit. It features fireproofing, and also \
			provides the user with superior armor and mobility compared to the standard Syndicate MODsuit."
	item = /obj/item/mod/control/pre_equipped/traitor_elite
	// This one costs more than the nuke op counterpart
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	progression_minimum = 90 MINUTES
	cost = 16
	cant_discount = TRUE

/datum/uplink_item/utility_clothing/modsuit/Wraith
	name = "MODsuit wraith cloaking module"
	desc = "A MODsuit module that grants to the user Optical camouflage and the ability to overload light sources to recharge suit power."
	item = /obj/item/mod/module/stealth/wraith
	cost = 4

/datum/uplink_item/utility_clothing/syndie_armor
	name = "Syndicate Body armor"
	desc = "A highly compact set of body armor with two inner slots for small items. \
	It comes with chameleon features being able to appear as other outwears. This function be locked and unlocked with a multitool"
	item = /obj/item/clothing/suit/chameleon/syndie_armor
	cost = 4
	purchasable_from = ALL

/datum/uplink_item/utility_clothing/holster
	name = "Syndicate Holster"
	desc = "A useful little device that allows for inconspicuous carrying of guns using chameleon technology. It also allows for badass gun-spinning."
	item = /obj/item/storage/belt/holster/chameleon
	cost = 1

/datum/uplink_item/utility_clothing/agent_card
	name = "Agent Identification Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and hold up to 5 wildcards \
			from other identification cards. In addition, they can be forged to display a new assignment, name and trim. \
			This can be done an unlimited amount of times. Some Syndicate areas and devices can only be accessed \
			with these cards."
	item = /obj/item/card/id/advanced/chameleon
	cost = 4

/datum/uplink_item/utility_clothing/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping and skillchips are sold separately. \
			The chameleon technology can be locked and unlocked using a multitool, hiding it from others."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS //clown ops are allowed to buy this kit, since it's basically a costume

/datum/uplink_item/utility_clothing/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar, a floor tile and some contraband inside."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30
	illegal_tech = FALSE

/datum/uplink_item/utility_clothing/chameleonheadsetdeluxe
	name = "Advanced Chameleon Headset"
	desc = "A premium model Chameleon Headset. All the features you love of the original, but now with flashbang \
			protection, voice amplification, memory-foam, HD Sound Quality, and extra-wide spectrum dial. Usually reserved \
			for high-ranking Cybersun officers, a few spares have been reserved for field agents."
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/radio/headset/chameleon/advanced
	cost = 2
