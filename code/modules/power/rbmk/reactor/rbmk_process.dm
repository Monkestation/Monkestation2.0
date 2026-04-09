/*************************************************************
 * RBMK Process Logic — Canonical V4
 * -----------------------------------------------------------
 * Responsibilities of this file:
 * - passive decay
 * - coolant heat exchange
 * - main process loop
 * - rod output integration
 * - tritium generation
 * - pressure sampling
 * - integrity / meltdown checks
 *
 * Design rules:
 * - OFF   = no rods installed
 * - IDLE  = rods installed but no active reaction
 * - SCRAM = emergency full insertion event, not a permanent lock
 * - No instability model
 * - Void coefficient is temperature-driven only
 *
 * V4 tuning:
 * - Cooling softened significantly so the core can actually heat up
 * - Flow still matters, but no longer smothers reactor output
 * - Tritium increased heavily while remaining linear with flux
 * - Meltdown only occurs when integrity reaches zero
 *************************************************************/


/*************************************************************
 * SUPPORT PROCS
 *************************************************************/

/// Passive decay when no active reaction is present
/obj/machinery/rbmk/reactor/proc/rbmk_decay_process()
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)
	thermal_output = 0
	last_tick_flux = flux
	last_tick_temp_gain = 0

/// Coolant heat exchange
/// - Only a fraction of coolant contacts the core each tick
/// - Inlet rate affects cooling authority
/// - Cold coolant cools the core
/// - Hot coolant heats the core
/// - Processed coolant is merged back into the internal loop
/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if(!coolant_internal)
		return

	var/total_coolant_moles = coolant_internal.total_moles()
	if(total_coolant_moles <= 0)
		return

	// Much softer contact fraction so cooling helps without hard-locking temp.
	var/flow_ratio = clamp(inlet_rate / max(RBMK_INLET_RATE_MAX, 1), 0.005, 0.12)

	var/datum/gas_mixture/contact_mix = coolant_internal.remove_ratio(flow_ratio)
	if(!contact_mix)
		return

	var/contact_moles = contact_mix.total_moles()
	if(contact_moles <= 0)
		coolant_internal.merge(contact_mix)
		return

	var/contact_temp = contact_mix.temperature

	// Higher = reactor temp is harder for coolant to bully around.
	var/core_thermal_mass = 900

	// Lower multiplier = contacted coolant has less control over the core.
	var/coolant_thermal_mass = max(contact_moles * 2, 1)

	var/weighted_core_heat = temperature * core_thermal_mass
	var/weighted_coolant_heat = contact_temp * coolant_thermal_mass
	var/equilibrium_temperature = (weighted_core_heat + weighted_coolant_heat) / (core_thermal_mass + coolant_thermal_mass)

	temperature = equilibrium_temperature
	contact_mix.temperature = equilibrium_temperature

	coolant_internal.merge(contact_mix)

/// Samples reactor temperature history for console graphs / telemetry
/obj/machinery/rbmk/reactor/proc/rbmk_sample_reactor_temperature()
	if(!reactor_temperature_history)
		reactor_temperature_history = list()

	reactor_temperature_history.Add(temperature)
	if(reactor_temperature_history.len > 60)
		reactor_temperature_history.Cut(1, 2)

/// Samples current coolant pressure into cached pressure var
/obj/machinery/rbmk/reactor/proc/rbmk_update_pressure()
	if(!coolant_internal)
		pressure = 0
		return

	pressure = clamp(
		coolant_internal.return_pressure(),
		0,
		RBMK_PRESSURE_EXTREME
	)

/// Hard failure checks
/// Meltdown should only ever come from integrity reaching zero.
/obj/machinery/rbmk/reactor/proc/check_hard_meltdown_conditions()
	if(meltdown_in_progress)
		return

	if(reactor_integrity <= 0)
		trigger_meltdown("Core structural integrity reached zero")
		return


/*************************************************************
 * MAIN REACTOR PROCESS
 *************************************************************/

