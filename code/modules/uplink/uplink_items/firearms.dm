/datum/uplink_category/firearms
	name = "Firearms"
	weight = 9

/datum/uplink_item/firearms
	category = /datum/uplink_category/firearms

/datum/uplink_item/firearms/foampistol
	name = "Donksoft Riot Pistol Case"
	desc = "A case containing an innocent-looking toy pistol designed to fire foam darts at higher than normal velocity. \
		Comes loaded with riot-grade darts effective at incapacitating a target, two spare magazines and a box of loose \
		riot darts. Perfect for nonlethal takedowns at range, as well as deniability. While not included in the kit, the \
		pistol is compatible with suppressors, which can be purchased separately."
	item = /obj/item/storage/toolbox/guncase/traitor/donksoft
	cost = 2
	surplus = 50
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/firearms/pistol
	name = "Makarov Pistol Case"
	desc = "A weapon case containing an unknown variant of the Makarov pistol, along with two spare magazines and a box of loose 9mm ammunition. \
		Chambered in 9mm. Perfect for frequent skirmishes with security, as well as ensuring you have enough firepower to outlast the competition. \
		While not included in the kit, the pistol is compatible with suppressors, which can be purchased seperately."
	item = /obj/item/storage/toolbox/guncase/traitor
	cost = 7
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/firearms/whispering_jester_45
	name = "Whispering-Jester .45 ACP Handgun"
	desc = "A .45 handgun that is designed by Rayne Corp. The handgun has a built in suppressor. It's magazines contain 18 rounds."
	item = /obj/item/gun/ballistic/automatic/pistol/whispering_jester_45
	cost = 10
	surplus = 50

/datum/uplink_item/firearms/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3
	illegal_tech = FALSE

/datum/uplink_item/firearms/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A short bow mounted across a tiller in miniature. \
	Small enough to fit into a pocket or slip into a bag unnoticed. \
	It will synthesize and fire bolts tipped with a debilitating \
	toxin that will damage and disorient targets, causing them to \
	slur as if inebriated. It can produce an infinite number \
	of bolts, but takes time to automatically recharge after each shot."
	item = /obj/item/gun/energy/recharge/ebow
	cost = 10
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)


/datum/uplink_item/firearms/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an \
			organic host as a home base and source of fuel. Holoparasites come in various types and share damage with their host."
	progression_minimum = 30 MINUTES
	item = /obj/item/guardian_creator/tech
	cost = 15
	surplus = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/firearms/revolver
	name = "Syndicate Revolver"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum."
	item = /obj/item/gun/ballistic/revolver/syndicate
	progression_minimum = 30 MINUTES
	cost = 13
	surplus = 50
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/firearms/rebarxbowsyndie
	name = "Syndicate Rebar Crossbow"
	desc = "A much more proffessional version of the engineer's bootleg rebar crossbow. 3 shot mag, quicker loading, and better ammo. Owners manual included."
	item = /obj/item/storage/box/syndie_kit/rebarxbowsyndie
	cost = 10

/datum/uplink_item/firearms/laser_musket
	name = "Syndicate Laser Musket"
	desc = "An exprimental 'rifle' designed by Aetherofusion. This laser(probably) uses alien technology to fit 4 high energy capacitors \
			into a small rifle which can be stored safely(?) in any backpack. To charge, simply press down on the main control panel. \
			Rumors of this 'siphoning power off your lifeforce' are greatly exaggerated, and Aetherofusion assures safety for up to 2 years of use."
	item = /obj/item/gun/energy/laser/musket/syndicate
	progression_minimum = 30 MINUTES
	cost = 10
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/firearms/renoster
	name = "Renoster Shotgun Case"
	desc = "A twelve gauge shotgun with an eight shell capacity underneath. Comes with two boxes of buckshot."
	item = /obj/item/storage/toolbox/guncase/nova/opfor/renoster
	cost = 10

/datum/uplink_item/firearms/shotgun_revolver
	name = "\improper Bóbr 12 GA revolver"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. A revolver type design with a four shell cylinder. That's right, shell, this one shoots twelve guage."
	item = /obj/item/storage/box/syndie_kit/shotgun_revolver
	cost = 8

/datum/uplink_item/firearms/shit_smg
	name = "Surplus Smg Bundle"
	desc = "A single surplus Plastikov SMG and two extra magazines. A terrible weapon, perfect for henchmen."
	item = /obj/item/storage/box/syndie_kit/shit_smg_bundle
	cost = 4

/datum/uplink_item/firearms/renoster
	name = "Renoster Shotgun Case"
	desc = "A twelve gauge shotgun with an eight shell capacity underneath. Comes with two boxes of buckshot."
	item = /obj/item/storage/toolbox/guncase/nova/opfor/renoster
	cost = 10

/datum/uplink_item/firearms/slipstick
	name = "Syndie Lipstick"
	desc = "Stylish way to kiss to death, isn't it syndiekisser?"
	item = /obj/item/lipstick/syndie
	cost = 12

/datum/uplink_item/firearms/dart_pistol
	name = "Dart Pistol"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any \
			space a small item can."
	item = /obj/item/gun/syringe/syndicate
	cost = 4
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/firearms/fss_disk
	name = "FSS-550 disk"
	desc = "A disk that allows an autolathe to print the FSS-550 and associated ammo. \
	The FSS-550 is a modified version of the WT-550 autorifle, it's good for arming a large group, but is weaker compared to 'proper' guns."
	item = /obj/item/disk/design_disk/fss
	progression_minimum = 15 MINUTES
	cost = 5
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS) //Because I don't think they get an autolathe or the resources to use the disk.

/datum/uplink_item/firearms/minipea
	name = "5 peashooters strapped together"
	desc = "For use in a trash tank, 5 small machineguns strapped together using syndicate technology. It burns through ammo like no other."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/minipea
	cost = 8
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/firearms/devitt
	name = "Devitt Mk3 Light Tank"
	desc = "An ancient tank teleported in for your machinations, comes prepared with a cannon and machinegun. REQUIRES TWO CREWMEMBERS TO OPPERATE EFFECTIVELY."
	item = /obj/vehicle/sealed/mecha/devitt
	cost = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
