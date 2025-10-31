/*************************************************************
 * RBMK Instability Module (Stable-Core Revision)
 * - Converts flux, heat, and radiation into chaotic instability
 * - Uses logarithmic scaling for smoother buildup
 * - Supports passive self-stabilization from coolant and rods
 *************************************************************/

/// Updates overall instability based on reactor state and rods
/obj/machinery/rbmk/reactor/proc/update_instability()
	if(!running)
		return instability

	/*************************************************************
	 * Normalized Ratios (bounded for safety)
	 *************************************************************/
	var/flux_ratio        = clamp(flux / RBMK_SAFE_FLUX, 0, 4)
	var/temperature_ratio = clamp(temperature / max_temp, 0, 2)
	var/radiation_ratio   = clamp(radiation / RBMK_SAFE_RADIATION, 0, 3)

	/*************************************************************
	 * Base Instability Curve
	 * - Logarithmic weighting gives smooth ramp at low values
	 * - Flux dominates, temperature secondary, radiation minor
	 *************************************************************/
	var/base_flux_component = log(1 + flux_ratio * 2) * 45
	var/base_temp_component = log(1 + temperature_ratio * 2) * 30
	var/base_rad_component  = log(1 + radiation_ratio * 1.5) * 15

	var/calculated_instability = base_flux_component + base_temp_component + base_rad_component

	/*************************************************************
	 * Rod Activity Influence
	 * - Adds small chaos based on total rod reactivity
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
		calculated_instability += total_rod_influence * 35 // less extreme than before

	/*************************************************************
	 * Synergy Spike
	 * - True runaway only when both flux and temperature are excessive
	 *************************************************************/
	if(flux > RBMK_SYNERGY_FLUX_THRESHOLD && temperature > (max_temp * RBMK_SYNERGY_TEMP_RATIO))
		var/surge_strength = ((flux / RBMK_SYNERGY_FLUX_THRESHOLD) + (temperature / max_temp)) / 2
		calculated_instability *= 1 + (surge_strength * 0.4) // softer than before, scales dynamically

	/*************************************************************
	 * Radiation “Kicker”
	 * - Only contributes significant effect when truly over limit
	 *************************************************************/
	if(radiation > (RBMK_RADIATION_KICKER_THRESHOLD * 1.25))
		var/kick_strength = (radiation / RBMK_RADIATION_KICKER_THRESHOLD) - 1
		calculated_instability += (kick_strength * 25)

	/*************************************************************
	 * Control Rod Dampening
	 * - Deep insertion strongly suppresses chaos buildup
	 *************************************************************/
	var/rod_insertion_ratio = clamp(control_rod_depth / RBMK_CONTROL_ROD_MAX, 0, 1)
	var/rod_dampen_factor = 0.4 + (1 - rod_insertion_ratio) * 0.6 // 0.4 fully inserted, 1 fully withdrawn
	calculated_instability *= rod_dampen_factor

	/*************************************************************
	 * Coolant Stabilization
	 * - Pressure and coolant performance smooth the noise
	 *************************************************************/
	if(pressure > RBMK_PRESSURE_WARNING)
		var/pressure_ratio = clamp(pressure / RBMK_PRESSURE_CRITICAL, 0, 2)
		calculated_instability /= (1 + (pressure_ratio * 0.2))

	/*************************************************************
	 * Mild Recovery if Conditions Improve
	 * - Prevents “stuck” high instability when reactor stabilizes
	 *************************************************************/
	if(flux < RBMK_SAFE_FLUX && temperature < (max_temp * 0.7))
		calculated_instability = max(calculated_instability - 5, 0)

	/*************************************************************
	 * Clamp and Apply
	 *************************************************************/
	instability = clamp(calculated_instability, 0, RBMK_INSTABILITY_MAX)
	return instability
