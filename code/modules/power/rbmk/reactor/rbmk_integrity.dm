/obj/machinery/rbmk/reactor/proc/apply_integrity_damage(damage_amount, failure_reason, seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS, damage_cap_per_second = RBMK_INTEGRITY_DAMAGE_CAP_PER_SECOND)
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

	if(damage_amount <= 0)
		return

	var/old_integrity = reactor_integrity
	var/damage_cap = max(damage_cap_per_second * seconds_per_tick, 0)
	var/applied_damage = min(damage_amount, damage_cap)
	if(applied_damage <= 0)
		return

	reactor_integrity = max(reactor_integrity - applied_damage, 0)
	last_integrity_damage += old_integrity - reactor_integrity
	handle_integrity_damage_warning(old_integrity, failure_reason)

	if(reactor_integrity <= 0)
		trigger_meltdown(failure_reason)


/obj/machinery/rbmk/reactor/proc/handle_integrity_damage_warning(old_integrity, damage_reason)
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

	var/max_integrity = max(max_reactor_integrity, 1)
	var/old_percent = (old_integrity / max_integrity) * 100
	var/new_percent = (reactor_integrity / max_integrity) * 100
	if(new_percent >= old_percent)
		return

	if(!integrity_warning_started)
		integrity_warning_started = TRUE
		send_integrity_warning("RBMK casing integrity is degrading at [get_area_name(src)]. Cause: [damage_reason].", FALSE)

	var/warning_threshold = 0
	if(old_percent > 10 && new_percent <= 10)
		warning_threshold = 10
	else if(old_percent > 25 && new_percent <= 25)
		warning_threshold = 25
	else if(old_percent > 50 && new_percent <= 50)
		warning_threshold = 50
	else if(old_percent > 75 && new_percent <= 75)
		warning_threshold = 75

	if(!warning_threshold)
		return

	send_integrity_warning("RBMK casing integrity has fallen below [warning_threshold]% at [get_area_name(src)]. Immediate engineering response required.", warning_threshold <= RBMK_INTEGRITY_GLOBAL_WARNING_THRESHOLD)


/obj/machinery/rbmk/reactor/proc/send_integrity_warning(message, stationwide = FALSE)
	if(!message)
		return

	visible_message(span_warning("[src] emits a sharp structural integrity alarm!"))
	playsound(src, SFX_SM_DELAM, 85, FALSE, 40, 30, falloff_distance = 10)
	rbmk_engineering_alert(message)

	if(!stationwide)
		return

	priority_announce(
		message,
		"RBMK Reactor Integrity Alert",
		'sound/misc/airraid.ogg'
	)


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

			apply_integrity_damage(
				cooldown_damage * process_scale,
				"Core failure during cooldown",
				seconds_per_tick,
				RBMK_INTEGRITY_COOLDOWN_DAMAGE_CAP_PER_SECOND
			)

		return

	temperature_excess = max(0, temperature - temp_stress_threshold)

	if(temperature_excess > 0)
		total_damage += temperature_excess / 850

		// Damage ramps up hard once the core gets deep into the red.
		if(temperature > high_temp_damage_threshold)
			total_damage += (temperature - high_temp_damage_threshold) / 300

	if(total_damage <= 0)
		return

	apply_integrity_damage(total_damage * process_scale, "Core breach: Thermal overload!", seconds_per_tick)
