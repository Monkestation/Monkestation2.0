/************************************************************
 * Bananium Fuel Rod
 * - A ridiculous but functional moderator.
 * - Produces small amounts of heat and radiation.
 * - Slightly dampens reactor flux and overall reactivity.
 ************************************************************/

/// Bananium Fuel Rod
/obj/item/rbmk/fuel_rod/bananium
	name = "Bananium Fuel Rod"
	desc = "Ridiculous and silly, yet somehow still a functional reactor moderator."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "bananium"
	depleted_icon_state = "bananium_used"
	depleted_description = "A hollowed-out bananium rod, still faintly smells like potassium."

	// Core parameters
	fuel_amount = 600
	base_heat_output = 2
	base_flux_output = 1
	base_radiation_output = 3
	depletion_rate = 0.5
	reactivity_sensitivity = 0.0015      // gentle reactor response

	// Stabilizing modifiers
	thermal_multiplier = 0.8             // reduces total heat buildup
	flux_multiplier = 0.9                // absorbs some neutron activity
	radiation_multiplier = 1.0

	rod_type = "bananium"
	rod_color = "yellow"

	active = TRUE


/************************************************************
 * Bananium Rod Processing Logic
 ************************************************************/

/// Burns slowly, lightly reacts to the reactor environment, and stabilizes the core
/obj/item/rbmk/fuel_rod/bananium/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
	// Handle depletion
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

	// Gradual fuel burn
	fuel_amount = max(0, fuel_amount - depletion_rate)

	// --- Reactivity model ---
	var/temperature_factor = 1 + ((reactor_temperature - RBMK_AMBIENT_TEMP) * reactivity_sensitivity)
	var/flux_factor = 1 + (reactor_flux * 0.005)
	var/reactivity_factor = clamp(core_feedback_factor * temperature_factor * flux_factor, 0.8, 1.5)
	core_feedback_last = reactivity_factor

	// --- Output calculation ---
	var/heat_output = base_heat_output * reactivity_factor * thermal_multiplier
	var/flux_output = base_flux_output * (1 / reactivity_factor) * flux_multiplier  // acts as a weak moderator
	var/radiation_output = base_radiation_output * sqrt(reactivity_factor) * radiation_multiplier

	return list(
		"heat" = heat_output,
		"flux" = flux_output,
		"radiation" = radiation_output,
		"thermal_mult" = thermal_multiplier,
		"flux_mult" = flux_multiplier
	)
