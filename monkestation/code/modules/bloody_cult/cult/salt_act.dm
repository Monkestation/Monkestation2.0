/atom/proc/salt_act()
	return

/obj/effect/decal/cleanable/food/salt/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	for(var/atom/movable/AM in loc)
		AM.salt_act()

/obj/item/clothing/suit/hooded/cultrobes/salt_act()
	acid_melt()

/obj/item/clothing/shoes/cult/salt_act()
	acid_melt()

/obj/item/clothing/gloves/color/black/cult/salt_act()
	acid_melt()

/obj/item/storage/backpack/cultpack/salt_act()
	acid_melt()

/obj/item/weapon/bloodcult_pamphlet/salt_act()
	fire_act(1000, 200)

/obj/item/storage/cult/salt_act()
	acid_melt()

/obj/item/reagent_containers/cup/cult/salt_act()
	acid_melt()

/obj/item/restraints/cult/salt_act()
	acid_melt()

/obj/item/weapon/blood_tesseract/salt_act()
	throw_impact()
