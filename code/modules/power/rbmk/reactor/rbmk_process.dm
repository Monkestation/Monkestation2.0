/obj/machinery/rbmk/reactor/proc/rbmk_decay_process(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	flux = max(flux - (RBMK_FLUX_DECAY_PER_SECOND * seconds_per_tick), 0)
	radiation = max(radiation - (RBMK_RADIATION_DECAY_PER_SECOND * seconds_per_tick), 0)
	thermal_output = 0
	last_tick_flux = flux
	last_tick_base_flux = flux
	last_tick_void_flux_bonus = 0
	last_tick_temp_gain = 0


/obj/machinery/rbmk/reactor/proc/maintain_residual_radiation(list/all_fuel_rods)
	var/residual_rod_radiation = 0
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in all_fuel_rods)
		residual_rod_radiation += fuel_rod.get_residual_radiation_output()

	var/residual_floor = residual_rod_radiation * RBMK_RESIDUAL_RADIATION_MULTIPLIER
	residual_floor += temperature * RBMK_RADIATION_TEMP_MULT
	radiation = clamp(max(radiation, residual_floor), 0, RBMK_MAX_RADIATION)


/obj/machinery/rbmk/reactor/proc/rbmk_update_control_rods(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(scrammed && control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		actual_control_rod_depth = RBMK_CONTROL_ROD_MAX
		return

	var/step_size = control_rod_step * seconds_per_tick

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

	if(!has_active_fuel_rods())
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


/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	last_coolant_exchange_ratio = 0
	last_coolant_core_temp_change = 0
	last_coolant_temperature_change = 0

	if(!coolant_internal)
		return

	var/coolant_moles = coolant_internal.total_moles()
	if(coolant_moles <= 0)
		return

	var/coolant_heat_capacity = coolant_internal.heat_capacity()
	if(coolant_heat_capacity <= 0)
		return

	var/commanded_flow_ratio = inlet_open ? CLAMP01(inlet_rate / max(RBMK_INLET_RATE_MAX, 1)) : 0
	var/open_port_count = 0
	var/actual_flow_rate = 0
	if(inlet_open)
		open_port_count++
		actual_flow_rate += last_inlet_flow_rate
	if(outlet_open)
		open_port_count++
		actual_flow_rate += last_outlet_flow_rate

	var/actual_flow_ratio = CLAMP01(actual_flow_rate / max(RBMK_INLET_RATE_MAX * max(open_port_count, 1), 1))
	var/coolant_inventory_ratio = CLAMP01(coolant_moles / max(RBMK_COOLANT_EFFECTIVE_MOLES_TARGET, 1))
	var/minimum_exchange_ratio = RBMK_COOLANT_STAGNANT_FLOW_RATIO * max(coolant_inventory_ratio, 0.25)
	var/exchange_ratio = max(actual_flow_ratio, commanded_flow_ratio * 0.25)
	exchange_ratio *= 0.35 + (coolant_inventory_ratio * 0.65)
	exchange_ratio = max(exchange_ratio, minimum_exchange_ratio)

	if(!inlet_open && !outlet_open)
		exchange_ratio = minimum_exchange_ratio
	else if(!inlet_open || !outlet_open)
		exchange_ratio = max(exchange_ratio * RBMK_COOLANT_ONE_PORT_FLOW_MULT, minimum_exchange_ratio)

	var/process_scale = seconds_per_tick / RBMK_MACHINERY_PROCESS_SECONDS
	var/exchange_coefficient = RBMK_COOLANT_EXCHANGE_COEFFICIENT + (exchange_ratio * RBMK_COOLANT_EXCHANGE_FLOW_BONUS)
	exchange_coefficient *= 1 + rod_coolant_exchange_bonus
	exchange_coefficient = CLAMP01(exchange_coefficient)
	exchange_coefficient = 1 - ((1 - exchange_coefficient) ** process_scale)
	last_coolant_exchange_ratio = exchange_ratio

	var/temperature_delta = (temperature - coolant_internal.temperature) * exchange_coefficient
	if(abs(temperature_delta) < 0.1)
		return

	var/energy_to_coolant = CALCULATE_CONDUCTION_ENERGY(temperature_delta, coolant_heat_capacity, RBMK_CORE_HEAT_CAPACITY)

	var/max_gas_temp_change = RBMK_COOLANT_MAX_GAS_TEMP_CHANGE * process_scale
	var/max_core_temp_change = RBMK_COOLANT_MAX_CORE_TEMP_CHANGE * process_scale
	var/max_transfer_energy = min(
		max_gas_temp_change * coolant_heat_capacity,
		max_core_temp_change * RBMK_CORE_HEAT_CAPACITY
	)
	energy_to_coolant = clamp(energy_to_coolant, -max_transfer_energy, max_transfer_energy)

	// Derive both temperature changes from the same capped energy transfer so energy is conserved.
	var/coolant_temperature_change = energy_to_coolant / coolant_heat_capacity
	var/core_temperature_change = energy_to_coolant / RBMK_CORE_HEAT_CAPACITY

	last_coolant_temperature_change = coolant_temperature_change
	last_coolant_core_temp_change = core_temperature_change

	coolant_internal.temperature = max(coolant_internal.temperature + coolant_temperature_change, TCMB)
	temperature = max(temperature - core_temperature_change, RBMK_AMBIENT_TEMP)


/obj/machinery/rbmk/reactor/proc/rbmk_sample_reactor_temperature()
	if(!reactor_temperature_history)
		reactor_temperature_history = list()

	reactor_temperature_history.Add(temperature)
	if(reactor_temperature_history.len > 60)
		reactor_temperature_history.Cut(1, 2)


/obj/machinery/rbmk/reactor/proc/apply_pressure_damage(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(meltdown_in_progress || reactor_integrity <= 0)
		return

	if(pressure < RBMK_PRESSURE_WARNING)
		return

	var/process_scale = seconds_per_tick / RBMK_MACHINERY_PROCESS_SECONDS
	var/pressure_damage = (pressure - RBMK_PRESSURE_WARNING) / RBMK_PRESSURE_DAMAGE_DIVISOR

	if(pressure >= RBMK_PRESSURE_CRITICAL)
		pressure_damage += (pressure - RBMK_PRESSURE_CRITICAL) / RBMK_PRESSURE_CRITICAL_DAMAGE_DIVISOR

	if(pressure >= RBMK_PRESSURE_EXTREME)
		pressure_damage += RBMK_PRESSURE_EXTREME_DAMAGE_BONUS

	// Overpressure should be urgent, but never an instant random rupture.
	// Let it chew through integrity on a visible, repairable timer so engineers can SCRAM, vent, or weld.
	apply_integrity_damage(
		pressure_damage * process_scale,
		"Primary coolant pressure vessel failure",
		seconds_per_tick,
		RBMK_PRESSURE_INTEGRITY_DAMAGE_CAP_PER_SECOND
	)


/obj/machinery/rbmk/reactor/proc/rbmk_update_pressure(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(!coolant_internal)
		pressure = 0
		return

	pressure = max(coolant_internal.return_pressure(), 0)
	apply_pressure_damage(seconds_per_tick)

	if(inlet_open || outlet_open)
		wake_coolant_ports()


/obj/machinery/rbmk/reactor/proc/emit_real_radiation()
	if(meltdown_in_progress)
		return

	if(radiation <= 0)
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


/obj/machinery/rbmk/reactor/proc/try_spawn_flux_anomaly(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(meltdown_in_progress || !running || !has_active_fuel_rods())
		return

	if(flux < RBMK_FLUX_ANOMALY_THRESHOLD)
		return

	var/flux_anomaly_ratio = CLAMP01((flux - RBMK_FLUX_ANOMALY_THRESHOLD) / max(RBMK_MAX_FLUX - RBMK_FLUX_ANOMALY_THRESHOLD, 1))
	var/current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_LOW

	if(flux >= RBMK_FLUX_ANOMALY_EXTREME)
		current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_EXTREME
	else if(flux >= RBMK_FLUX_ANOMALY_HIGH)
		current_cooldown = RBMK_FLUX_ANOMALY_COOLDOWN_HIGH

	if(last_flux_anomaly_spawn + current_cooldown > world.time)
		return

	var/spawn_chance = round(8 + (flux_anomaly_ratio * 27))
	var/anomaly_range = round(4 + (flux_anomaly_ratio * 7))

	var/spawn_chance_rate = 1 - ((1 - (spawn_chance / 100)) ** (1 / RBMK_MACHINERY_PROCESS_SECONDS))
	var/spawn_chance_per_second = 100 * spawn_chance_rate
	if(!SPT_PROB(spawn_chance_per_second, seconds_per_tick))
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


/obj/machinery/rbmk/reactor/process(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	process_reactor_griddle(seconds_per_tick)

	if(meltdown_in_progress || reactor_integrity <= 0)
		process_meltdown_fallout()
		last_integrity_damage = 0
		reset_reaction_state()
		rod_motion_in_progress = FALSE
		update_reactor_icon()
		update_linked_consoles()
		previous_control_rod_depth = control_rod_depth
		return

	last_integrity_damage = 0

	check_supermatter_rod_activation()

	if(supermatter_cascade_active)
		update_linked_consoles()
		return

	rbmk_update_control_rods(seconds_per_tick)
	update_rod_motion_state()

	if(!has_fuel_rods())
		reset_reaction_state()
		startup_sequence_played = FALSE

		rbmk_coolant_exchange(seconds_per_tick)
		rbmk_update_pressure(seconds_per_tick)
		update_reactor_integrity(seconds_per_tick)
		rbmk_sample_coolant()
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		previous_control_rod_depth = control_rod_depth
		return

	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		scrammed = FALSE

	try_play_startup_sequence()

	var/list/all_fuel_rods = normal_slots + special_slots
	update_reactor_modifier_state(all_fuel_rods)

	var/active_rods = 0

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in all_fuel_rods)
		if(fuel_rod?.active && fuel_rod.contributes_to_reaction)
			active_rods++

	last_tick_rod_count = active_rods

	if(active_rods <= 0 || scrammed || actual_control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		running = FALSE

		rbmk_decay_process(seconds_per_tick)
		rbmk_coolant_exchange(seconds_per_tick)
		rbmk_update_pressure(seconds_per_tick)
		maintain_residual_radiation(all_fuel_rods)
		update_void_coefficient()
		emit_real_radiation()
		update_reactor_integrity(seconds_per_tick)
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

	var/total_flux = 0
	var/total_radiation = 0
	var/total_heat = 0

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in all_fuel_rods)
		if(!fuel_rod?.active)
			continue

		var/list/rod_output = fuel_rod.process_rod(seconds_per_tick)
		if(!islist(rod_output))
			continue

		total_flux += rod_output["flux"] || 0
		total_radiation += rod_output["radiation"] || 0
		total_heat += rod_output["heat"] || 0

	running = TRUE

	var/control_ratio = CLAMP01(actual_control_rod_depth / RBMK_CONTROL_ROD_MAX)
	var/flux_control_multiplier = CLAMP01(1 - control_ratio)
	var/heat_control_multiplier = CLAMP01(1 - (control_ratio ** 1.35))
	var/radiation_control_multiplier = max(
		RBMK_RESIDUAL_RADIATION_MULTIPLIER,
		CLAMP01(1 - (control_ratio ** 1.15))
	)
	var/flux_modifier_multiplier = 1 + rod_flux_multiplier_bonus

	total_flux *= flux_modifier_multiplier
	total_flux *= flux_control_multiplier
	total_heat *= heat_control_multiplier
	total_radiation *= radiation_control_multiplier

	var/base_flux = clamp(total_flux * RBMK_FLUX_GAIN, 0, RBMK_MAX_FLUX)
	var/extra_void_coefficient = update_void_coefficient()
	flux = clamp(base_flux * (1 + extra_void_coefficient), 0, RBMK_MAX_FLUX)

	last_tick_base_flux = base_flux
	last_tick_void_flux_bonus = max(flux - base_flux, 0)

	var/generated_heat_per_second = (total_heat / RBMK_MACHINERY_PROCESS_SECONDS) + (flux * RBMK_TEMP_GAIN_PER_SECOND)
	var/generated_heat = generated_heat_per_second * seconds_per_tick
	temperature += generated_heat

	thermal_output = generated_heat
	last_tick_flux = flux
	last_tick_temp_gain = generated_heat

	try_spawn_flux_anomaly(seconds_per_tick)

	radiation = clamp(
		total_radiation + (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
		0,
		RBMK_MAX_RADIATION
	)

	emit_real_radiation()

	rbmk_coolant_exchange(seconds_per_tick)

	if(coolant_internal)
		var/tritium_delta = flux * RBMK_TRITIUM_RATE * RBMK_TRITIUM_PRODUCTION_MULTIPLIER
		tritium_delta *= seconds_per_tick / RBMK_MACHINERY_PROCESS_SECONDS
		if(tritium_delta > 0)
			coolant_internal.assert_gases(/datum/gas/tritium)
			coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta

	rbmk_update_pressure(seconds_per_tick)
	rbmk_sample_coolant()
	rbmk_sample_reactor_temperature()

	update_reactor_integrity(seconds_per_tick)
	check_hard_meltdown_conditions()

	update_reactor_icon()
	update_linked_consoles()

	if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		startup_sequence_played = FALSE

	previous_control_rod_depth = control_rod_depth
