/************************************************************
 * Plasma Moderator Rod
 * - Amplifies reactor thermal feedback instead of producing heat directly.
 * - Never depletes; scales dynamically with the core’s activity.
 ************************************************************/

/// Plasma Moderator Rod
/obj/item/rbmk/fuel_rod/plasma
	name = "Plasma Moderator Rod"
	desc = "A glowing purple rod that supercharges the reactor's heat transfer and amplifies instability if not cooled properly."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plasma"

	// Infinite life, pure amplifier
	fuel_amount = INFINITY
	base_heat_output = 0
	base_flux_output = 0
	base_radiation_output = 0
	depletion_rate = 0
	reactivity_sensitivity = 0.004

	rod_type = "plasma"
	rod_color = "purple"

	// Amplifier multipliers
	thermal_multiplier = 1.3
	flux_multiplier = 1.15
	radiation_multiplier = 1.0
	active = TRUE


/************************************************************
 * Plasma rods override process_rod with feedback amplification
 ************************************************************/

/// Plasma rods never deplete; they enhance core feedback behavior
/obj/item/rbmk/fuel_rod/plasma/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
	// Plasma rods always remain active
	var/reactivity_factor = 1 + ((reactor_temperature / 2000) * reactivity_sensitivity) + (reactor_flux * 0.002)
	reactivity_factor = clamp(reactivity_factor, 1.0, 2.5)

	// Amplifies reactor’s current state
	var/thermal_amplify = thermal_multiplier * reactivity_factor
	var/flux_amplify = flux_multiplier * (1 + (reactor_flux / 500))
	var/radiation_bonus = (reactor_temperature > 5000) ? (reactor_temperature / 10000) : 0

	// Plasma rods enhance the system instead of producing stand-alone output
	return list(
		"heat" = base_heat_output + (reactor_temperature * 0.001 * thermal_amplify),
		"flux" = base_flux_output + (reactor_flux * 0.05 * flux_amplify),
		"radiation" = base_radiation_output + radiation_bonus,
		"thermal_mult" = thermal_amplify,
		"flux_mult" = flux_amplify
	)
