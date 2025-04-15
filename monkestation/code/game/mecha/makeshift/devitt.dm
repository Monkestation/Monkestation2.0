/obj/vehicle/sealed/mecha/devitt
	desc = "A multi hundred year old tank. How the hell it is running and on a space station is the least of your worries."
	name = "Devitt Mk3"
	icon = 'monkestation/icons/mecha/tanks.dmi'
	icon_state = "devitt"
	base_icon_state = "devitt"
	silicon_icon_state = "null"
	max_integrity = 500 // its a hunk of steel that didnt need to be limited by mecha legs
	force = 50
	movedelay = 1.2
	stepsound = 'monkestation/sound/mecha/tank_treads.ogg'
	turnsound = 'monkestation/sound/mecha/tank_treads.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/devitt //its neigh on immune to bullets, but explosives and melee will ruin it.
	internal_damage_threshold = 30 //Its old but no electronics
	wreckage = null
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
//	max_occupants = 2 driver+gunner, otherwise this thing would be gods OP  (commented out untill I do this.)
	max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 1, // you can put an engine in it, wow!
		MECHA_ARMOR = 0,
	)

/datum/armor/devitt
	melee = 10
	bullet = 70
	laser = 70
	energy = 70
	bomb = 10
	fire = 90
	acid = 20






