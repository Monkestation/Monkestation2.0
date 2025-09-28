// rbmk_stability.dm
// Handles instability calculations (flux + temperature + radiation → instability)

/obj/machinery/rbmk/reactor/proc/update_instability()
	// --- Base normalized factors ---
	var/flux_factor = flux / 100                // baseline safe flux
	var/temp_factor = temperature / max_temp    // normalized temperature
	var/rad_factor  = radiation / 50            // radiation normalized

	// --- Weighted instability ---
	// Flux has the strongest effect, temp second, radiation third
	instability = (flux_factor * 0.5 + temp_factor * 0.35 + rad_factor * 0.15) * 100

	// --- Synergy danger spike ---
	if (flux > 100 && temperature > (max_temp * 0.7))
		instability *= 1.5   // flux/temp runaway combo

	// Radiation hazard kicker
	if (radiation > 50)
		instability += 10

	// --- Influence from rod multipliers ---
	// Plasma and Supermatter rods push multipliers into flux_mult/thermal_mult
	var/multiplier = 1
	for (var/obj/item/rbmk/fuel_rod/R in normal_slots + special_slots)
		if (!R || !R.active)
			continue
		// Check if rod contributed multipliers
		var/contrib = R.process_rod()
		if ("flux_mult" in contrib)
			multiplier *= contrib["flux_mult"]
		if ("thermal_mult" in contrib)
			multiplier *= contrib["thermal_mult"]

	// Apply multiplier
	instability *= multiplier

	// --- Clamp to sane range ---
	instability = clamp(instability, 0, 500)   // expanded upper bound for chaos rods

	return instability
