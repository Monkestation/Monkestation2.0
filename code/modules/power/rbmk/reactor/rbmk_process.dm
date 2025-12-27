/*************************************************************
 * RBMK PROCESS LOGIC — MODEL A (2025 CANONICAL, FINAL)
 * -----------------------------------------------------------
 * CONTRACT:
 * - Fuel rods are AUTHORITATIVE over:
 *     • activation/deactivation
 *     • per-rod reactivity output
 *
 * - Reactor integrates:
 *     Rods → Flux → Heat → Void Coefficient → Flux
 *
 * DESIGN RULES:
 * - OFF   = no rods physically installed
 * - IDLE  = rods installed but inactive
 * - SCRAM = rods present, reactivity forced to zero
 * - No instability, linear VC feedback only
 *************************************************************/


/*************************************************************
 * SUPPORT PROCS (REACTOR-BOUND, NOT GLOBAL)
 *************************************************************/

/// Passive decay when no reactivity is present
/obj/machinery/rbmk/reactor/proc/rbmk_decay_process()
	flux = max(flux - RBMK_FLUX_DECAY, 0)
	radiation = max(radiation - RBMK_RADIATION_DECAY, 0)


/// Coolant heat exchange (delta-based, non-destructive)
/// Coolant may pull reactor below ambient
/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange()
	if (!coolant_internal)
		return

	var/delta = temperature - coolant_internal.temperature
	if (delta <= 0)
		return

	var/transfer = min(5, delta * 0.25)
	temperature -= transfer
	coolant_internal.temperature += transfer



/*************************************************************
 * MAIN REACTOR PROCESS
 *************************************************************/

/// Per-tick reactor logic
/obj/machinery/rbmk/reactor/process()

	/*******************************************************
	 * A. HARD TERMINATION (POST-MELTDOWN)
	 *******************************************************/
	if (reactor_integrity <= 0)
		flux = 0
		radiation = 0
		update_reactor_icon()
		update_linked_consoles()
		return


	/*******************************************************
	 * B. TRUE OFF — NO FUEL RODS INSTALLED
	 *******************************************************/
	if (!has_fuel_rods())
		running = FALSE
		flux = 0
		radiation = 0

		rbmk_coolant_exchange()
		rbmk_sample_coolant(src)

		update_reactor_icon()
		update_linked_consoles()
		return


	/*******************************************************
	 * C. COLLECT ROD OUTPUT (AUTHORITATIVE)
	 *******************************************************/
	var/total_flux = 0
	var/total_radiation = 0
	var/active_rods = 0

	for (var/obj/item/rbmk/fuel_rod/rod in (normal_slots + special_slots))
		if (!rod || !rod.active)
			continue

		var/list/output = rod.process_rod()
		total_flux += output["flux"]
		total_radiation += output["radiation"]
		active_rods++

	last_tick_rod_count = active_rods
	running = (active_rods > 0 && !scrammed)


	/*******************************************************
	 * D. IDLE / SCRAM STATE
	 *******************************************************/
	if (active_rods == 0 || scrammed)
		rbmk_decay_process()
		rbmk_coolant_exchange()
		rbmk_sample_coolant(src)

		update_reactor_icon()
		update_linked_consoles()
		return


	/*******************************************************
	 * E. CONTROL ROD DAMPENING
	 *******************************************************/
	var/control_multiplier = clamp(
		1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX),
		0,
		1
	)

	total_flux *= control_multiplier


	/*******************************************************
	 * F. FLUX INTEGRATION
	 *******************************************************/
	flux = clamp(
		total_flux * RBMK_FLUX_GAIN,
		0,
		RBMK_MAX_FLUX
	)


	/*******************************************************
	 * G. HEAT INTEGRATION (FROM FLUX)
	 *******************************************************/
	var/generated_heat = flux * RBMK_TEMP_GAIN_PER_TICK
	temperature += generated_heat

	thermal_output = generated_heat
	last_tick_flux = flux
	last_tick_temp_gain = generated_heat


	/*******************************************************
	 * H. VOID COEFFICIENT (AUTHORITATIVE PROC)
	 *******************************************************/
	var/extra_vc = update_void_coefficient()
	flux = clamp(
		flux * (1 + extra_vc),
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
	 * J. TRITIUM PRODUCTION (OPTIONAL)
	 *******************************************************/
	if (coolant_internal)
		var/tritium_delta = flux * RBMK_TRITIUM_RATE
		if (tritium_delta > 0)
			coolant_internal.assert_gases(/datum/gas/tritium)
			coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta


	/*******************************************************
	 * K. COOLANT + TELEMETRY
	 *******************************************************/
	rbmk_coolant_exchange()
	rbmk_sample_coolant(src)

	if (coolant_internal)
		pressure = clamp(
			coolant_internal.return_pressure(),
			0,
			RBMK_PRESSURE_EXTREME
		)


	/*******************************************************
	 * L. VISUALS + UI
	 *******************************************************/
	update_reactor_icon()
	update_linked_consoles()
