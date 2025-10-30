/************************************************************
 * Uranium Fuel Rod
 * - The classic choice: efficient but temperamental.
 * - Produces high heat and radiation; scales with flux.
 * - Runs best in midrange temperatures but destabilizes when overheated.
 ************************************************************/

/// Uranium Fuel Rod
/obj/item/rbmk/fuel_rod/uranium
	name = "Uranium Fuel Rod"
	desc = "A standard uranium fuel rod — powerful, efficient, and volatile under high temperatures."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "uranium"
	depleted_icon_state = "uranium_used"
	depleted_description = "A spent uranium rod, faintly warm to the touch."

	// Core properties
	fuel_amount = 1000
	base_heat_output = 5
	base_flux_output = 2
	base_radiation_output = 10
	depletion_rate = 1.0

	rod_type = "uranium"
	rod_color = "green"

	// Multiplier tuning
	thermal_multiplier = 1.0
	flux_multiplier = 1.0
	radiation_multiplier = 1.0

	// Reactivity tuning
	reactivity_sensitivity = 0.002      // how strongly it responds to environment
	heat_penalty_threshold = 9000       // starts becoming less efficient here
	flux_boost_threshold = 50           // flux above this increases output

	active = TRUE


/************************************************************
 * Uranium Processing Logic
 ************************************************************/

/// Responds dynamically to reactor temperature and flux
/obj/item/rbmk/fuel_rod/uranium/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
	// Handle depletion and inactive states
	if (fuel_amount <= 0)
		if (active)
			active = FALSE
			icon_state = depleted_icon_state
			desc = depleted_description
		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0,
			"thermal_mult" = 1.0,
			"flux_mult" = 1.0
		)

	// Consume fuel
	fuel_amount = max(0, fuel_amount - depletion_rate)

	// --- Reactivity Model ---
	var/reactivity_factor = 1.0

	// Gains efficiency in moderate temperature range
	if (reactor_temperature > RBMK_AMBIENT_TEMP && reactor_temperature < heat_penalty_threshold)
		reactivity_factor += ((reactor_temperature - RBMK_AMBIENT_TEMP) / 4000) * reactivity_sensitivity

	// Loses efficiency when overheated
	if (reactor_temperature >= heat_penalty_threshold)
		reactivity_factor -= ((reactor_temperature - heat_penalty_threshold) / 4000) * reactivity_sensitivity

	// Boosts neutron & radiation output under high flux
	if (reactor_flux > flux_boost_threshold)
		reactivity_factor += ((reactor_flux - flux_boost_threshold) / 100) * (reactivity_sensitivity * 2)

	reactivity_factor = clamp(reactivity_factor * core_feedback_factor, 0.8, 1.3)
	core_feedback_last = reactivity_factor

	// --- Calculate Outputs ---
	var/heat_output = base_heat_output * thermal_multiplier * reactivity_factor
	var/flux_output = base_flux_output * flux_multiplier * reactivity_factor
	var/radiation_output = base_radiation_output * radiation_multiplier * reactivity_factor

	return list(
		"flux" = flux_output,
		"heat" = heat_output,
		"radiation" = radiation_output,
		"flux_mult" = flux_multiplier,
		"thermal_mult" = thermal_multiplier
	)
