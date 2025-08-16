/obj/structure/closet/secure_closet/corporate_liaison
	name = "Nanotrasen representative's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'

/obj/structure/closet/secure_closet/corporate_liaison/PopulateContents()
	..()
	new /obj/item/storage/backpack/satchel/leather(src)
	new /obj/item/storage/photo_album/personal(src)
	new /obj/item/assembly/flash(src)
	new /obj/item/bedsheet/centcom(src)
	new /obj/item/storage/bag/garment/corporate_liaison(src)
	new /obj/item/circuitboard/machine/fax(src)
	new /obj/item/storage/photo_album/nt_rep(src)