/// Per-tick reactor logic
/obj/machinery/rbmk/reactor/process()

	/*******************************************************
	 * A. POST-MELTDOWN HARD STOP
	 *******************************************************/
	if(meltdown_in_progress || reactor_integrity <= 0)
		reset_reaction_state()
		update_reactor_icon()
		update_linked_consoles()
		return


	/*******************************************************
	 * B. TRUE OFF — NO FUEL RODS INSTALLED
	 *******************************************************/
	if(!has_fuel_rods())
		reset_reaction_state()

		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant(src)
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		return


	/*******************************************************
	 * C. COLLECT ROD OUTPUT
	 * For V1, all working rods must return:
	 *   "flux", "radiation", "heat"
	 *******************************************************/
	var/total_flux = 0
	var/total_radiation = 0
	var/total_heat = 0
	var/active_rods = 0

	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(!fuel_rod || !fuel_rod.active)
			continue

		var/list/rod_output = fuel_rod.process_rod()
		if(!islist(rod_output))
			continue

		total_flux += rod_output["flux"] || 0
		total_radiation += rod_output["radiation"] || 0
		total_heat += rod_output["heat"] || 0
		active_rods++

	last_tick_rod_count = active_rods

	// SCRAM is an event, not a permanent lock.
	// Once operators withdraw from full insertion, the reactor may run again.
	if(scrammed && control_rod_depth < RBMK_CONTROL_ROD_MAX)
		scrammed = FALSE


	/*******************************************************
	 * D. IDLE / SCRAM STATE
	 *******************************************************/
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
		return


	/*******************************************************
	 * E. CONTROL ROD DAMPENING
	 *******************************************************/
	running = TRUE

	var/control_multiplier = clamp(
		1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX),
		0,
		1
	)

	total_flux *= control_multiplier
	total_heat *= control_multiplier
	total_radiation *= control_multiplier


	/*******************************************************
	 * F. FLUX INTEGRATION
	 *******************************************************/
	flux = clamp(
		total_flux * RBMK_FLUX_GAIN,
		0,
		RBMK_MAX_FLUX
	)


	/*******************************************************
	 * G. HEAT INTEGRATION
	 * V1 uses rod heat directly plus flux-derived heat.
	 *******************************************************/
	var/generated_heat = total_heat + (flux * RBMK_TEMP_GAIN_PER_TICK)
	temperature += generated_heat

	thermal_output = generated_heat
	last_tick_flux = flux
	last_tick_temp_gain = generated_heat


	/*******************************************************
	 * H. VOID COEFFICIENT
	 *******************************************************/
	var/extra_void_coefficient = update_void_coefficient()
	flux = clamp(
		flux * (1 + extra_void_coefficient),
		0,
		RBMK_MAX_FLUX
	)


	/*******************************************************
	 * I. RADIATION OUTPUT
	 *******************************************************/
	radiation = clamp(
		total_radiation + (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
		0,
		RBMK_MAX_RADIATION
	)


	/*******************************************************
	 * J. TRITIUM PRODUCTION
	 * Tritium is a byproduct only. It affects the system
	 * indirectly through coolant pressure / gas composition.
	 *
	 * Strongly increased, but kept linear with flux.
	 *******************************************************/
	if(coolant_internal)
		var/tritium_delta = flux * (RBMK_TRITIUM_RATE * 400)
		if(tritium_delta > 0)
			coolant_internal.assert_gases(/datum/gas/tritium)
			coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta


	/*******************************************************
	 * K. COOLANT / PRESSURE / TELEMETRY
	 *******************************************************/
	rbmk_coolant_exchange()
	rbmk_update_pressure()
	rbmk_sample_coolant(src)
	rbmk_sample_reactor_temperature()


	/*******************************************************
	 * L. INTEGRITY / FAILURE
	 *******************************************************/
	update_reactor_integrity()
	check_hard_meltdown_conditions()


	/*******************************************************
	 * M. VISUALS / UI
	 *******************************************************/
	update_reactor_icon()
	update_linked_consoles()
