/obj/item/implanter/weapons_auth
	name = "implanter (Weapons Authorization)"
	imp_type = /obj/item/implant/weapons_auth

/obj/item/storage/box/syndie_kit/weapons_auth
	name = "Weapons Authorization kit"

/obj/item/storage/box/syndie_kit/weapons_auth/PopulateContents()
	new /obj/item/implanter/weapons_auth(src)

/obj/item/storage/box/syndie_kit/weapons_auth_pins
	name = "Weapons Authorization kit"

/obj/item/storage/box/syndie_kit/weapons_auth_pins/PopulateContents()
	new /obj/item/implanter/weapons_auth(src)
	for(var/i in 1 to 3)
		new /obj/item/firing_pin/implant/pindicate(src)
