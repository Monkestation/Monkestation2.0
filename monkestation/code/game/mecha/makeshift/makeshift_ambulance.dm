/obj/vehicle/sealed/mecha/makeshift_ambulance
	desc = "An haphazardly-built vehicle built upon a porta potty locker as it's main chassis. It appears to function as an impromptu makeshift ambulance"
	name = "Porta Potty Ambulance"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "pottyambo"
	base_icon_state = "pottyambo"
	silicon_icon_state = "null"
	max_integrity = 125
	lights_power = 6
	movedelay = 1.5
	stepsound = 'sound/vehicles/carrev.ogg'
	turnsound = 'sound/vehicles/carrev.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS //can't strafe bruv
	armor_type = /datum/armor/scrap_vehicles //Same armour as a locker (close enough to a portapotty no?)
	internal_damage_threshold = 30 //Its got shitty durability
	wreckage = null
	mech_type = EXOSUIT_MODULE_AMBULANCE
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)
