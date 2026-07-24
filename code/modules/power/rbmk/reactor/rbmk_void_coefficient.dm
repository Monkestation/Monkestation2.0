/obj/machinery/rbmk/reactor/proc/update_void_coefficient()
	// A hot, fueled core retains coolant feedback after SCRAM even though that
	// feedback is no longer multiplying an active fission reaction.
	if(meltdown_in_progress || !has_active_fuel_rods() || temperature < RBMK_TEMP_RUNNING)
		void_coefficient = 0
		void_coefficient_temperature = 0
		void_coefficient_pressure = 0
		void_coefficient_coolant = 0
		last_void_flux_multiplier = 1
		return 0

	var/effective_damage_threshold = get_effective_temp_damage_threshold()
	var/temperature_ratio = CLAMP01((temperature - RBMK_TEMP_RUNNING) / max(effective_damage_threshold - RBMK_TEMP_RUNNING, 1))
	var/heat_gate = CLAMP01((temperature - RBMK_TEMP_MODERATE) / max(RBMK_TEMP_HOT, 1))

	var/temperature_coefficient = max(temperature * RBMK_VC_TEMP_COEFF, 0)
	temperature_coefficient += temperature_ratio * 0.35
	temperature_coefficient = clamp(temperature_coefficient, 0, RBMK_VC_TEMP_COMPONENT_MAX)

	var/pressure_ratio = CLAMP01(1 - (pressure / max(RBMK_PRESSURE_WARNING, 1)))
	var/pressure_coefficient = pressure_ratio * heat_gate * RBMK_VC_PRESSURE_COMPONENT_MAX

	var/coolant_moles = coolant_internal?.total_moles() || 0
	var/coolant_ratio = CLAMP01(coolant_moles / max(RBMK_VC_COOLANT_MOLES_TARGET, 1))
	var/coolant_coefficient = (1 - coolant_ratio) * heat_gate * RBMK_VC_COOLANT_COMPONENT_MAX

	void_coefficient = clamp(
		temperature_coefficient + pressure_coefficient + coolant_coefficient,
		0,
		RBMK_VC_MAX
	)

	void_coefficient_temperature = temperature_coefficient
	void_coefficient_pressure = pressure_coefficient
	void_coefficient_coolant = coolant_coefficient
	// Residual VC remains observable after SCRAM, but cannot multiply zeroed fission flux.
	last_void_flux_multiplier = running ? 1 + void_coefficient : 1

	return void_coefficient
