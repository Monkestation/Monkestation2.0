/*************************************************************
 * RBMK Process Logic — Canonical V4.8
 * -----------------------------------------------------------
 * Responsibilities of this file:
 * - passive decay
 * - coolant heat exchange
 * - main process loop
 * - rod output integration
 * - tritium generation
 * - pressure sampling
 * - integrity / meltdown checks
 * - real radiation emission
 * - delayed control rod motion
 *
 * Design rules:
 * - OFF   = no rods installed
 * - IDLE  = rods installed but no active reaction
 * - SCRAM = emergency full insertion event, not a permanent lock
 * - No instability model
 * - Void coefficient is temperature-driven only
 *
 * V4.8 tuning:
 * - Core runs substantially hotter under load
 * - Cooling still matters, but no longer smothers temperature
 * - Heat becomes effective earlier in rod withdrawal
 * - Uses built-in radiation_pulse() driven by RBMK radiation logic
 * - Radiation now starts only after rods leave full insertion
 * - Radiation scales primarily with reactor load instead of ambient temp bleed
 * - Control rods now move toward commanded depth over time
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

/// Move actual control rods toward the commanded target depth
/obj/machinery/rbmk/reactor/proc/rbmk_update_control_rods()
	var/step_size = control_rod_step

	if(scrammed)
		step_size = scram_control_rod_step

	step_size = max(step_size, 1)

	if(actual_control_rod_depth < control_rod_depth)
		actual_control_rod_depth = min(actual_control_rod_depth + step_size, control_rod_depth)
	else if(actual_control_rod_depth > control_rod_depth)
		actual_control_rod_depth = max(actual_control_rod_depth - step_size, control_rod_depth)

	actual_control_rod_depth = clamp(actual_control_rod_depth, 0, RBMK_CONTROL_ROD_MAX)

/// Coolant heat exchange
/// - Flow still matters, but coolant should not dominate the core
/// - Core stays thermally stubborn so high-temp operation is possible
/// - Coolant still heats up enough to make outlet temperature meaningful
/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if(!coolant_internal)
		return

	var/total_coolant_moles = coolant_internal.total_moles()
	if(total_coolant_moles <= 0)
		return

	// Keep cooling meaningful without hard-smothering the core.
	var/flow_ratio = clamp(inlet_rate / max(RBMK_INLET_RATE_MAX, 1), 0.006, 0.14)

	var/datum/gas_mixture/contact_mix = coolant_internal.remove_ratio(flow_ratio)
	if(!contact_mix)
		return

	var/contact_moles = contact_mix.total_moles()
	if(contact_moles <= 0)
		coolant_internal.merge(contact_mix)
		return

	var/contact_temp = contact_mix.temperature

	// Make the core harder to drag down.
	var/core_thermal_mass = 2200

	// Coolant still picks up heat, but does not bully the core.
	var/coolant_thermal_mass = max(contact_moles * 1.8, 1)

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

/// Emit real station radiation using the built-in radiation system.
/// Radiation should not begin until rods are lifted from full insertion,
/// and should scale mostly with reactor load rather than ambient temp.
/obj/machinery/rbmk/reactor/proc/emit_real_radiation()
	if(meltdown_in_progress)
		return

	// No real radiation while fully inserted or while not actually running.
	if(actual_control_rod_depth >= RBMK_CONTROL_ROD_MAX)
		return
	if(!running)
		return
	if(radiation <= 0 || flux <= 0)
		return

	var/integrity_ratio = reactor_integrity / max(max_reactor_integrity, 1)
	integrity_ratio = clamp(integrity_ratio, 0, 1)

	// Scale emission mostly by load.
	// This keeps startup low and makes harder-running cores nastier.
	var/load_ratio = clamp(flux / max(RBMK_MAX_FLUX, 1), 0, 1)

	// Effective radiation output is softened heavily at low load.
	var/effective_rad_output = radiation * (0.15 + (load_ratio * 0.85))
	effective_rad_output = min(effective_rad_output, RBMK_MAX_RADIATION)

	// At low load, threshold stays high enough that shielding/range matter a lot.
	// At high load and lower integrity, radiation escapes more easily.
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

	// Much softer chance curve.
	// Healthy reactor = light chance, damaged reactor = meaningfully dangerous.
	var/rad_chance = 2 + (load_ratio * 8) + ((1 - integrity_ratio) * 20)

	// Keep it more chamber-local.
	var/rad_range = clamp(round(2 + (load_ratio * 3)), 2, 5)

	// Lower strength into the built-in system.
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
		actual_control_rod_depth = control_rod_depth

		rbmk_coolant_exchange()
		rbmk_update_pressure()
		rbmk_sample_coolant(src)
		rbmk_sample_reactor_temperature()

		update_reactor_icon()
		update_linked_consoles()
		return

	// Control rods continue moving whenever rods are installed.
	rbmk_update_control_rods()


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

	var/control_ratio = clamp(
		actual_control_rod_depth / RBMK_CONTROL_ROD_MAX,
		0,
		1
	)

	var/flux_control_multiplier = clamp(
		1 - control_ratio,
		0,
		1
	)

	// Less suppressive than flux through most of the range,
	// but still reaches 0 when rods are fully inserted.
	var/heat_control_multiplier = clamp(
		1 - (control_ratio ** 1.35),
		0,
		1
	)

	// Radiation suppression sits between heat and flux.
	var/radiation_control_multiplier = clamp(
		1 - (control_ratio ** 1.15),
		0,
		1
	)

	total_flux *= flux_control_multiplier
	total_heat *= heat_control_multiplier
	total_radiation *= radiation_control_multiplier


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

	emit_real_radiation()


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
