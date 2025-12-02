/*************************************************************
 * RBMK Integrity Module (Balanced 2025 Revision)
 *************************************************************/

/// Applies structural damage from stress conditions
/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()

	if(reactor_integrity <= 0)
		return

	// Off or fully inserted rods → minimal wear
	if(!running || control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		if(temperature > RBMK_AMBIENT_TEMP + 25)
			reactor_integrity = max(reactor_integrity - 0.005, 0)
		return

	var/total_damage = 0.0

	/*************************************************************
	 * SAFE ZONE — no damage at all
	 *************************************************************/
	if( \
   	 	temperature < RBMK_TEMP_STRESS_THRESHOLD && \
    	flux < RBMK_FLUX_STRESS_THRESHOLD && \
    	instability < RBMK_INSTABILITY_THRESHOLD && \
    	pressure < RBMK_PRESSURE_WARNING \
)
		return


	/*************************************************************
	 * Temperature Damage
	 *************************************************************/
	if(temperature > RBMK_TEMP_STRESS_THRESHOLD)
		var/excess = temperature - RBMK_TEMP_STRESS_THRESHOLD
		total_damage += (excess / RBMK_TEMP_STRESS_DIVISOR) ** 1.15

	if(temperature > (max_temp * RBMK_TEMP_NEAR_MAX_RATIO))
		var/ne = temperature - (max_temp * RBMK_TEMP_NEAR_MAX_RATIO)
		total_damage += (ne / RBMK_TEMP_NEAR_MAX_DIVISOR) ** 1.3

	/*************************************************************
	 * Flux Damage
	 *************************************************************/
	if(flux > RBMK_FLUX_STRESS_THRESHOLD)
		var/fe = flux - RBMK_FLUX_STRESS_THRESHOLD
		total_damage += (fe / RBMK_FLUX_STRESS_DIVISOR) ** 1.15

	if(flux > RBMK_FLUX_HIGH_THRESHOLD)
		var/fh = flux - RBMK_FLUX_HIGH_THRESHOLD
		total_damage += (fh / RBMK_FLUX_HIGH_DIVISOR) ** 1.22

	/*************************************************************
	 * Instability Damage
	 *************************************************************/
	if(instability > RBMK_INSTABILITY_THRESHOLD)
		var/ie = instability - RBMK_INSTABILITY_THRESHOLD
		total_damage += (ie / RBMK_INSTABILITY_DIVISOR) ** 1.12

	/*************************************************************
	 * Pressure Damage
	 *************************************************************/
	if(pressure > RBMK_PRESSURE_WARNING)
		var/pe = pressure - RBMK_PRESSURE_WARNING
		total_damage += (pe / RBMK_PRESSURE_WARNING_DIVISOR) ** 1.12

	if(pressure > RBMK_PRESSURE_CRITICAL)
		var/pce = pressure - RBMK_PRESSURE_CRITICAL
		total_damage += (pce / RBMK_PRESSURE_CRITICAL_DIVISOR) ** 1.2

	if(pressure > RBMK_PRESSURE_EXTREME)
		var/pee = pressure - RBMK_PRESSURE_EXTREME
		total_damage += (pee / RBMK_PRESSURE_EXTREME_DIVISOR) ** 1.28

	/*************************************************************
	 * Rod Count Baseline — reduced
	 *************************************************************/
	var/rod_count = length(normal_slots) + length(special_slots)
	if(rod_count > 0)
		total_damage += rod_count * 0.001  // (was 0.0025)

	/*************************************************************
	 * APPLY DAMAGE
	 *************************************************************/
	if(total_damage > 0)
		reactor_integrity = max(reactor_integrity - total_damage, 0)

		if(reactor_integrity <= 0)
			trigger_meltdown("⚠ Reactor breached from combined overload!")

	/*************************************************************
	 * Repairable Flag
	 *************************************************************/
	repairable = ( \
    	temperature < (max_temp * RBMK_REPAIRABLE_TEMP_RATIO) && \
    	flux < RBMK_REPAIRABLE_FLUX_LIMIT && \
   		pressure < RBMK_REPAIRABLE_PRESSURE_LIMIT \
)

