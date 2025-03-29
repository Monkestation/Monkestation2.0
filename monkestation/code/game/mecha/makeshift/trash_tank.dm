/obj/vehicle/sealed/mecha/working/makeshift_ambulance
	desc = "A trashcart that seems to be repurposed as the basis of a tank hull. with a turret and an electric engine strapped into it. It's a miracle it's even working"
	name = "trash tank"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "trash_tank"
	base_icon_state = "trash_tank"
	silicon_icon_state = "null"
	max_integrity = 200
	movedelay = 1.5
	stepsound = 'sound/vehicles/carrev.ogg'
	turnsound = 'sound/vehicles/carrev.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = list(melee = 30, bullet = 20, laser = 20, energy = 10, bomb = 20, bio = 0, rad = 0, fire = 70, acid = 60) //mediocre armor, do you expect any better?
	internal_damage_threshold = 50 //Its got shitty durabilit
	wreckage = null
	mech_type = EXOSUIT_MODULE_MAKESHIFT & EXOSUIT_MODULE_MEDICAL
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)
