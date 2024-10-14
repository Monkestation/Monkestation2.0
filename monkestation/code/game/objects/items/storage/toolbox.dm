/obj/item/storage/toolbox/brig_physician
	name = "Brig Phyiscan's Toolbox"
	desc = "Capable of robusting and repairing any troublesome robots after the fact."
	icon = 'monkestation/icons/obj/clothing/jobs/brig_physician.dmi'
	icon_state = "toolbox_brigphys"
	inhand_icon_state = "toolbox_brigphys"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/brigphys_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/brigphys_righthand.dmi'

/obj/item/storage/toolbox/brig_physician/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
