/obj/item/storage/box/buckshotroulette
	name = "box of blank shotgun shells"
	desc = "A box full of shells that do not contain any projectiles."
	icon_state = "beanbagshot_box"
	illustration = null

/obj/item/storage/box/buckshotroulette/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/beanbag/blank(src)
