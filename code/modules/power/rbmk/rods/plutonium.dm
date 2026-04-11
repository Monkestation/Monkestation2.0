/*************************************************************
 * Plutonium Fuel Rod — Canonical V1
 * -----------------------------------------------------------
 * Role:
 * - highest-output standard rod
 * - hottest
 * - most radioactive
 * - shortest-lived of the three basics
 *************************************************************/

/// Plutonium fuel rod
/obj/item/rbmk/fuel_rod/plutonium

	name = "Plutonium Fuel Rod"
	desc = "A dangerously potent fuel rod with a massive neutron output. Requires aggressive cooling."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plutonium"

	// Depleted appearance
	depleted_icon_state = "plutonium_used"
	depleted_description = "A spent plutonium rod. Still faintly warm."

	// Identification
	rod_type = "plutonium"
	rod_color = "crimson"

	// Fuel system
	fuel_amount = 800
	fuel_consumption = 1

	// Output profile
	reactivity = 16
	flux_multiplier = 1.25
	radiation_multiplier = 3.0
	thermal_multiplier = 1.4

	// Activation state
	active = TRUE
