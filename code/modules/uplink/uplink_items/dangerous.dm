//All bundles and telecrystals
/datum/uplink_category/dangerous
	name = "Conspicuous Weapons"
	weight = 9

/datum/uplink_item/dangerous
	category = /datum/uplink_category/dangerous

/datum/uplink_item/dangerous/foampistol
	name = "Toy Pistol with Riot Darts"
	desc = "An innocent-looking toy pistol designed to fire foam darts. Comes loaded with riot-grade \
			darts effective at incapacitating a target."
	item = /obj/item/gun/ballistic/automatic/pistol/toy/riot
	cost = 2
	surplus = 50 //monkestation edit: from 10 to 50
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pistol
	name = "Makarov Pistol"
	desc = "A small, easily concealable handgun that uses 9mm auto rounds in 8-round magazines and is compatible \
			with suppressors."
	progression_minimum = 10 MINUTES
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 7
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3
	illegal_tech = FALSE

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive. Activating it produces a loud, distinctive noise."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/energy/sword/saber
	cost = 8
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
			Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
			Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
			deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/powerfist
	cost = 6
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed or the meaty fists of a hulk."
	progression_minimum = 20 MINUTES
	item = /obj/item/clothing/gloves/rapid
	cost = 8

/datum/uplink_item/dangerous/doublesword
	name = "Double-Bladed Energy Sword"
	desc = "The double-bladed energy sword does slightly more damage than a standard energy sword and will deflect \
			energy projectiles it blocks, but requires two hands to wield. It also struggles to protect you from tackles."
	progression_minimum = 30 MINUTES
	item = /obj/item/dualsaber

	cost = 13
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/doublesword/get_discount_value(discount_type)
	switch(discount_type)
		if(TRAITOR_DISCOUNT_BIG)
			return 0.5
		if(TRAITOR_DISCOUNT_AVERAGE)
			return 0.35
		else
			return 0.2

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an \
			organic host as a home base and source of fuel. Holoparasites come in various types and share damage with their host."
	progression_minimum = 30 MINUTES
	item = /obj/item/guardian_creator/tech
	cost = 18
	surplus = 40 //monkestation edit: from 0 to 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/dangerous/revolver
	name = "Syndicate Revolver"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum."
	item = /obj/item/gun/ballistic/revolver/syndicate
	progression_minimum = 30 MINUTES
	cost = 13
	surplus = 50
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/cat
	name = "Feral cat grenade"
	desc = "This grenade is filled with 5 feral cats in stasis. Upon activation, the feral cats are awoken and unleashed unto unlucky bystanders. WARNING: The cats are not trained to discern friend from foe!"
	cost = 5
	item = /obj/item/grenade/spawnergrenade/cat
	surplus = 30

/datum/uplink_item/dangerous/rebarxbowsyndie
	name = "Syndicate Rebar Crossbow"
	desc = "A much more proffessional version of the engineer's bootleg rebar crossbow. 3 shot mag, quicker loading, and better ammo. Owners manual included."
	item = /obj/item/storage/box/syndie_kit/rebarxbowsyndie
	cost = 10

/datum/uplink_item/dangerous/minipea
	name = "5 peashooters strapped together"
	desc = "For use in a trash tank, 5 small machineguns strapped together using syndicate technology. It burns through ammo like no other."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/minipea
	cost = 8
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/devitt
	name = "Devitt Mk3 Light Tank"
	desc = "An ancient tank teleported in for your machinations, comes prepared with a cannon and machinegun. REQUIRES TWO CREWMEMBERS TO OPPERATE EFFECTIVELY."
	item = /obj/vehicle/sealed/mecha/devitt
	cost = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/laser_musket
	name = "Syndicate Laser Musket"
	desc = "An exprimental 'rifle' designed by Aetherofusion. This laser(probably) uses alien technology to fit 4 high energy capacitors \
			into a small rifle which can be stored safely(?) in any backpack. To charge, simply press down on the main control panel. \
			Rumors of this 'siphoning power off your lifeforce' are greatly exaggerated, and Aetherofusion assures safety for up to 2 years of use."
	item = /obj/item/gun/energy/laser/musket/syndicate
	progression_minimum = 30 MINUTES
	cost = 10
	surplus = 40
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/venom_knife
	name = "Poisoned Knife"
	desc = "A knife that is made of two razor sharp blades, it has a secret compartment in the handle to store liquids which are injected when stabbing something. Can hold up to forty units of reagents but comes empty."
	item = /obj/item/knife/venom
	cost = 6 // all in all it's not super stealthy and you have to get some chemicals yourself

