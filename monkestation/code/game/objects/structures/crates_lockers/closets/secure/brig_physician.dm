/obj/structure/closet/secure_closet/secmed
	name = "brig physician's locker"
	icon = 'monkestation/icons/obj/storage/closet.dmi'
	icon_state = "brigphys"
	req_access = list(ACCESS_BRIG)


/obj/structure/closet/secure_closet/secmed/PopulateContents()
	..()

	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/garment/brig_physician(src)
	new /obj/item/storage/backpack/duffelbag/secmed/surgery(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/storage/toolbox/repair (src)
	new /obj/item/storage/medkit/brute(src)
	new /obj/item/storage/medkit/fire(src)
	new /obj/item/storage/medkit/toxin(src)
	new /obj/item/storage/medkit/o2(src)
