/*************************************************************
 * RBMK Instability Module (Balanced Stable-Core Revision)
 *************************************************************/

/// Updates overall instability with new balance curves
/obj/machinery/rbmk/reactor/proc/update_instability()
	if(!running)
		return instability

	/*************************************************************
	 * Normalized Ratios
	 *************************************************************/
	var/flux_ratio        = clamp(flux / RBMK_SAFE_FLUX, 0, 4)
	var/temperature_ratio = clamp(temperature / max_temp, 0, 2)
	var/radiation_ratio   = clamp(radiation / RBMK_SAFE_RADIATION, 0, 3)

	/*************************************************************
	 * Balanced Base Instability Curve
	 *************************************************************/
	var/base_flux_component = log(1 + flux_ratio * 1.5) * 25
	var/base_temp_component = log(1 + temperature_ratio * 1.2) * 18
	var/base_rad_component  = log(1 + radiation_ratio) * 10

	var/calculated_instability = base_flux_component + base_temp_component + base_rad_component

	/*************************************************************
	 * Rod Influence — Reduced
	 *************************************************************/
	var/total_rod_influence = 0.0
	var/rod_count = 0

	for(var/obj/item/rbmk/fuel_rod/rod in (normal_slots + special_slots))
		if(!rod || !rod.active)
			continue
		rod_count++
		total_rod_influence += (rod.fuel_power * (rod.flux_multiplier + rod.thermal_multiplier))

	if(rod_count > 0)
		total_rod_influence /= rod_count
		calculated_instability += total_rod_influence * 18  // (was 35)

	/*************************************************************
	 * Synergy — unchanged
	 *************************************************************/
	if(flux > RBMK_SYNERGY_FLUX_THRESHOLD && temperature > (max_temp * RBMK_SYNERGY_TEMP_RATIO))
		var/surge = ((flux / RBMK_SYNERGY_FLUX_THRESHOLD) + (temperature / max_temp)) / 2
		calculated_instability *= 1 + (surge * 0.4)

	/*************************************************************
	 * Radiation kicker — unchanged
	 *************************************************************/
	if(radiation > (RBMK_RADIATION_KICKER_THRESHOLD * 1.25))
		var/kick = (radiation / RBMK_RADIATION_KICKER_THRESHOLD) - 1
		calculated_instability += (kick * 25)

	/*************************************************************
	 * Rod Dampening
	 *************************************************************/
	var/rod_depth_ratio = clamp(control_rod_depth / RBMK_CONTROL_ROD_MAX, 0, 1)
	calculated_instability *= (0.4 + (1 - rod_depth_ratio) * 0.6)

	/*************************************************************
	 * Coolant Dampening — increased
	 *************************************************************/
	if(pressure > RBMK_PRESSURE_WARNING)
		var/pr = clamp(pressure / RBMK_PRESSURE_CRITICAL, 0, 2)
		calculated_instability /= (1 + pr * 0.35)

	/*************************************************************
	 * Mild Stability Recovery
	 *************************************************************/
	if(flux < RBMK_SAFE_FLUX && temperature < (max_temp * 0.7))
		calculated_instability = max(0, calculated_instability - 5)

	/*************************************************************
	 * Clamp & Apply
	 *************************************************************/
	instability = clamp(calculated_instability, 0, RBMK_INSTABILITY_MAX)
	return instability
