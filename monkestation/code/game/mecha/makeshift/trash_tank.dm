/obj/vehicle/sealed/mecha/trash_tank
	desc = "A trashcart that seems to be repurposed as the basis of a tank hull. with a turret and an electric engine strapped into it. It's a miracle it's even working"
	name = "trash tank"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "trash_tank"
	base_icon_state = "trash_tank"
	silicon_icon_state = "null"
	max_integrity = 200
	force = 20
	movedelay = 1.5
	stepsound = 'monkestation/sound/mecha/tank_treads.ogg'
	turnsound = 'monkestation/sound/mecha/tank_treads.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/scrap_tank //mediocre armor, do you expect any better?
	internal_damage_threshold = 60 //Its got shitty durability
	wreckage = /obj/structure/closet/crate/trashcart
	mech_type = EXOSUIT_MODULE_TRASHTANK
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

/datum/armor/scrap_tank
	melee = 30
	bullet = 20
	laser = 20
	energy = 10
	bomb = 20
	fire = 70
	acid = 60

/datum/armor/scrap_tank/uparmoured
	melee = 60
	bullet = 40
	laser = 40
	energy = 20
	fire = 70
	acid = 60

/obj/vehicle/sealed/mecha/trash_tank/proc/upgrade()
	name = "up-armoured trash tank"
	icon_state = "trash_tank-armoured"
	base_icon_state = "trash_tank-armoured"
	update_appearance()

	armor_type = /datum/armor/scrap_tank/uparmoured
