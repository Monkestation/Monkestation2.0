///Ammo

/obj/item/storage/box/kinetic
	name = "box of kinetic SMG magazines"
	desc = "A box full of kinetic projectile magazines, specifically for the 'Rapier' SMG.\
	It is specially designed to only hold proto-kinetic magazines, and also fit inside of explorer webbing."
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/magazine/pksmgmag,
	))

/obj/item/storage/box/kinetic/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_box/magazine/pksmgmag(src)

/obj/item/storage/box/kinetic/autoshotgun //box containing 45 spare shells for the fenrir, used to reload spare mags. cheaper to buy than new spare mags.
	name = "20. Gauge Hydra Shell Box"
	desc = "A surprisingly hefty box containing 45 spare 10. gauge Hydra shells, for reloading spare Fenrir magazines. Despite its heft, it fits in explorer webbing."
	icon_state = "smallshell_box"
	illustration = ""

/obj/item/storage/box/kinetic/autoshotgun/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 45
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 45
	atom_storage.set_holdable(list(/obj/item/ammo_casing/shotgun/hydrakinetic))

/obj/item/storage/box/kinetic/autoshotgun/PopulateContents() //populate
	for(var/i in 1 to 45)
		new /obj/item/ammo_casing/shotgun/hydrakinetic (src)

/obj/item/storage/box/kinetic/autoshotgun/smallcase //box containing 3 spare mags for the fenrir auto shotgun
	name = "Spare Fenrir Shotgun Magazine Case"
	desc = "A small gun case that contains three spare magazines for the Fenrir auto shotgun. It fits in explorer webbing too."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case_small"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/autoshotgun/smallcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 3
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/autoshotgun/smallcase/PopulateContents() //populate
		new /obj/item/ammo_box/magazine/autoshotgun (src)
		new /obj/item/ammo_box/magazine/autoshotgun (src)
		new /obj/item/ammo_box/magazine/autoshotgun (src)


/obj/item/storage/box/kinetic/kineticlmg //box of stripper clips (20, totalling 100 rounds)
	name = "box of kinetic 7.62mm stripper clips"
	desc = "A box that contains up to 20 stripper clips of Kinetic 7.62mm, for refilling the 'Hellhound' LMG. Surprisingly fits inside of explorer webbings."
	icon_state = "kinetic762_box"
	illustration = ""

/obj/item/storage/box/kinetic/kineticlmg/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 20
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 100
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/a762/kinetic,
	))

/obj/item/storage/box/kinetic/kineticlmg/PopulateContents() //populate
	for(var/i in 1 to 20)
		new /obj/item/ammo_box/a762/kinetic(src)

/obj/item/storage/box/kinetic/kineticlmg/smallcase //hilarious its called small case when it holds the larger option
	name = "Case of 'Hellhound' Rapid Reloaders"
	desc = "A case containing three rapid reloaders for the 'Hellhound' LMG. For when you really just dont have time."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case_small"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/kineticlmg/smallcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 3
	atom_storage.set_holdable(list(/obj/item/ammo_box/a762/kinetic/big))

/obj/item/storage/box/kinetic/kineticlmg/smallcase/PopulateContents() //populate

		new /obj/item/ammo_box/a762/kinetic/big (src)
		new /obj/item/ammo_box/a762/kinetic/big (src)
		new /obj/item/ammo_box/a762/kinetic/big (src)


/obj/item/storage/box/kinetic/grenadelauncher //box containing 12 spare 40mm kinetic shells for the 'Slab' grenade launcher
	name = "40mm Kinetic Grenade Box"
	desc = "A small box containing 12 spare 40mm Kinetic Grenades for the 'Slab' Grenade Launcher. Despite everything, it fits in explorer webbing."
	icon_state = "40mmk_box"
	illustration = ""

/obj/item/storage/box/kinetic/grenadelauncher/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 12
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 12
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/a40mm/kinetic
	))

/obj/item/storage/box/kinetic/grenadelauncher/PopulateContents() //populate
	for(var/i in 1 to 12)
		new /obj/item/ammo_casing/a40mm/kinetic (src)


/obj/item/storage/box/kinetic/govmining
	name = "box of .45-70 Gov Kinetic rounds"
	desc = "A box containing 36 individual .45-70 Gov Kinetic rounds. Good for loading your 'Duster' revolver or refilling your speedloaders. Fits in explorer webbing."
	icon_state = "gov_box"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/cardboard

/obj/item/storage/box/kinetic/govmining/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 36
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 36
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/govmining,
	))

/obj/item/storage/box/kinetic/govmining/PopulateContents() //populate
	for(var/i in 1 to 36)
		new /obj/item/ammo_casing/govmining(src)

/obj/item/storage/box/kinetic/govmining/smallcase
	name = "Case of 'Duster' Speedloaders"
	desc = "A case containing three spare speedloaders for the 'Duster' revolver"
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case_small"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/govmining/smallcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 3
	atom_storage.set_holdable(list(/obj/item/ammo_box/govmining))

/obj/item/storage/box/kinetic/govmining/smallcase/PopulateContents() //populate

		new /obj/item/ammo_box/govmining (src)
		new /obj/item/ammo_box/govmining (src)
		new /obj/item/ammo_box/govmining (src)


/obj/item/storage/box/kinetic/minerjdj //box containing a single bullet, as to not anger the mining vendor with the bullets dynamic description
	name = ".950 JDJ Kinetic bullet case"
	desc = "A pretty redundant small gun case that only contains a single .950 JDJ Kinetic round for the 'Thor' rifle... its more than enough honestly."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case_small"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/minerjdj/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 1
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/minerjdj/PopulateContents() //populate

		new /obj/item/ammo_casing/minerjdj (src)



