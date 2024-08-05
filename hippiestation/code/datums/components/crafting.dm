/datum/crafting_recipe/noose
	name = "noose"
	result = /obj/structure/noose
	reqs = list(/obj/item/stack/cable_coil =  30)
	time = 1 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/baseball_bat_spiked
	name = "Spiked Bat"
	result = /obj/item/melee/baseball_bat/spiked
	reqs = list(/obj/item/stack/rods = 5,
				/obj/item/melee/baseball_bat = 1)
	time = 100
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/glass_hatchet
	name = "Makeshift glass hatchet"
	result = /obj/item/hatchet/improvised
	reqs = list(/obj/item/stack/sheet/cloth = 1,
				/obj/item/shard/ = 1,
				/obj/item/wrench = 1,)
	time = 40
	category = CAT_WEAPON_MELEE


