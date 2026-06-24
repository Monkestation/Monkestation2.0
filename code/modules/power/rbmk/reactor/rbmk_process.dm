/obj/machinery/rbmk/reactor/proc/rbmk_decay_process()
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)
	thermal_output = 0
	last_tick_flux = flux
	last_tick_temp_gain = 0


/obj/machinery/rbmk/reactor/proc/rbmk_update_control_rods()
	if(scrammed && control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		actual_control_rod_depth = RBMK_CONTROL_ROD_MAX
		return

	var/step_size = control_rod_step
	step_size = max(step_size, 1)
	step_size = max(round(step_size * 0.35), 1) * 2

	if(actual_control_rod_depth < control_rod_depth)
		actual_control_rod_depth = min(actual_control_rod_depth + step_size, control_rod_depth)
	else if(actual_control_rod_depth > control_rod_depth)
		actual_control_rod_depth = max(actual_control_rod_depth - step_size, control_rod_depth)

	actual_control_rod_depth = clamp(actual_control_rod_depth, 0, RBMK_CONTROL_ROD_MAX)


/obj/machinery/rbmk/reactor/proc/update_rod_motion_state()
	var/rods_at_target = (actual_control_rod_depth == control_rod_depth)

	if(!rods_at_target)
		rod_motion_in_progress = TRUE
		return

	if(rod_motion_in_progress)
		rod_motion_in_progress = FALSE
		playsound(src, 'sound/rbmk/switch2.ogg', 55, TRUE)


/obj/machinery/rbmk/reactor/proc/try_play_startup_sequence()
	if(startup_sequence_played)
		return

	if(meltdown_in_progress || scrammed)
		return

	if(!has_fuel_rods())
		return

	if(previous_control_rod_depth >= RBMK_CONTROL_ROD_MAX && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		startup_sequence_played = TRUE
		playsound(src, 'sound/rbmk/startup.ogg', 80, FALSE)
		addtimer(CALLBACK(src, PROC_REF(play_startup_stage_two)), 3 SECONDS, TIMER_DELETE_ME)


/obj/machinery/rbmk/reactor/proc/play_startup_stage_two()
	if(QDELETED(src))
		return

	if(meltdown_in_progress)
		return

	playsound(src, 'sound/rbmk/startup2.ogg', 90, FALSE)


/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if(!coolant_internal)
		return

	if(coolant_internal.total_moles() <= 0)
		return

	var/coolant_heat_capacity = coolant_internal.heat_capacity()
	if(coolant_heat_capacity <= 0)
		return

	var/commanded_flow_ratio = CLAMP01(inlet_rate / max(RBMK_INLET_RATE_MAX, 1))
	var/exchange_ratio = max(commanded_flow_ratio, RBMK_COOLANT_STAGNANT_FLOW_RATIO)

	if(!inlet_open && !outlet_open)
		exchange_ratio = RBMK_COOLANT_STAGNANT_FLOW_RATIO
	else if(!inlet_open || !outlet_open)
		exchange_ratio = max(exchange_ratio * RBMK_COOLANT_ONE_PORT_FLOW_MULT, RBMK_COOLANT_STAGNANT_FLOW_RATIO)

	var/exchange_coefficient = RBMK_COOLANT_EXCHANGE_COEFFICIENT + (exchange_ratio * RBMK_COOLANT_EXCHANGE_FLOW_BONUS)
	exchange_coefficient = CLAMP01(exchange_coefficient)

	var/temperature_delta = (temperature - coolant_internal.temperature) * exchange_coefficient
	if(abs(temperature_delta) < 0.1)
		return

	var/energy_to_coolant = CALCULATE_CONDUCTION_ENERGY(temperature_delta, coolant_heat_capacity, RBMK_CORE_HEAT_CAPACITY)

	var/coolant_temperature_change = energy_to_coolant / coolant_heat_capacity
	var/core_temperature_change = energy_to_coolant / RBMK_CORE_HEAT_CAPACITY

	coolant_temperature_change = clamp(coolant_temperature_change, -RBMK_COOLANT_MAX_GAS_TEMP_CHANGE, RBMK_COOLANT_MAX_GAS_TEMP_CHANGE)
	core_temperature_change = clamp(core_temperature_change, -RBMK_COOLANT_MAX_CORE_TEMP_CHANGE, RBMK_COOLANT_MAX_CORE_TEMP_CHANGE)

	coolant_internal.temperature = max(coolant_internal.temperature + coolant_temperature_change, TCMB)
	temperature = max(temperature - core_temperature_change, RBMK_AMBIENT_TEMP)


/obj/machinery/rbmk/reactor/proc/rbmk_sample_reactor_temperature()
	if(!reactor_temperature_history)
		reactor_temperature_history = list()

	reactor_temperature_history.Add(temperature)
	if(reactor_temperature_history.len > 60)
		reactor_temperature_history.Cut(1, 2)


/obj/machinery/rbmk/reactor/proc/rbmk_update_pressure()
	if(!coolant_internal)
		pressure = 0
		return

	pressure = clamp(coolant_internal.return_pressure(), 0, RBMK_PRESSURE_EXTREME)

	if(inlet_open || outlet_open)
		wake_coolant_ports()


/obj/machinery/rbmk/reactor/proc/emit_real_radiation()
	if(meltdown_in_progress || !running)
		return

	if(actual_control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		return
	if(radiation <= 0 || flux <= 0)
		return

	var/integrity_ratio = CLAMP01(reactor_integrity / max(max_reactor_integrity, 1))
	var/load_ratio = CLAMP01(flux / max(RBMK_MAX_FLUX, 1))

	var/effective_rad_output = radiation * (0.15 + (load_ratio * 0.85))
	effective_rad_output = min(effective_rad_output, RBMK_MAX_RADIATION)

	var/rad_threshold
	if(integrity_ratio <= 0)
		rad_threshold = effective_rad_output ? 0 : 1
	else if(integrity_ratio >= 1)
		rad_threshold = max(0.45, 1 - (effective_rad_output / RBMK_MAX_RADIATION))
	else
		rad_threshold = max(
			0.20,
			(1 - (effective_rad_output / RBMK_MAX_RADIATION)) ** ((1 / integrity_ratio) ** 1.2)
		)

	var/rad_chance = 2 + (load_ratio * 8) + ((1 - integrity_ratio) * 20)
	var/rad_range = clamp(round(2 + (load_ratio * 3)), 2, 5)
	var/rad_intensity = max(1, round(effective_rad_output * 0.18))

	radiation_pulse(
		src,
		rad_range,
		rad_threshold,
		rad_chance,
		0,
		rad_intensity,
		TRUE
	)


/obj/machinery/rbmk/reactor/proc/try_spawn_flux_anomaly()
	if(meltdown_in_progress || !running || !has_active_fuel_rods())
		return

	if(flux < RBMK_FLUX_ANOMALY_THRESHOLD)
		return

	var/flux_anomaly_ratio = CLAMP01((flux - RBMK_FLUX_ANOMALY_THRESHOLD) / max(RBMK_MAX_FLUX - RBMK_FLUX_ANOMALY_THRESHOLD, 1))
	var/current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_LOW

	if(flux_anomaly_ratio >= 0.75)
		current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_EXTREME
	else if(flux_anomaly_ratio >= 0.35)
		current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_HIGH

	if(last_flux_anomaly_spawn + current_cooldown > world.time)
		return

	var/spawn_chance = round(8 + (flux_anomaly_ratio * 27))
	var/anomaly_range = round(4 + (flux_anomaly_ratio * 7))

	if(!prob(spawn_chance))
		return

	var/turf/reactor_turf = get_turf(src)
	if(!reactor_turf)
		return

	var/list/valid_turfs = list()

	for(var/turf/open/open_turf in orange(anomaly_range, reactor_turf))
		if(open_turf.density)
			continue

		valid_turfs += open_turf

	if(!length(valid_turfs))
		return

	var/turf/spawn_turf = pick(valid_turfs)

	last_flux_anomaly_spawn = world.time
	flux_anomaly_cooldown = current_cooldown

	new /obj/effect/anomaly/flux(spawn_turf, rand(25 SECONDS, 35 SECONDS), FALSE, FLUX_NO_EMP)

	visible_message(span_warning("A harmonic flux distortion forms near [src]!"))


/obj/machinery/rbmk/reactor/proc/start_meltdown_fallout()
	if(rbmk_fallout_active)
		return

	rbmk_fallout_active = TRUE
	rbmk_fallout_radius = 0
	rbmk_fallout_next_spread = world.time

	GLOB.rbmk_fallout_reactors |= src

	if(!(locate(/datum/weather/rbmk_fallout) in SSweather.processing))
		SSweather.run_weather(/datum/weather/rbmk_fallout)


/obj/machinery/rbmk/reactor/proc/process_meltdown_fallout()
	if(!rbmk_fallout_active)
		return

	if(world.time < rbmk_fallout_next_spread)
		return

	rbmk_fallout_radius = min(rbmk_fallout_radius + RBMK_FALLOUT_RADIUS_STEP, RBMK_FALLOUT_MAX_RADIUS)
	rbmk_fallout_next_spread = world.time + RBMK_FALLOUT_SPREAD_INTERVAL


/obj/machinery/rbmk/reactor/proc/check_hard_meltdown_conditions()
	if(meltdown_in_progress)
		return

	if(reactor_integrity <= 0)
		trigger_meltdown("Core structural integrity reached zero")


/obj/machinery/rbmk/reactor/process()
	if(meltdown_in_progress || reactor_integrity <= 0)
		process_meltdown_fallout()
		reset_reaction_state()
		rod_motion_in_progress = FALSE
		update_reactor_icon()
		update_linked_consoles()
		previous_control_rod_depth = control_rod_depth
		return

	check_supermatter_rod_activation()

	if(supermatter_cascade_active)
		update_linked_consoles()
		return

	rbmk_update_control_rods()
	update_rod_motion_state()

	if(!has_fuel_rods())
		reset_reaction_state()
		startup_sequence_played = FALSE

		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant()
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		previous_control_rod_depth = control_rod_depth
		return

	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		scrammed = FALSE

	try_play_startup_sequence()

	var/total_flux = 0
	var/total_radiation = 0
	var/total_heat = 0
	var/active_rods = 0

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(!fuel_rod?.active)
			continue

		var/list/rod_output = fuel_rod.process_rod()
		if(!islist(rod_output))
			continue

		total_flux += rod_output["flux"] || 0
		total_radiation += rod_output["radiation"] || 0
		total_heat += rod_output["heat"] || 0
		active_rods++

	last_tick_rod_count = active_rods

	if(active_rods <= 0 || scrammed)
		running = FALSE

		rbmk_decay_process()
		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant()
		rbmk_sample_reactor_temperature()
		check_decay_meltdown()
		check_hard_meltdown_conditions()

		update_reactor_icon()
		update_linked_consoles()

		if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
			startup_sequence_played = FALSE

		previous_control_rod_depth = control_rod_depth
		return

	running = TRUE

	var/control_ratio = CLAMP01(actual_control_rod_depth / RBMK_CONTROL_ROD_MAX)
	var/flux_control_multiplier = CLAMP01(1 - control_ratio)
	var/heat_control_multiplier = CLAMP01(1 - (control_ratio ** 1.35))
	var/radiation_control_multiplier = CLAMP01(1 - (control_ratio ** 1.15))

	total_flux *= flux_control_multiplier
	total_heat *= heat_control_multiplier
	total_radiation *= radiation_control_multiplier

	flux = clamp(total_flux * RBMK_FLUX_GAIN, 0, RBMK_MAX_FLUX)

	var/generated_heat = total_heat + (flux * RBMK_TEMP_GAIN_PER_TICK)
	temperature += generated_heat

	thermal_output = generated_heat
	last_tick_flux = flux
	last_tick_temp_gain = generated_heat

	var/extra_void_coefficient = update_void_coefficient()
	flux = clamp(flux * (1 + extra_void_coefficient), 0, RBMK_MAX_FLUX)

	try_spawn_flux_anomaly()

	radiation = clamp(
		total_radiation + (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
		0,
		RBMK_MAX_RADIATION
	)

	emit_real_radiation()

	rbmk_coolant_exchange()

	if(coolant_internal)
		var/tritium_delta = flux * (RBMK_TRITIUM_RATE * 400)
		if(tritium_delta > 0)
			coolant_internal.assert_gases(/datum/gas/tritium)
			coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta

	rbmk_update_pressure()
	rbmk_sample_coolant()
	rbmk_sample_reactor_temperature()

	update_reactor_integrity()
	check_hard_meltdown_conditions()

	update_reactor_icon()
	update_linked_consoles()

	if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		startup_sequence_played = FALSE

	previous_control_rod_depth = control_rod_depth
