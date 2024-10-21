obj/item/gun/ballistic/automatic/ar/tactical
	name = "\improper NT-ARG MK.II 'Boarder'"
	desc = "A robust assault rifle used by Nanotrasen fighting forces. This one is fitted with multiple attachment points."
	icon = 'monkestation/code/modules/CBRN/tactical-ar.dmi'
	icon_state = "tactical-arg"
	can_suppress = TRUE
	suppressor_x_offset = 8
	can_bayonet = TRUE
	knife_x_offset = 20
	knife_y_offset = 11
	pin = /obj/item/firing_pin/implant/mindshield
	accepted_magazine_type = /obj/item/ammo_box/magazine/m556/ar

/obj/item/gun/ballistic/automatic/ar/tactical/add_seclight_point() //Seclite functionality
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 13, \
		overlay_y = 15)

/obj/item/ammo_box/magazine/m556/ar

	name = "rifle magazine (5.56mm)"
	icon = 'monkestation/code/modules/CBRN/ar_ammo.dmi'
	icon_state = "ar-5.56mm"
