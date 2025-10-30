/*************************************************************
 * RBMK Process Logic (Rod-Driven Core Model)
 * - Integrates rod-driven flux, heat, radiation, and coolant
 * - Scales decay heat, handles realistic afterheat bleed
 * - Stabilized for clean console telemetry and graph updates
 *************************************************************/

/// Main process loop
/obj/machinery/rbmk/reactor/process(delta_time)
	if(reactor_integrity <= 0)
		running = FALSE
		return

	// --- Mark repairable state ---
	repairable = (temperature < (RBMK_MAX_TEMP * RBMK_REPAIRABLE_TEMP_RATIO))

	/*************************************************************
	 * Control Rod Auto-Shutdown
	 * - Fully inserted rods automatically halt reaction
	 *************************************************************/
	if(control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		if(running)
			running = FALSE
			scrammed = TRUE
			to_chat(src, span_notice("Control rods fully inserted — reactor shutting down."))
		rbmk_decay_process(src)
		update_linked_consoles()
		return

	/*************************************************************
	 * SCRAM / Cooldown Handling
	 *************************************************************/
	if(!running)
		rbmk_decay_process(src)
		update_linked_consoles()
		return

	/*************************************************************
	 * Reset core variables before computation
	 *************************************************************/
	flux = 0
	radiation = 0
	thermal_output = 0

	var/has_active_rods = FALSE
	var/total_flux = 0
	var/total_heat = 0
	var/total_rads = 0
	var/rod_reactivity = 0.0

	/*************************************************************
	 * Process all active rods
	 *************************************************************/
	var/list/all_rods = normal_slots + special_slots
	for(var/obj/item/rbmk/fuel_rod/fuelRod in all_rods)
		if(!fuelRod || QDELETED(fuelRod))
			continue

		var/list/result = fuelRod.process_rod(temperature, flux)
		if(!result)
			continue

		total_flux += result["flux"]
		total_rads += result["radiation"]
		total_heat += result["heat"]

		rod_reactivity += (fuelRod.flux_multiplier + fuelRod.thermal_multiplier)
		if(fuelRod.fuel_amount > 0)
			has_active_rods = TRUE

		// --- Special rod behaviors ---
		if(fuelRod.rod_type == "telecrystal" && temperature >= 2000)
			var/inc = (temperature >= 10000 ? 3 : temperature >= 5000 ? 2 : 1)
			fuelRod.charge_progress += inc
			if(fuelRod.charge_progress >= fuelRod.charge_max && !fuelRod.charged)
				fuelRod.charged = TRUE
				to_chat(src, span_warning("A telecrystal rod hums violently as it finishes charging with bluespace energy!"))

		else if(fuelRod.rod_type == "supermatter" && prob(2))
			trigger_meltdown("Supermatter destabilization within fuel rod array!")

	/*************************************************************
	 * Reactor Core Scaling
	 *************************************************************/
	var/control_effect = (100 - control_rod_depth) / 100
	var/reactivity_factor = clamp(rod_reactivity / max(1, length(all_rods)), 0.5, 2.5)

	flux        = clamp(total_flux * control_effect * reactivity_factor, 0, RBMK_MAX_FLUX)
	radiation   = clamp(total_rads * control_effect * reactivity_factor, 0, RBMK_MAX_RADIATION)
	temperature += (total_heat * control_effect * reactivity_factor)

	// --- Power output & decay heat ---
	var/generated_power = (flux + radiation + total_heat)
	decay_heat = clamp(decay_heat + (generated_power * 0.0015), 0, 300)
	thermal_output = (temperature * RBMK_HEAT_SCALING) * reactivity_factor

	/*************************************************************
	 * Coolant Energy Exchange
	 *************************************************************/
	rbmk_coolant_exchange(src)
	rbmk_sample_coolant(src)

	if(coolant_internal)
		pressure = clamp(coolant_internal.return_pressure(), 0, RBMK_PRESSURE_EXTREME)
		rbmk_record_gas_snapshot()

	/*************************************************************
	 * Natural Flux / Rad Bleed
	 *************************************************************/
	flux = max(0, flux - RBMK_FLUX_DECAY)
	radiation = max(0, radiation - RBMK_RADIATION_DECAY)

	/*************************************************************
	 * System Integrity and Chaos Metrics
	 *************************************************************/
	update_instability()
	update_reactor_integrity()

	/*************************************************************
	 * Auto SCRAM Fail-safe
	 *************************************************************/
	if(!has_active_rods || temperature > RBMK_MAX_TEMP || reactor_integrity <= 0)
		running = FALSE
		scrammed = TRUE
		to_chat(src, span_danger("⚠ Emergency SCRAM: reactor automatically shut down!"))
		update_reactor_icon()
		update_linked_consoles()
		return

	/*************************************************************
	 * Visuals and UI Sync
	 *************************************************************/
	update_reactor_icon()
	update_linked_consoles()


/*************************************************************
 * RBMK Decay / Cooldown Process
 * - Handles realistic afterheat bleed post-shutdown
 *************************************************************/

/// Afterheat simulation when reactor is scrammed
/proc/rbmk_decay_process(obj/machinery/rbmk/reactor/reactor)
	if(!reactor)
		return

	rbmk_sample_coolant(reactor)
	if(reactor.coolant_internal)
		reactor.pressure = reactor.coolant_internal.return_pressure()
		reactor.rbmk_record_gas_snapshot()

	if(reactor.decay_heat > 0)
		var/transfer = reactor.decay_heat * 0.04

		if(reactor.coolant_internal)
			reactor.coolant_internal.temperature += transfer * 0.6
			reactor.temperature -= transfer * 0.3

		reactor.flux = max(0, reactor.flux - (reactor.decay_heat * 0.04))
		reactor.radiation = max(0, reactor.radiation - (reactor.decay_heat * 0.025))
		reactor.temperature = max(RBMK_AMBIENT_TEMP, reactor.temperature - (reactor.decay_heat * 0.06))
		reactor.decay_heat *= 0.985
	else
		if(reactor.temperature > RBMK_AMBIENT_TEMP)
			reactor.temperature = max(RBMK_AMBIENT_TEMP, reactor.temperature - RBMK_IDLE_COOL_RATE)
		else
			reactor.icon_state = "reactor_off"

	reactor.update_reactor_icon()


/*************************************************************
 * Gas History Tracking (Graph Data)
 *************************************************************/

/// Snapshot coolant gas composition for console graphs
/obj/machinery/rbmk/reactor/proc/rbmk_record_gas_snapshot()
	if(!coolant_internal)
		return

	var/datum/gas_mixture/mix = coolant_internal
	var/total = mix.total_moles()
	if(total <= 0)
		return

	var/list/snapshot = list()
	for(var/gas_path in mix.gases)
		var/moles = mix.gases[gas_path][MOLES]
		var/percent = (moles / total) * 100
		snapshot[gas_path] = percent

	coolant_gas_hist += list(snapshot)
	if(length(coolant_gas_hist) > 60)
		coolant_gas_hist.Cut(1, 2)


/*************************************************************
 * RBMK Coolant Exchange (Nonlinear)
 * - Handles heat transfer and pressure buildup
 *************************************************************/

/// Handles nonlinear energy exchange between reactor and coolant
/proc/rbmk_coolant_exchange(obj/machinery/rbmk/reactor/reactor)
	if(!reactor || !reactor.coolant_internal)
		return

	var/datum/gas_mixture/mix = reactor.coolant_internal
	var/temp_diff = reactor.temperature - mix.temperature
	if(abs(temp_diff) < 0.5)
		return

	var/efficiency = 1.0
	for(var/gas_path in mix.gases)
		switch(gas_path)
			if(/datum/gas/nitrogen)        efficiency += 0.10
			if(/datum/gas/carbon_dioxide)  efficiency += 0.25
			if(/datum/gas/oxygen)          efficiency -= 0.05
			if(/datum/gas/plasma)          efficiency -= 0.40

	var/transfer = (abs(temp_diff) ** 0.9) * 0.04 * efficiency * sign(temp_diff)
	reactor.temperature -= transfer
	mix.temperature += transfer * 0.55

	// --- Dynamic pressure ---
	var/new_pressure = mix.return_pressure() + (abs(transfer) / 40)
	if(new_pressure > RBMK_PRESSURE_CRITICAL)
		reactor.instability += 3
	reactor.pressure = clamp(new_pressure, 0, RBMK_PRESSURE_EXTREME)

	// --- Oxygen byproduct buildup ---
	mix.assert_gases(/datum/gas/oxygen)
	mix.gases[/datum/gas/oxygen][MOLES] += clamp(abs(transfer) / 1800, 0, 10)

	// --- Pressure history (for graphs) ---
	reactor.coolant_pressure_history += reactor.pressure
	if(length(reactor.coolant_pressure_history) > 60)
		reactor.coolant_pressure_history.Cut(1, 2)
