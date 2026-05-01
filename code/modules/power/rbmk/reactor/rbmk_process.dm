/obj/machinery/rbmk/reactor/proc/rbmk_decay_process()
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)
	thermal_output = 0
	last_tick_flux = flux
	last_tick_temp_gain = 0


/obj/machinery/rbmk/reactor/proc/rbmk_update_control_rods()
	var/step_size = scrammed ? scram_control_rod_step : control_rod_step
	step_size = max(step_size, 1)

	if(!scrammed)
		step_size = max(round(step_size * 0.35), 1)
	else
		step_size = max(round(step_size * 0.6), 1)

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
		playsound(src, 'monkestation/sound/effects/rbmk/switch2.ogg', 55, TRUE)


/obj/machinery/rbmk/reactor/proc/try_play_startup_sequence()
	if(startup_sequence_played)
		return

	if(meltdown_in_progress || scrammed)
		return

	if(!has_fuel_rods())
		return

	if(previous_control_rod_depth >= RBMK_CONTROL_ROD_MAX && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		startup_sequence_played = TRUE
		playsound(src, 'monkestation/sound/effects/rbmk/startup.ogg', 70, TRUE)
		addtimer(CALLBACK(src, PROC_REF(play_startup_stage_two)), 1, TIMER_DELETE_ME)


/obj/machinery/rbmk/reactor/proc/play_startup_stage_two()
	if(QDELETED(src))
		return

	if(meltdown_in_progress || scrammed)
		return

	if(!has_fuel_rods())
		return

	playsound(src, 'monkestation/sound/effects/rbmk/startup2.ogg', 70, TRUE)


/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if(!coolant_internal)
		return

	var/total_coolant_moles = coolant_internal.total_moles()
	if(total_coolant_moles <= 0)
		return

	// Treat inlet_rate as a cooling throughput request, not a raw percentage
	// of the whole internal coolant reservoir.
	var/flow_ratio = CLAMP01(inlet_rate / max(RBMK_INLET_RATE_MAX, 1))
	if(flow_ratio <= 0)
		return

	// Bounded participating coolant mass per tick.
	// This makes cooling depend mostly on commanded flow rather than
	// on how huge the stored reservoir happens to be.
	var/desired_contact_moles = 0.5 + (flow_ratio * 7.5)
	desired_contact_moles = clamp(desired_contact_moles, 0.5, 8)

	var/remove_ratio = CLAMP01(desired_contact_moles / total_coolant_moles)
	if(remove_ratio <= 0)
		return

	var/datum/gas_mixture/contact_mix = coolant_internal.remove_ratio(remove_ratio)
	if(!contact_mix)
		return

	var/contact_moles = contact_mix.total_moles()
	if(contact_moles <= 0)
		coolant_internal.merge(contact_mix)
		return

	var/contact_temp = contact_mix.temperature

	// Keep the reactor thermally heavy so it does not instantly swing around.
	var/core_thermal_mass = 2200

	var/effective_contact_moles = clamp(contact_moles, 0.5, 8)
	var/flow_strength = clamp(flow_ratio, 0.05, 1.0)

	var/coolant_thermal_mass = max(effective_contact_moles * 1.8 * flow_strength, 1)

	var/weighted_core_heat = temperature * core_thermal_mass
	var/weighted_coolant_heat = contact_temp * coolant_thermal_mass
	var/equilibrium_temperature = (weighted_core_heat + weighted_coolant_heat) / (core_thermal_mass + coolant_thermal_mass)

	temperature = equilibrium_temperature
	contact_mix.temperature = equilibrium_temperature

	coolant_internal.merge(contact_mix)


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


/obj/machinery/rbmk/reactor/proc/check_hard_meltdown_conditions()
	if(meltdown_in_progress)
		return

	if(reactor_integrity <= 0)
		trigger_meltdown("Core structural integrity reached zero")


/obj/machinery/rbmk/reactor/process()
	if(meltdown_in_progress || reactor_integrity <= 0)
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
		rbmk_sample_coolant(src)
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		previous_control_rod_depth = control_rod_depth
		return

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

	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		scrammed = FALSE

	if(active_rods <= 0 || scrammed)
		running = FALSE

		rbmk_decay_process()
		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant(src)
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

	radiation = clamp(
		total_radiation + (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
		0,
		RBMK_MAX_RADIATION
	)

	emit_real_radiation()

	if(coolant_internal)
		var/tritium_delta = flux * (RBMK_TRITIUM_RATE * 400)
		if(tritium_delta > 0)
			coolant_internal.assert_gases(/datum/gas/tritium)
			coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta

	rbmk_coolant_exchange()
	rbmk_update_pressure()
	rbmk_sample_coolant(src)
	rbmk_sample_reactor_temperature()

	update_reactor_integrity()
	check_hard_meltdown_conditions()

	update_reactor_icon()
	update_linked_consoles()

	if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		startup_sequence_played = FALSE

	previous_control_rod_depth = control_rod_depth
