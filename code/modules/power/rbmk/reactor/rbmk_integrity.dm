/obj/machinery/rbmk/reactor/proc/update_reactor_integrity(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

	var/temp_stress_threshold = get_effective_temp_stress_threshold()
	var/high_temp_damage_threshold = get_effective_temp_damage_threshold()
	var/process_scale = seconds_per_tick / RBMK_MACHINERY_PROCESS_SECONDS
	var/temperature_excess
	var/total_damage = 0

	// A hot core can still keep chewing itself up after shutdown.
	if(!running)
		if(temperature > RBMK_AMBIENT_TEMP + 20)
			var/cooldown_damage = 0.003

			if(temperature > temp_stress_threshold)
				cooldown_damage += (temperature - temp_stress_threshold) / 50000

			reactor_integrity = max(reactor_integrity - (cooldown_damage * process_scale), 0)

			if(reactor_integrity <= 0)
				trigger_meltdown("Core failure during cooldown")

		return

	temperature_excess = max(0, temperature - temp_stress_threshold)

	if(temperature_excess > 0)
		total_damage += temperature_excess / 850

		// Damage ramps up hard once the core gets deep into the red.
		if(temperature > high_temp_damage_threshold)
			total_damage += (temperature - high_temp_damage_threshold) / 300

	var/flux_excess = max(0, flux - RBMK_FLUX_STRESS_THRESHOLD)
	if(flux_excess > 0)
		total_damage += flux_excess / 80

		if(flux > RBMK_FLUX_HIGH_THRESHOLD)
			total_damage += (flux - RBMK_FLUX_HIGH_THRESHOLD) / 35

	if(total_damage <= 0)
		return

	reactor_integrity = max(reactor_integrity - (total_damage * process_scale), 0)

	if(reactor_integrity <= 0)
		trigger_meltdown("Core breach: Thermal overload!")
