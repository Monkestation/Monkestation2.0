/obj/machinery/rbmk/reactor/proc/rbmk_decay_process()
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)
	thermal_output = 0
	last_tick_flux = flux
	last_tick_temp_gain = 0


/obj/machinery/rbmk/reactor/proc/rbmk_update_control_rods()
	var/step_size = scrammed ? scram_control_rod_step : control_rod_step
	step_size = max(step_size, 1)

	if(actual_control_rod_depth < control_rod_depth)
		actual_control_rod_depth = min(actual_control_rod_depth + step_size, control_rod_depth)
	else if(actual_control_rod_depth > control_rod_depth)
		actual_control_rod_depth = max(actual_control_rod_depth - step_size, control_rod_depth)

	actual_control_rod_depth = clamp(actual_control_rod_depth, 0, RBMK_CONTROL_ROD_MAX)


/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if(!coolant_internal)
		return

	var/total_coolant_moles = coolant_internal.total_moles()
	if(total_coolant_moles <= 0)
		return

	var/flow_ratio = clamp(inlet_rate / max(RBMK_INLET_RATE_MAX, 1), 0.006, 0.14)

	var/datum/gas_mixture/contact_mix = coolant_internal.remove_ratio(flow_ratio)
	if(!contact_mix)
		return

	var/contact_moles = contact_mix.total_moles()
	if(contact_moles <= 0)
		coolant_internal.merge(contact_mix)
		return

	var/contact_temp = contact_mix.temperature

	// Keep the core hard to drag down while still letting coolant pick up heat.
	var/core_thermal_mass = 2200
	var/coolant_thermal_mass = max(contact_moles * 1.8, 1)

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

	// No emitted radiation while the rods are fully in or the reactor is not actually running.
	if(actual_control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		return
	if(radiation <= 0 || flux <= 0)
		return

	var/integrity_ratio = clamp(reactor_integrity / max(max_reactor_integrity, 1), 0, 1)
	var/load_ratio = clamp(flux / max(RBMK_MAX_FLUX, 1), 0, 1)

	// Scale mostly off load so startup stays light and hard-running cores get nastier.
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
		update_reactor_icon()
		update_linked_consoles()
		return

	if(!has_fuel_rods())
		reset_reaction_state()
		actual_control_rod_depth = control_rod_depth

		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant()
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		return

	rbmk_update_control_rods()

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

	// SCRAM is just a latched event. If rods are pulled back out, allow the reactor to run again.
	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		scrammed = FALSE

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
		return

	running = TRUE

	var/control_ratio = clamp(actual_control_rod_depth / RBMK_CONTROL_ROD_MAX, 0, 1)
	var/flux_control_multiplier = clamp(1 - control_ratio, 0, 1)

	// Heat is still easier to sustain than flux, but fully inserted rods still shut it down.
	var/heat_control_multiplier = clamp(1 - (control_ratio ** 1.35), 0, 1)

	// Radiation suppression sits between the two.
	var/radiation_control_multiplier = clamp(1 - (control_ratio ** 1.15), 0, 1)

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
	rbmk_sample_coolant()
	rbmk_sample_reactor_temperature()

	update_reactor_integrity()
	check_hard_meltdown_conditions()

	update_reactor_icon()
	update_linked_consoles()
