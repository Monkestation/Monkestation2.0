/*************************************************************
 * RBMK Integrity Module — Canonical V1
 * -----------------------------------------------------------
 * Integrity responds ONLY to:
 *   - Temperature overstress
 *   - Pressure overstress
 *   - Flux overstress (minor effect)
 *   - Mechanical stress from installed rod count
 *
 * Design rules:
 * - Void coefficient does NOT directly damage the core
 * - Tritium does NOT directly damage the core
 * - Cooldown while overheated can still damage the shell
 *************************************************************/


/*************************************************************
 * Integrity Update
 *************************************************************/

/// Applies structural wear based on reactor operating conditions
/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()

	/************************************************
	 * 1. Hard exit
	 ************************************************/
	if (meltdown_in_progress || reactor_integrity <= 0)
		return


	/************************************************
	 * 2. Non-running cooldown damage
	 * If the reactor is no longer reacting but remains very hot,
	 * the shell may continue to take slow thermal damage.
	 ************************************************/
	if (!running)
		if (temperature > RBMK_AMBIENT_TEMP + 20)
			var/cooldown_damage = 0.003

			// Extremely hot shutdowns should be worse than mild ones
			if (temperature > RBMK_TEMP_STRESS_THRESHOLD)
				cooldown_damage += (temperature - RBMK_TEMP_STRESS_THRESHOLD) / 50000

			reactor_integrity = max(reactor_integrity - cooldown_damage, 0)

			if (reactor_integrity <= 0)
				trigger_meltdown("Core failure during cooldown")

		return


	/************************************************
	 * 3. Stress collection
	 ************************************************/
	var/temperature_excess = max(0, temperature - RBMK_TEMP_STRESS_THRESHOLD)
	var/pressure_excess = max(0, pressure - RBMK_PRESSURE_WARNING)
	var/flux_excess = max(0, flux - RBMK_FLUX_STRESS_THRESHOLD)
	var/rod_count = length(normal_slots) + length(special_slots)


	/************************************************
	 * 4. Damage calculation
	 ************************************************/
	var/total_damage = 0.0

	// Temperature overstress
	if (temperature_excess > 0)
		total_damage += temperature_excess / 850

		// Near-failure acceleration
		if (temperature > RBMK_MAX_TEMP * 0.92)
			total_damage += (temperature - (RBMK_MAX_TEMP * 0.92)) / 300

	// Pressure overstress
	if (pressure_excess > 0)
		total_damage += pressure_excess / 1700

		// Deep-red pressure zone
		if (pressure > RBMK_PRESSURE_CRITICAL)
			total_damage += (pressure - RBMK_PRESSURE_CRITICAL) / 1000

	// Flux overstress (minor contributor)
	if (flux_excess > 0)
		total_damage += flux_excess / 2000

		if (flux > RBMK_FLUX_HIGH_THRESHOLD)
			total_damage += (flux - RBMK_FLUX_HIGH_THRESHOLD) / 1400

	// Mechanical stress from installed rods
	total_damage += rod_count * 0.0008


	/************************************************
	 * 5. Apply damage
	 ************************************************/
	if (total_damage > 0)
		reactor_integrity = max(reactor_integrity - total_damage, 0)

		if (reactor_integrity <= 0)
			trigger_meltdown("Core breach: Temperature / pressure overload!")