/datum/uplink_item/dangerous/renoster
	name = "Renoster Shotgun Case"
	desc = "A twelve gauge shotgun with an eight shell capacity underneath. Comes with two boxes of buckshot."
	item = /obj/item/storage/toolbox/guncase/nova/opfor/renoster
	cost = 10

/datum/uplink_item/dangerous/infanteria
	name = "Carwo-Cawil Battle Rifle Case"
	desc = "A heavy battle rifle, this one seems to be painted tacticool black. Accepts any standard SolFed rifle magazine. Comes with two mags. This will NOT fit in a backpack... "
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/infanteria
	cost = 12

/datum/uplink_item/dangerous/miecz
	name = "'Miecz' Submachinegun Case"
	desc = "A short barrel, further compacted conversion of the 'Lanca' rifle to fire pistol caliber cartridges. Comes with two magazines."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/miecz
	cost = 9

/datum/uplink_item/dangerous/kiboko
	name = "Kiboko Grenade Launcher Case"
	desc = "A unique grenade launcher firing .980 grenades. A laser sight system allows its user to specify a range for the grenades it fires to detonate at. Comes with two C980 Grenade Drums."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/opfor/kiboko
	cost = 14

/datum/uplink_item/dangerous/sidano
	name = "Sindano SMG"
	desc = "A small submachinegun, this one is painted in tacticool black. Accepts any standard Sol pistol magazine."
	progression_minimum = 10 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/pistol/opfor/sindano
	cost = 12

/datum/uplink_item/dangerous/wespe
	name = "Wespe Pistol"
	desc = "The standard issue service pistol of SolFed's various military branches. Comes with attached light."
	progression_minimum = 5 MINUTES
	item = /obj/item/storage/toolbox/guncase/nova/pistol/opfor/wespe
	cost = 6

/datum/uplink_item/dangerous/shotgun_revolver
	name = "\improper Bóbr 12 GA revolver"
	desc = "An outdated sidearm rarely seen in use by some members of the CIN. A revolver type design with a four shell cylinder. That's right, shell, this one shoots twelve guage."
	item = /obj/item/storage/box/syndie_kit/shotgun_revolver
	cost = 8

/datum/uplink_item/dangerous/shit_smg
	name = "Surplus Smg Bundle"
	desc = "A single surplus Plastikov SMG and two extra magazines. A terrible weapon, perfect for henchmen."
	item = /obj/item/storage/box/syndie_kit/shit_smg_bundle
	cost = 4

/datum/uplink_item/dangerous/fss_disk
	name = "FSS-550 disk"
	desc = "A disk that allows an autolathe to print the FSS-550 and associated ammo. \
	The FSS-550 is a modified version of the WT-550 autorifle, it's good for arming a large group, but is weaker compared to 'proper' guns."
	item = /obj/item/disk/design_disk/fss
	progression_minimum = 15 MINUTES
	cost = 5
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS) //Because I don't think they get an autolathe or the resources to use the disk.

/datum/uplink_item/dangerous/efireaxe
	name = "Syndicate Fire Axe"
	desc = "A modernised version of the infamous fire axe, courtesy of the Gorlex Marauders. Capable of breaching almost anything, and cleaving through almost any armour, it is to be handled with care."
	item = /obj/item/fireaxe/energy
	cost = 12
