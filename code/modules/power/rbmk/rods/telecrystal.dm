/************************************************************
 * Telecrystal Fuel Rod
 * - Absorbs reactor heat and radiation to charge with unstable bluespace energy.
 * - Fully charges under high stress, then passively boosts flux output.
 ************************************************************/

/// Telecrystal Fuel Rod
/obj/item/rbmk/fuel_rod/telecrystal
	name = "Telecrystal Fuel Rod"
	desc = "A crystalline rod that absorbs heat and radiation to charge with unstable bluespace energy."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "tc_empty"
	depleted_icon_state = "tc_full"
	depleted_description = "A cracked, inert telecrystal rod."

	// Core behavior
	fuel_amount = 1e9                       // effectively infinite
	depletion_rate = 0
	base_heat_output = 0
	base_flux_output = 0
	base_radiation_output = 0

	rod_type = "telecrystal"
	rod_color = "cyan"

	// Charging parameters
	charge_progress = 0
	charge_max = 500
	charged = FALSE
	usable = TRUE

	// Passive modifiers
	thermal_multiplier = 1.0
	flux_multiplier = 1.05
	radiation_multiplier = 1.0
	active = TRUE


/************************************************************
 * Telecrystal Rod Processing Logic
 ************************************************************/

/// Charges proportionally to core temperature and flux intensity
/obj/item/rbmk/fuel_rod/telecrystal/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
	if (!active || !usable)
		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0,
			"thermal_mult" = 1.0,
			"flux_mult" = 1.0
		)

	// Fully charged rods stabilize and provide passive flux modulation
	if (charged)
		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0,
			"flux_mult" = 1.1,
			"thermal_mult" = 1.0
		)

	// --- Charging behavior ---
	var/charge_rate = 0
	if (reactor_temperature >= 10000)
		charge_rate = 3
	else if (reactor_temperature >= 5000)
		charge_rate = 2
	else if (reactor_temperature >= 2000)
		charge_rate = 1

	// Apply charge progression
	if (charge_rate > 0)
		charge_progress = min(charge_max, charge_progress + charge_rate)

	// Completion check
	if (charge_progress >= charge_max && !charged)
		charged = TRUE
		icon_state = "rod_tc_full"
		// Optional: could send a subtle reactor console warning or chat notice here

	// Emits mild flux proportional to charge buildup
	var/flux_output = (charge_progress / charge_max) * 0.5

	return list(
		"heat" = 0,
		"flux" = flux_output,
		"radiation" = 0,
		"thermal_mult" = thermal_multiplier,
		"flux_mult" = flux_multiplier
	)
