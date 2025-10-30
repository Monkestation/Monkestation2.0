/************************************************************
 * Supermatter Fuel Rod
 * - Contains a sliver of condensed supermatter crystal.
 * - Produces extreme heat and radiation; highly unstable.
 * - Will self-detonate if instability or temperature exceed safe limits.
 ************************************************************/

/// Supermatter Fuel Rod
/obj/item/rbmk/fuel_rod/supermatter
	name = "Supermatter Fuel Rod"
	desc = "A Syndicate-engineered rod containing a sliver of supermatter. Emits immense energy and threatens catastrophic meltdown."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "syndicate"
	
	// Core parameters
	fuel_amount = 100                    // short lifespan
	base_heat_output = 150               // massive heat output
	base_flux_output = 0                 // no neutron production
	base_radiation_output = 120          // lethal radiation emission
	depletion_rate = 1.0
	reactivity_sensitivity = 0.006       // extremely reactive

	rod_type = "supermatter"
	rod_color = "gold"

	// Output multipliers
	thermal_multiplier = 1.8
	flux_multiplier = 1.2
	radiation_multiplier = 2.0

	// Internal instability tracking
	var/internal_instability = 0
	var/meltdown_threshold = 100
	var/meltdown_triggered = FALSE
	active = TRUE


/************************************************************
 * Supermatter Processing Logic
 ************************************************************/

/// Processes reactor response and internal meltdown buildup
/obj/item/rbmk/fuel_rod/supermatter/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
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

	// Consume fuel gradually
	fuel_amount = max(0, fuel_amount - depletion_rate)

	// Build internal instability based on core conditions
	internal_instability += ((reactor_temperature / 3000) + (reactor_flux / 50)) * reactivity_sensitivity

	// Meltdown check
	if (internal_instability >= meltdown_threshold && !meltdown_triggered)
		meltdown_triggered = TRUE
		var/obj/machinery/rbmk/reactor/reactor_core = loc
		if (istype(reactor_core))
			reactor_core.trigger_meltdown("Supermatter containment failure detected!")

	// Reactivity scaling
	var/reactivity_factor = 1 + ((reactor_temperature / 2000) * reactivity_sensitivity)
	reactivity_factor = clamp(reactivity_factor * core_feedback_factor, 1.0, 3.5)
	core_feedback_last = reactivity_factor

	// Extreme heat & radiation output
	var/heat_output = base_heat_output * reactivity_factor * thermal_multiplier
	var/radiation_output = base_radiation_output * reactivity_factor * radiation_multiplier

	// Minimal flux production (indirect effect)
	var/flux_output = reactor_flux * 0.02 * flux_multiplier

	return list(
		"heat" = heat_output,
		"flux" = flux_output,
		"radiation" = radiation_output,
		"thermal_mult" = thermal_multiplier,
		"flux_mult" = flux_multiplier
	)
