/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

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

	var/temperature_excess = max(0, temperature - RBMK_TEMP_STRESS_THRESHOLD)
	var/pressure_excess = max(0, pressure - RBMK_PRESSURE_WARNING)

	var/total_damage = 0.0

	if(temperature_excess > 0)
		total_damage += temperature_excess / 850

		// Damage ramps up hard once the core is deep into the red.
		if(temperature > RBMK_MAX_TEMP * 0.92)
			total_damage += (temperature - (RBMK_MAX_TEMP * 0.92)) / 300

	if(pressure_excess > 0)
		total_damage += pressure_excess / 1700

		if(pressure > RBMK_PRESSURE_CRITICAL)
			total_damage += (pressure - RBMK_PRESSURE_CRITICAL) / 1000

	if(total_damage > 0)
		reactor_integrity = max(reactor_integrity - total_damage, 0)

		if(reactor_integrity <= 0)
			trigger_meltdown("Core breach: Temperature / pressure overload!")
