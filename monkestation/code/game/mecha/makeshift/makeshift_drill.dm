/obj/vehicle/sealed/mecha/makeshift_drill
	desc = "a square of rusted sheetmetal bolted to tracks and housing a comically large drill. This pile of junk looks especially fragile."
	name = "Sheet metal drill"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "sheetmetaldrill"
	base_icon_state = "sheetmetaldrill"
	silicon_icon_state = "null"
	max_integrity = 65
	lights_power = 8
	movedelay = 2.5
	stepsound = 'monkestation/sound/mecha/tank_treads.ogg'
	turnsound = 'monkestation/sound/mecha/tank_treads.ogg'
	mecha_flags = IS_ENCLOSED | HAS_LIGHTS //can't strafe bruv
	armor_type = /datum/armor/scrap_vehicles //Same armour as a locker (like it matters with that hp)
	internal_damage_threshold = 30 //Its got shitty durability
	wreckage = null
	mech_type = EXOSUIT_MODULE_DRILL
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 2,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)
