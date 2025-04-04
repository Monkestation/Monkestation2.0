/obj/item/mecha_ammo/makeshift
	name = "makeshift shells ammo box"
	desc = "A improvised box of makeshift ammunition, it looks something out of Mad Max"
	icon = 'monkestation/icons/mecha/makeshift_ammo.dmi'
	icon_state = "pipegun_ammo"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3)
	rounds = 8
	ammo_type = MECHA_AMMO_PIPEGUN

/obj/item/mecha_ammo/makeshift/peashooter
	name = "peashooter ammo box"
	icon_state = "peashooter_ammo"
	rounds = 30
	ammo_type = MECHA_AMMO_PEASHOOTER

/obj/item/mecha_ammo/makeshift/isg
	name = "launchable ieds"
	desc = "A rusty box filled with refitted IEDs, for use with a jury-rigged cannon. Cannot be primed by hand."
	icon_state = "isg_ammo"
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	rounds = 3
	ammo_type = MECHA_AMMO_ISG
