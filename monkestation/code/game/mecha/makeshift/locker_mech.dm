/obj/vehicle/sealed/mecha/working/ripley/lockermech
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that resembles the functions of a mech."
	name = "Locker Mech"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "lockermech"
	base_icon_state = "lockermech"
	silicon_icon_state = "null"
	max_integrity = 100 //its made of scraps
	lights_power = 5
	movedelay = 2 //Same speed as a ripley, for now.
	armor_type = /datum/armor/scrap_vehicles //Same armour as a locker
	internal_damage_threshold = 30 //Its got shitty durability
	wreckage = null
	mech_type = EXOSUIT_MODULE_MAKESHIFT
	cargo = list()
	cargo_capacity = 5 // you can fit a few things in this locker but not much.
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)

/datum/armor/scrap_vehicles
	melee = 20
	bullet = 10
	laser = 10
	bomb = 10
	fire = 70
	acid = 60
