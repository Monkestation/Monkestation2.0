/*************************************************************
 * RBMK Fuel Rod Base — Canonical V1
 * -----------------------------------------------------------
 * Contract:
 * - Rods are authoritative over:
 *     • fuel burn
 *     • depletion / active state
 *     • per-tick raw output
 *
 * - Reactor process integrates:
 *     rods -> flux -> heat -> void coefficient -> flux
 *
 * Design rules:
 * - Rods do NOT care about reactor temperature
 * - Rods do NOT care about void coefficient
 * - Rods return only raw physical outputs
 *************************************************************/


/*************************************************************
 * Base Fuel Rod Definition
 *************************************************************/

/// Generic RBMK fuel rod item
/obj/item/rbmk/fuel_rod
	name = "Fuel Rod"
	desc = "A generic fuel rod designed for RBMK reactors."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "rod_generic"
	layer = OBJ_LAYER + 0.02
	plane = GAME_PLANE

	/************************************************
	 * Identification
	 ************************************************/
	var/rod_type = "generic"
	var/rod_color = "white"

	/************************************************
	 * Fuel System
	 ************************************************/
	var/fuel_amount = 100
	var/fuel_consumption = 1

	/************************************************
	 * Output Characteristics
	 ************************************************/
	var/reactivity = 10
	var/flux_multiplier = 1.0
	var/radiation_multiplier = 1.0
	var/thermal_multiplier = 1.0

	/************************************************
	 * Activation State
	 ************************************************/
	var/active = TRUE

	/************************************************
	 * Depleted Appearance / Description
	 ************************************************/
	var/depleted_icon_state = "rod_empty"
	var/depleted_description = "A spent fuel rod, inert."


/*************************************************************
 * Helper Procs
 *************************************************************/

/// Marks the rod as spent and updates appearance
/obj/item/rbmk/fuel_rod/proc/deplete_rod()
	active = FALSE
	icon_state = depleted_icon_state
	desc = depleted_description

/// Returns a standard zero-output payload
/obj/item/rbmk/fuel_rod/proc/get_zero_output()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0
	)


/*************************************************************
 * Rod Processing
 *************************************************************/

/// Process this rod for one reactor tick
/obj/item/rbmk/fuel_rod/proc/process_rod()

	// Inactive rods contribute nothing
	if (!active)
		return get_zero_output()

	// Spent rods become inert permanently
	if (fuel_amount <= 0)
		deplete_rod()
		return get_zero_output()

	// Burn fuel
	fuel_amount = max(0, fuel_amount - fuel_consumption)

	// If this tick emptied the rod, deplete it after output is produced.
	// This allows the final tick of fuel to still contribute.
	var/should_deplete_after_output = (fuel_amount <= 0)

	// Compute raw per-tick outputs
	var/rod_flux_output = reactivity * flux_multiplier
	var/rod_radiation_output = reactivity * radiation_multiplier
	var/rod_heat_output = reactivity * thermal_multiplier

	if (should_deplete_after_output)
		deplete_rod()

	return list(
		"flux" = rod_flux_output,
		"radiation" = rod_radiation_output,
		"heat" = rod_heat_output
	)
