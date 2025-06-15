/obj/vehicle/sealed/mecha/scourgehunter
	desc = "Made as a modification to a storm tank, tracks would be gunked up by zombie hordes, so legs were installed to walk over mountains of corpses."
	name = "\improper Heme QMW 1a Scourge Hunter"
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "scourgehunter"
	base_icon_state = "scourgehunter"
	SET_BASE_PIXEL(-24, 0)
	step_energy_drain = 100 // 10x drain holy fuck
	movedelay = 8 // shes slow, cause its fat, and its the first of its kind.
	max_integrity = 550 // shes fat, very fucking fat
	armor_type = /datum/armor/foxmechs
	max_temperature = 25000
	force = 50 // it needs to bash down shit to get through places
	internal_damage_threshold = 18
	wreckage = /obj/structure/mecha_wreckage/scourgehunter
	mech_type = EXOSUIT_MODULE_FOXMECH
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/quadmg,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,  // this one can be modified!
	)
	step_energy_drain = 3

/datum/armor/foxmechs
	melee = 50
	bullet = 10 // meant to fight zombies, why would it need bullet armor.
	laser = 10
	energy = 10
	fire = 100
	acid = 100
