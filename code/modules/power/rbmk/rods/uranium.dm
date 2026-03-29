/*************************************************************
 * Uranium Fuel Rod — Canonical V1
 * -----------------------------------------------------------
 * Role:
 * - standard baseline fuel rod
 * - hotter and more radioactive than thorium
 * - solid general-purpose power rod
 *************************************************************/

/// Uranium fuel rod
/obj/item/rbmk/fuel_rod/uranium
	name = "Uranium Fuel Rod"
	desc = "A volatile uranium fuel rod. Produces high heat and dangerous levels of radiation."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "uranium"

	// Depleted appearance
	depleted_icon_state = "uranium_used"
	depleted_description = "A spent uranium fuel rod."

	// Identification
	rod_type = "uranium"
	rod_color = "green"

	// Fuel system
	fuel_amount = 1000
	fuel_consumption = 1

	// Output profile
	reactivity = 12
	flux_multiplier = 1.0
	radiation_multiplier = 2.5
	thermal_multiplier = 1.2

	// Activation state
	active = TRUE
