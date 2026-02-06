/datum/orderable_item/waste_weapon //ALL WASTE PIN WEAPONS GO IN THIS CATEGORY, AS FREE MINERS CANT USE THEM, AND CURRENTLY GOLEMS CANNOT EITHER (BECAUSE WASTE PIN GUNS USUALLY HAVE NO MOD CAPACITY FOR TRIGGER GUARDS)
	category_index = CATEGORY_WASTE_WEAPON


/datum/orderable_item/waste_weapon/railgun //has a waste pin, and cant be modified with a trigger guard, so does not go in the PKA category
	item_path = /obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	cost_per_order = 1250

/datum/orderable_item/waste_weapon/pksmg
	item_path = /obj/item/storage/box/pksmg
	desc = "A case containing a PKSMG and three magazines to get you started."
	cost_per_order = 1750

/datum/orderable_item/waste_weapon/pksmg/sparemags
	item_path = /obj/item/storage/box/kinetic
	desc = "A box containing seven magazines for the PKSMG that also fits in explorer webbing."
	cost_per_order = 500

/datum/orderable_item/waste_weapon/pkshotgun
	item_path = /obj/item/storage/box/kinetic/shotgun/bigcase
	desc = "A case containing a PKShotgun along with four lethal shells and eight mining shells."
	cost_per_order = 2500

/datum/orderable_item/waste_weapon/pkshotgun/spareshells
	item_path = /obj/item/storage/box/kinetic/shotgun
	desc = "A box containing ten Magnum Kinetic Buckshot shells for the PKShotgun. Fits in explorer webbing."
	cost_per_order = 500

/datum/orderable_item/waste_weapon/pkshotgun/spareshells/rockbreaker
	item_path = /obj/item/storage/box/kinetic/shotgun/rockbreaker
	desc = "A box containing twenty Rockbreaker shells for the PKShotgun, designed to destroy masses of rock but do very little damage to fauna. Fits in explorer webbing."
	cost_per_order = 300

/datum/orderable_item/waste_weapon/pkshotgun/spareshells/slugs
	item_path = /obj/item/storage/box/kinetic/shotgun/sniperslug
	desc = "A box containing ten 50 BMG Slug shells for the PKShotgun. Still penetrates rock walls but not fauna. Trades potential damage for range and reliability. Fits in explorer webbing."
	cost_per_order = 650

/datum/orderable_item/waste_weapon/miningrevolver
	item_path = /obj/item/storage/box/kinetic/govmining/bigcase
	cost_per_order = 1750

/datum/orderable_item/waste_weapon/miningrevolver/spareshells
	item_path = /obj/item/storage/box/kinetic/govmining
	cost_per_order = 650

/datum/orderable_item/waste_weapon/miningrevolver/sparemags
	item_path = /obj/item/storage/box/kinetic/govmining/smallcase
	cost_per_order = 1500

/datum/orderable_item/waste_weapon/fenrir
	item_path = /obj/item/storage/box/kinetic/autoshotgun/bigcase
	cost_per_order = 2000

/datum/orderable_item/waste_weapon/fenrir/spareshells
	item_path = /obj/item/storage/box/kinetic/autoshotgun
	cost_per_order = 650

/datum/orderable_item/waste_weapon/fenrir/sparemags
	item_path = /obj/item/storage/box/kinetic/autoshotgun/smallcase
	cost_per_order = 1500

/datum/orderable_item/waste_weapon/slab
	item_path = /obj/item/storage/box/kinetic/grenadelauncher/bigcase
	cost_per_order = 2500

/datum/orderable_item/waste_weapon/slab/spareshells
	item_path = /obj/item/storage/box/kinetic/grenadelauncher
	cost_per_order = 2000

/datum/orderable_item/waste_weapon/hellhound
	item_path = /obj/item/storage/box/kinetic/kineticlmg/bigcase
	cost_per_order = 3000

/datum/orderable_item/waste_weapon/hellhound/spareshells
	item_path = /obj/item/storage/box/kinetic/kineticlmg
	cost_per_order = 2500

/datum/orderable_item/waste_weapon/hellhound/sparemags
	item_path = /obj/item/storage/box/kinetic/kineticlmg/smallcase
	cost_per_order = 3000 //yes these cost the same as the gun, however its still preferable to buying a whole new gun because its harder to carry multiple LMG's than these loaders kept in nice boxes

/datum/orderable_item/waste_weapon/jdj
	item_path = /obj/item/storage/box/kinetic/minerjdj/bigcase
	cost_per_order = 115385 //really weird number however its specifically set to this to make shuttle buy a clean 75k points. This thing should demolish your wallet as violently as your enemies

/datum/orderable_item/waste_weapon/jdj/spareshells
	item_path = /obj/item/storage/box/kinetic/minerjdj
	cost_per_order = 76923 //same reason as above, this puts it at 50k for a shuttle buy