/obj/item/storage/box/kinetic/shotgun //box
	name = "box of kinetic shells"
	desc = "A box that can hold up to ten shells of Magnum Kinetic Buckshot for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "protoshell_box"
	illustration = "protoshell_box"

/obj/item/storage/box/kinetic/shotgun/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic,
	))

/obj/item/storage/box/kinetic/shotgun/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic(src)

/obj/item/storage/box/kinetic/shotgun/sniperslug //box
	name = "box of .50 BMG Kinetic"
	desc = "A box designed to hold up to ten shells of 50 BMG Slugs for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "bmgshell_box"
	illustration = "bmgshell_box"

/obj/item/storage/box/kinetic/shotgun/sniperslug/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/sniperslug,
	))

/obj/item/storage/box/kinetic/shotgun/sniperslug/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic/sniperslug(src)

/obj/item/storage/box/kinetic/shotgun/rockbreaker //box
	name = "box of kinetic rock breaker"
	desc = "A box for holding up to twenty shells of Rockbreaker for the PKShotgun. Surprisingly fits inside of explorer webbings."
	icon = 'icons/obj/storage/toolbox.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "ammobox"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/shotgun/rockbreaker/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 20
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/rockbreaker,
	))

/obj/item/storage/box/kinetic/shotgun/rockbreaker/PopulateContents() //populate
	for(var/i in 1 to 20)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)




///Guns

/obj/item/storage/box/pksmg //A case that the SMG comes in on purchase, containing three magazines
	name = "'Rapier' SMG Case"
	desc = "A case containing a 'Rapier' SMG and three magazines. Designed for full auto but has limited ammo."
	icon_state = "miner_case"
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	illustration = ""

/obj/item/storage/box/pksmg/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 4

/obj/item/storage/box/pksmg/PopulateContents()
		new /obj/item/gun/ballistic/automatic/proto/pksmg(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)


/obj/item/storage/box/kinetic/autoshotgun/bigcase //box containing the actual gun and a few spare mags for sale
	name = "'Fenrir' Shotgun case"
	desc = "A mining gun case containing a 20. gauge Fenrir automatic shotgun and three spare magazines."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/autoshotgun/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 4
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/autoshotgun/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/shotgun/autoshotgun (src)
		new /obj/item/ammo_box/magazine/autoshotgun (src)
		new /obj/item/ammo_box/magazine/autoshotgun (src)
		new /obj/item/ammo_box/magazine/autoshotgun (src)


/obj/item/storage/box/kinetic/kineticlmg/bigcase //box containing the LMG and a box of extra bullets to get one reload
	name = "Kinetic 'Hellhound' LMG case"
	desc = "A special and totally original gun case that contains a Kinetic 'Hellhound' LMG, and a box of spare rounds to refill it."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/kineticlmg/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 2
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/kineticlmg/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/automatic/proto/pksmg/kineticlmg (src)
		new /obj/item/storage/box/kinetic/kineticlmg (src)


/obj/item/storage/box/kinetic/grenadelauncher/bigcase //box containing the  launcher and a spare box of grenades
	name = "'Slab' grenade launcher case"
	desc = "A mining gun case containing a six round rotary 'Slab' grenade launcher, and a box of spare grenades."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case"
	w_class = WEIGHT_CLASS_BULKY
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/grenadelauncher/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 2
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/grenadelauncher/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/revolver/grenadelauncher/kinetic (src)
		new /obj/item/storage/box/kinetic/grenadelauncher (src)


/obj/item/storage/box/kinetic/govmining/bigcase
	name = "Kinetic 'Duster' Revolver Case"
	desc = "A case containing a 'Duster' kinetic revolver and three speedloaders."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/govmining/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 4
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/govmining/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/revolver/govmining (src)
		new /obj/item/ammo_box/govmining (src)
		new /obj/item/ammo_box/govmining (src)
		new /obj/item/ammo_box/govmining (src)


/obj/item/storage/box/kinetic/minerjdj/bigcase //box containing the actual gun for sale
	name = ".950 JDJ Kinetic 'Thor' Rifle case"
	desc = "A pretty redundant gun case that only contains the .950 JDJ Kinetic 'Thor' Rifle... contains no spare ammo, so make your one shot count or buy some more bullets."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/minerjdj/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 1
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/minerjdj/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/rifle/minerjdj (src)


/obj/item/storage/box/kinetic/shotgun/bigcase //box
	name = "Kinetic 'Slayer' Shotgun Case"
	desc = "A special and totally original gun case that contains a 'Slayer' Shotgun, eight shells of Rockbreaker, and four shells of Magnum Kinetic Buckshot. Beware, they dont fit back inside once taken out for some reason."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/shotgun/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 13
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 13
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/shotgun/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/shotgun/doublebarrel/kinetic(src) //the shotgun
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //fuck it we do a little bit of bad code :)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //8 shells of rockbreaker
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src) //4 shells of kinetic buckshot
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)


// Pkas
/obj/item/storage/box/shockwave
	name = "PK-Shockwave Box"
	desc = "A box containing a PK-Shockwave and the Shockwave modkit. Designed to create large blasts of powerful kinetic energy for clearing large amounts of rock, or fauna"
	icon_state = "cyber_implants"
	icon_preview = /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave::icon
	icon_state_preview = /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave::icon_state

/obj/item/storage/box/shockwave/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 2

/obj/item/storage/box/shockwave/PopulateContents()
	new /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave(src)
	new /obj/item/borg/upgrade/modkit/aoe/turfs/shockwave(src)

