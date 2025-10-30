/*************************************************************
 * RBMK Instability Module (Rod-Driven Revision)
 * - Converts flux, heat, and radiation into chaotic instability
 * - Weighted by live fuel rod multipliers and core synergy
 *************************************************************/

/// Updates overall instability based on reactor state and rods
/obj/machinery/rbmk/reactor/proc/update_instability()
	// --- Early out ---
	if (!running)
		return instability

	/*************************************************************
	 * Normalize Key Reactor Factors
	 *************************************************************/
	var/flux_ratio = flux / RBMK_SAFE_FLUX
	var/temperature_ratio = temperature / max_temp
	var/radiation_ratio = radiation / RBMK_SAFE_RADIATION

	// Weighted baseline — flux dominates, then temperature, then radiation
	var/calculated_instability = (flux_ratio * RBMK_FLUX_WEIGHT + temperature_ratio * RBMK_TEMP_WEIGHT + radiation_ratio * RBMK_RAD_WEIGHT) * 100


	/*************************************************************
	 * Rod Activity Influence
	 * - Each active rod contributes a base instability pulse
	 * - Multiplied by its own flux/thermal multipliers
	 *************************************************************/
	var/total_rod_influence = 0.0
	var/active_rod_count = 0

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(!fuel_rod || !fuel_rod.active)
			continue

		active_rod_count++
		total_rod_influence += ((fuel_rod.flux_multiplier + fuel_rod.thermal_multiplier) * fuel_rod.fuel_power)

	if(active_rod_count > 0)
		total_rod_influence /= active_rod_count
		calculated_instability += total_rod_influence * 50 // modest baseline addition

	/*************************************************************
	 * Synergy Spike: High Flux + High Temperature
	 * - Creates instability surges during runaway conditions
	 *************************************************************/
	if(flux > RBMK_SYNERGY_FLUX_THRESHOLD && temperature > (max_temp * RBMK_SYNERGY_TEMP_RATIO))
		calculated_instability *= RBMK_SYNERGY_MULT

	/*************************************************************
	 * Radiation "Kicker"
	 * - Pushes instability upward when radiation exceeds limits
	 *************************************************************/
	if(radiation > RBMK_RADIATION_KICKER_THRESHOLD)
		calculated_instability += RBMK_RADIATION_KICKER_BONUS

	/*************************************************************
	 * Control Rod Dampening
	 * - Deep insertion smooths instability buildup
	 *************************************************************/
	var/control_rod_effectiveness = 1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX)
	if(control_rod_effectiveness < 0)
		control_rod_effectiveness = 0
	calculated_instability *= (0.5 + control_rod_effectiveness * 0.5)

	/*************************************************************
	 * Passive Stabilization via Coolant Pressure
	 * - High coolant pressure slightly reduces instability
	 *************************************************************/
	if(pressure > RBMK_PRESSURE_WARNING)
		var/pressure_ratio = min(pressure / RBMK_PRESSURE_CRITICAL, 2)
		calculated_instability /= (1 + (pressure_ratio * 0.15))

	/*************************************************************
	 * Clamp and Apply
	 *************************************************************/
	instability = clamp(calculated_instability, 0, RBMK_INSTABILITY_MAX)
	return instability
