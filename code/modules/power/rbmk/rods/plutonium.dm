/************************************************************
 * Plutonium Fuel Rod
 * - Extremely powerful and unstable
 * - Reacts heavily to reactor temperature and flux
 * - High radiation output and rapid depletion
 ************************************************************/

/// Plutonium Fuel Rod
/obj/item/rbmk/fuel_rod/plutonium
	name = "Plutonium Fuel Rod"
	desc = "An unstable, high-yield rod that rapidly increases heat and radiation output. Dangerous if not cooled properly."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plutonium"

	// Core properties
	fuel_amount = 800                   // burns quickly
	base_heat_output = 7                // high thermal generation
	base_flux_output = 4                // strong neutron production
	base_radiation_output = 15          // extreme radiation
	depletion_rate = 1.0                // base consumption
	reactivity_sensitivity = 0.0035     // strong reactivity to feedback

	rod_type = "plutonium"
	rod_color = "crimson"

	// Instability multipliers
	thermal_multiplier = 1.4
	flux_multiplier = 1.25
	radiation_multiplier = 1.3
	active = TRUE

	depleted_icon_state = "plutonium_used"
	depleted_description = "A spent plutonium fuel rod, still faintly radioactive."


/************************************************************
 * Plutonium Processing Logic
 ************************************************************/

/// Reacts violently to reactor conditions
/obj/item/rbmk/fuel_rod/plutonium/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
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

	// Depletion increases sharply with heat
	var/depletion_factor = 1 + ((reactor_temperature - RBMK_AMBIENT_TEMP) / 3000)
	fuel_amount = max(0, fuel_amount - (depletion_rate * depletion_factor))

	// Reactivity scaling
	var/reactivity_factor = 1 + ((reactor_temperature / 2000) * reactivity_sensitivity) + (reactor_flux * 0.001)
	reactivity_factor = clamp(reactivity_factor * core_feedback_factor, 1.0, 3.0)
	core_feedback_last = reactivity_factor

	// Amplified outputs
	var/heat_output = base_heat_output * reactivity_factor * thermal_multiplier
	var/flux_output = base_flux_output * reactivity_factor * flux_multiplier
	var/radiation_output = base_radiation_output * reactivity_factor * radiation_multiplier

	return list(
		"heat" = heat_output,
		"flux" = flux_output,
		"radiation" = radiation_output,
		"thermal_mult" = thermal_multiplier,
		"flux_mult" = flux_multiplier
	)
