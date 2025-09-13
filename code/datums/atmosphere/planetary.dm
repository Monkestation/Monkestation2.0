// Atmos types used for planetary airs
/datum/atmosphere/lavaland
	id = LAVALAND_DEFAULT_ATMOS

	base_gases = list(
		GAS_O2=5,
		GAS_N2=10,
	)
	normal_gases = list(
		GAS_O2=10,
		GAS_N2=10,
		GAS_CO2=10,
	)
	restricted_gases = list(
		/datum/gas/plasma=0.1,
		GAS_BZ=1.2,
		GAS_MIASMA=1.2,
		GAS_H2O=0.1,
	)
	restricted_chance = 30

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = BODYTEMP_COLD_DAMAGE_LIMIT + 1
	maximum_temp = BODYTEMP_HEAT_DAMAGE_LIMIT - 5

/datum/atmosphere/icemoon
	id = ICEMOON_DEFAULT_ATMOS

	base_gases = list(
		GAS_O2=5,
		GAS_N2=10,
	)
	normal_gases = list(
		GAS_O2=10,
		GAS_N2=10,
		GAS_CO2=10,
	)
	restricted_gases = list(
		/datum/gas/plasma=0.1,
		GAS_H2O=0.1,
		GAS_MIASMA=1.2,
	)
	restricted_chance = 20

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = ICEBOX_MIN_TEMPERATURE
	maximum_temp = ICEBOX_MIN_TEMPERATURE

/datum/atmosphere/oshan
	id = OSHAN_DEFAULT_ATMOS


	base_gases = list(
		GAS_O2=10,
		GAS_CO2=10,
	)
	normal_gases = list(
		GAS_O2=10,
		GAS_CO2=10,
	)
	restricted_gases = list(
		GAS_O2=10,
		GAS_CO2=10,
	)

	minimum_pressure = HAZARD_LOW_PRESSURE + 10
	maximum_pressure = LAVALAND_EQUIPMENT_EFFECT_PRESSURE - 1

	minimum_temp = T20C
	maximum_temp = T20C
