/obj/item/gun/energy/laser/plasmacore
	name = "PlasmaCore-6e"
	icon = 'monkestation/code/modules/NT_rep/cool_gun/plasmacoresixe.dmi'
	icon_state = "plasma_core_six"
	charge_sections = 6
	cell_type = /obj/item/stock_parts/cell/plasmacore
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire)


/obj/item/gun/energy/laser/plasmacore/Initialize(mapload) //it takes two hand slots and costs 12 tc, they deserve fast recharging
	. = ..()
	AddComponent( \
		/datum/component/gun_crank, \
		charging_cell = get_cell(), \
		charge_amount = 100, \
		cooldown_time = 1.5 SECONDS, \
		charge_sound = 'sound/weapons/laser_crank.ogg', \
		charge_sound_cooldown_time = 1.3 SECONDS, \
		)

/obj/item/stock_parts/cell/plasmacore
	name = "PlasmaCore-6e experimental cell"
	maxcharge = 600 //same as the secborg cell but i'm not reusing that here
	icon = 'icons/obj/power.dmi'
	icon_state = "icell"
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4, /datum/material/plasma=SMALL_MATERIAL_AMOUNT)
