/************************************************************
 * Thorium Fuel Rod
 * - Long-lived, stable, and self-moderating.
 * - Provides consistent output with mild reactivity to heat.
 * - Ideal for balancing high-output or unstable cores.
 ************************************************************/

/// Thorium Fuel Rod
/obj/item/rbmk/fuel_rod/thorium
	name = "Thorium Fuel Rod"
	desc = "A long-lasting, stable fuel rod that provides consistent output with natural moderation under high heat."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "thorium"
	depleted_icon_state = "thorium_used"
	depleted_description = "A depleted thorium rod, its fuel spent but casing intact."

	// Core parameters
	fuel_amount = 1200                       // very long life
	base_heat_output = 3                     // mild heat
	base_flux_output = 1                     // low neutron production
	base_radiation_output = 6                // moderate radiation
	depletion_rate = 1.0
	reactivity_sensitivity = 0.0015          // slight heat responsiveness

	rod_type = "thorium"
	rod_color = "lightblue"

	// Multipliers and stability behavior
	thermal_multiplier = 0.9
	flux_multiplier = 1.0
	radiation_multiplier = 1.0
	active = TRUE


/************************************************************
 * Thorium Processing Logic
 ************************************************************/

/// Thorium burns slowly and moderates its reactivity at high temperature
/obj/item/rbmk/fuel_rod/thorium/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
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

	// Consume minimal fuel each tick
	fuel_amount = max(0, fuel_amount - depletion_rate)

	// Efficiency increases slightly with heat
	var/reactivity_factor = 1 + ((reactor_temperature - RBMK_AMBIENT_TEMP) / 5000) * reactivity_sensitivity
	reactivity_factor = clamp(reactivity_factor * core_feedback_factor, 0.8, 1.2)
	core_feedback_last = reactivity_factor

	// Self-moderating under high heat
	if (reactor_temperature > 8000)
		thermal_multiplier = 0.85
	else
		thermal_multiplier = 0.9

	// Calculate outputs
	var/heat_output = base_heat_output * thermal_multiplier * reactivity_factor
	var/flux_output = base_flux_output * flux_multiplier
	var/radiation_output = base_radiation_output * radiation_multiplier * reactivity_factor

	return list(
		"heat" = heat_output,
		"flux" = flux_output,
		"radiation" = radiation_output,
		"thermal_mult" = thermal_multiplier,
		"flux_mult" = flux_multiplier
	)
