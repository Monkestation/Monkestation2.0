// Atmos types used for planetary airs
/datum/atmosphere/lavaland
	id = LAVALAND_DEFAULT_ATMOS

	base_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/nitrogen=10,
		/datum/gas/carbon_dioxide=10,
	)
	restricted_gases = list(
		/datum/gas/plasma=0.1,
		/datum/gas/bz=1.2,
		/datum/gas/miasma=1.2,
		/datum/gas/water_vapor=0.1,
	)
	restricted_chance = 30

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = BODYTEMP_COLD_DAMAGE_LIMIT + 1
	maximum_temp = BODYTEMP_HEAT_DAMAGE_LIMIT - 5

/datum/atmosphere/icemoon
	id = ICEMOON_DEFAULT_ATMOS

	base_gases = list(
		/datum/gas/oxygen=20, //MONKESTATION EDIT: Increases oxygen level by a fuckload so that craterstation is breathable, formerly 10
		/datum/gas/nitrogen=40, //MONKESTATION EDIT: they kept bothering me for more air formerly 10
	)
	normal_gases = list(
		/datum/gas/oxygen=24, //MONKESTATION EDIT: oxygen (used to be 10)
		/datum/gas/nitrogen=1, //used to be 10l, now 1. lmao. this is going to backfire horribly.
		/datum/gas/carbon_dioxide=5, //MONKESTATION EDIT: 15 was too much, down to 5. used to be 10
	)
	restricted_gases = list(
		/datum/gas/plasma=0.2, //used to be 0.5 i think, it kept setting things on fire whenever i wanted to weld and i really dont want that for crater
		/datum/gas/water_vapor=0.1,
		/datum/gas/miasma=1.2,
	)
	restricted_chance = 20

	minimum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE + 1 //miner mains are gonna kill me for this one
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE + 30

	minimum_temp = ICEBOX_MIN_TEMPERATURE
	maximum_temp = ICEBOX_MIN_TEMPERATURE

/datum/atmosphere/oshan
	id = OSHAN_DEFAULT_ATMOS


	base_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/carbon_dioxide=10,
	)
	normal_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/carbon_dioxide=10,
	)
	restricted_gases = list(
		/datum/gas/oxygen=10,
		/datum/gas/carbon_dioxide=10,
	)

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = T20C
	maximum_temp = T20C
