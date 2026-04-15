/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

	var/high_temp_damage_threshold = decay_meltdown_threshold
	var/temperature_excess
	var/pressure_excess
	var/total_damage = 0

	// A hot core can still keep chewing itself up after shutdown.
	if(!running)
		if(temperature > RBMK_AMBIENT_TEMP + 20)
			var/cooldown_damage = 0.003

			if(temperature > RBMK_TEMP_STRESS_THRESHOLD)
				cooldown_damage += (temperature - RBMK_TEMP_STRESS_THRESHOLD) / 50000

			reactor_integrity = max(reactor_integrity - cooldown_damage, 0)

			if(reactor_integrity <= 0)
				trigger_meltdown("Core failure during cooldown")

		return

	temperature_excess = max(0, temperature - RBMK_TEMP_STRESS_THRESHOLD)
	pressure_excess = max(0, pressure - RBMK_PRESSURE_WARNING)

	if(temperature_excess > 0)
		total_damage += temperature_excess / 850

		// Damage ramps up hard once the core is deep into the red.
		if(temperature > high_temp_damage_threshold)
			total_damage += (temperature - high_temp_damage_threshold) / 300

	if(pressure_excess > 0)
		total_damage += pressure_excess / 1700

		if(pressure > RBMK_PRESSURE_CRITICAL)
			total_damage += (pressure - RBMK_PRESSURE_CRITICAL) / 1000

	if(total_damage <= 0)
		return

	reactor_integrity = max(reactor_integrity - total_damage, 0)

	if(reactor_integrity <= 0)
		trigger_meltdown("Core breach: Temperature / pressure overload!")
