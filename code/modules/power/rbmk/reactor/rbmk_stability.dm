// rbmk_stability.dm
// Handles instability calculations (flux + temperature + radiation → instability)

/obj/machinery/rbmk/reactor/proc/update_instability()
	// --- Base normalized factors ---
	var/flux_factor = flux / RBMK_SAFE_FLUX
	var/temp_factor = temperature / max_temp
	var/rad_factor  = radiation / RBMK_SAFE_RADIATION

	// --- Weighted instability ---
	// Flux has the strongest effect, temp second, radiation third
	instability = (flux_factor * RBMK_FLUX_WEIGHT + temp_factor * RBMK_TEMP_WEIGHT + rad_factor * RBMK_RAD_WEIGHT) * 100

	// --- Synergy danger spike ---
	if (flux > RBMK_SYNERGY_FLUX_THRESHOLD && temperature > (max_temp * RBMK_SYNERGY_TEMP_RATIO))
		instability *= RBMK_SYNERGY_MULT

	// Radiation hazard kicker
	if (radiation > RBMK_RADIATION_KICKER_THRESHOLD)
		instability += RBMK_RADIATION_KICKER_BONUS

	// --- Influence from rod multipliers ---
	var/multiplier = 1
	for (var/obj/item/rbmk/fuel_rod/R in normal_slots + special_slots)
		if (!R || !R.active)
			continue
		var/contrib = R.process_rod()
		if ("flux_mult" in contrib)
			multiplier *= contrib["flux_mult"]
		if ("thermal_mult" in contrib)
			multiplier *= contrib["thermal_mult"]

	// Apply multiplier
	instability *= multiplier

	// --- Clamp to sane range ---
	instability = clamp(instability, 0, RBMK_INSTABILITY_MAX)

	return instability
