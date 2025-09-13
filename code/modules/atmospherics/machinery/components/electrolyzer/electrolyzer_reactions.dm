GLOBAL_LIST_INIT(electrolyzer_reactions, electrolyzer_reactions_list())

/*
 * Global proc to build the electrolyzer reactions list
 */
/proc/electrolyzer_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/electrolyzer_reaction))
		var/datum/electrolyzer_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/electrolyzer_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"
	var/desc = ""
	var/list/factor

/datum/electrolyzer_reaction/proc/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	return

/datum/electrolyzer_reaction/proc/reaction_check(datum/gas_mixture/air_mixture)
	var/temp = air_mixture.temperature
	var/list/cached_gases = air_mixture.gases
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/id in requirements)
		if (id == "MIN_TEMP" || id == "MAX_TEMP")
			continue
		if(!cached_gases[id] || cached_gases[id][MOLES] < requirements[id])
			return FALSE
	return TRUE

/datum/electrolyzer_reaction/h2o_conversion
	name = "H2O Conversion"
	id = "h2o_conversion"
	desc = "Conversion of H2o into O2 and H2"
	requirements = list(
		GAS_H2O = MINIMUM_MOLE_COUNT
	)
	factor = list(
		GAS_H2O = "2 moles of H2O get consumed",
		GAS_H2 = "1 mole of O2 gets produced",
		GAS_H2 = "2 moles of H2 get produced",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/h2o_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)

	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(GAS_H2O, GAS_H2, GAS_H2)
	var/proportion = min(air_mixture.gases[GAS_H2O][MOLES] * INVERSE(2), (2.5 * (working_power ** 2)))
	air_mixture.gases[GAS_H2O][MOLES] -= proportion * 2
	air_mixture.gases[GAS_H2][MOLES] += proportion
	air_mixture.gases[GAS_H2][MOLES] += proportion * 2
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/nob_conversion
	name = "Hypernob conversion"
	id = "nob_conversion"
	desc = "Conversion of Hypernoblium into Antinoblium"
	requirements = list(
		GAS_HYPERNOB = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = 150
	)
	factor = list(
		GAS_HYPERNOB = "1 mole of Hypernoblium gets consumed",
		GAS_ANTINOB = "0.5 moles of Antinoblium get produced",
		"Temperature" = "Can only occur under 150 kelvin.",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/nob_conversion/react(turf/location, datum/gas_mixture/air_mixture, working_power)

	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(GAS_HYPERNOB, GAS_ANTINOB)
	var/proportion = min(air_mixture.gases[GAS_HYPERNOB][MOLES], (1.5 * (working_power ** 2)))
	air_mixture.gases[GAS_HYPERNOB][MOLES] -= proportion
	air_mixture.gases[GAS_ANTINOB][MOLES] += proportion * 0.5
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/halon_generation
	name = "Halon generation"
	id = "halon_generation"
	desc = "Production of halon from the electrolysis of BZ."
	requirements = list(
		GAS_BZ = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		GAS_BZ = "Consumed during reaction.",
		GAS_H2 = "0.2 moles of oxygen gets produced per mole of BZ consumed.",
		GAS_HALON = "2 moles of Halon gets produced per mole of BZ consumed.",
		"Energy" = "91.2321 kJ of thermal energy is released per mole of BZ consumed.",
		"Temperature" = "Reaction efficiency is proportional to temperature.",
		"Location" = "Can only happen on turfs with an active Electrolyzer.",
	)

/datum/electrolyzer_reaction/halon_generation/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(GAS_BZ, GAS_H2, GAS_HALON)
	var/reaction_efficency = min(air_mixture.gases[GAS_BZ][MOLES] * (1 - NUM_E ** (-0.5 * air_mixture.temperature * working_power / FIRE_MINIMUM_TEMPERATURE_TO_EXIST)), air_mixture.gases[GAS_BZ][MOLES])
	air_mixture.gases[GAS_BZ][MOLES] -= reaction_efficency
	air_mixture.gases[GAS_H2][MOLES] += reaction_efficency * 0.2
	air_mixture.gases[GAS_HALON][MOLES] += reaction_efficency * 2
	var/energy_used = reaction_efficency * HALON_FORMATION_ENERGY
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(((air_mixture.temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
