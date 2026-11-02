/// Hidden unary atmos component paired with an RBMK reactor coolant port.
/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3
	/// Reactor vessel that owns this port.
	var/obj/machinery/rbmk/reactor/parent_reactor

/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
	. = ..()
	if(!length(airs))
		airs = list(new /datum/gas_mixture())
	initialize_directions = dir
	connect_nodes()
	update_parents()
	return .

/obj/machinery/atmospherics/components/unary/rbmk/base/Destroy()
	parent_reactor = null
	return ..()

/// Coolant inlet port placed west of an RBMK vessel.
/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST

/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	parent_reactor?.process_coolant_transfer(seconds_per_tick)

/// Coolant outlet port placed east of an RBMK vessel.
/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST

/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	parent_reactor?.process_coolant_transfer(seconds_per_tick)

/**
 * Moves coolant through both ports once per air tick.
 *
 * Both transfers use the same starting state so the reactor never exposes a
 * half-finished coolant update.
 */
/obj/machinery/rbmk/reactor/proc/process_coolant_transfer(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	if(last_coolant_air_cycle == SSair.times_fired)
		return
	last_coolant_air_cycle = SSair.times_fired
	last_inlet_moles_moved = 0
	last_outlet_moles_moved = 0
	last_inlet_flow_rate = 0
	last_outlet_flow_rate = 0
	last_inlet_pressure = 0
	last_outlet_pressure = 0
	var/datum/gas_mixture/internal_coolant_mix = coolant_internal
	if(!internal_coolant_mix)
		return
	var/datum/gas_mixture/inlet_pipe_mix = get_inlet_mix()
	var/datum/gas_mixture/outlet_pipe_mix = get_outlet_mix()
	var/internal_pressure = internal_coolant_mix.return_pressure()
	var/internal_moles = internal_coolant_mix.total_moles()
	last_inlet_pressure = inlet_pipe_mix?.return_pressure() || 0
	last_outlet_pressure = outlet_pipe_mix?.return_pressure() || 0
	var/desired_inlet_moles = 0
	if(inlet_open && inlet_pipe_mix?.total_moles() > 0)
		var/inlet_target_pressure = last_inlet_pressure + RBMK_INLET_PUMP_HEAD
		var/inlet_temperature_delta = abs(inlet_pipe_mix.temperature - internal_coolant_mix.temperature)
		var/inlet_pressure_limited_moles = inlet_pipe_mix.gas_pressure_calculate(
			internal_coolant_mix,
			inlet_target_pressure,
			inlet_temperature_delta <= 5,
		)
		desired_inlet_moles = min(
			clamp(inlet_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX) * seconds_per_tick,
			inlet_pressure_limited_moles,
		)
	var/desired_outlet_moles = 0
	var/turf/outlet_turf = get_turf(outlet)
	var/datum/gas_mixture/outlet_destination_mix = outlet_pipe_mix
	if(!outlet_destination_mix && outlet_turf)
		outlet_destination_mix = outlet_turf.return_air()
	var/downstream_pressure = outlet_destination_mix?.return_pressure() || 0
	var/outlet_target_pressure = 0
	if(outlet_open && outlet_destination_mix && internal_moles > 0 && internal_pressure > downstream_pressure)
		outlet_target_pressure = downstream_pressure + ((internal_pressure - downstream_pressure) / 2)
		var/outlet_temperature_delta = abs(internal_coolant_mix.temperature - outlet_destination_mix.temperature)
		var/outlet_pressure_limited_moles = internal_coolant_mix.gas_pressure_calculate(
			outlet_destination_mix,
			outlet_target_pressure,
			outlet_temperature_delta <= 5,
		)
		// Keep the circuit pressurized. The rate command is a maximum flow,
		// while backpressure determines when the regulator may actually open.
		var/held_pressure = clamp(operating_pressure, RBMK_OPERATING_PRESSURE_MIN, get_effective_pressure_warning())
		var/minimum_source_pressure = max(outlet_target_pressure, held_pressure)
		var/outlet_source_limited_moles = internal_moles * max(1 - (minimum_source_pressure / internal_pressure), 0)
		desired_outlet_moles = min(
			clamp(outlet_rate, RBMK_OUTLET_RATE_MIN, RBMK_OUTLET_RATE_MAX) * seconds_per_tick,
			internal_moles * RBMK_OUTLET_MAX_INVENTORY_FRACTION,
			outlet_pressure_limited_moles,
			outlet_source_limited_moles,
		)
	// Remove both quantities from the same snapshot before either destination is
	// merged. Equal commands therefore exchange coolant instead of alternately
	// overfilling and evacuating the chamber.
	var/datum/gas_mixture/incoming_mix = inlet ? inlet_pipe_mix?.remove(desired_inlet_moles) : null
	var/datum/gas_mixture/outgoing_mix
	if(outlet && desired_outlet_moles > 0)
		// Separate tritium into the outlet stream first, preserving the working
		// coolant where possible. No gas is hidden, discarded or sent through
		// a closed valve; the normal outlet flow budget still applies.
		var/list/tritium_entry = internal_coolant_mix.gases[/datum/gas/tritium]
		var/tritium_moles = tritium_entry ? tritium_entry[MOLES] : 0
		if(tritium_moles > 0)
			outgoing_mix = internal_coolant_mix.remove_specific(/datum/gas/tritium, min(tritium_moles, desired_outlet_moles))
		var/remaining_moles = desired_outlet_moles - (outgoing_mix?.total_moles() || 0)
		if(remaining_moles > 0)
			var/datum/gas_mixture/working_coolant = internal_coolant_mix.remove(remaining_moles)
			if(outgoing_mix)
				outgoing_mix.merge(working_coolant)
			else
				outgoing_mix = working_coolant
		// Selecting offgas changes the parcel heat capacity. Recheck pressure
		// using its actual composition before merging into the destination.
		if(outgoing_mix?.total_moles() > 0 && outlet_destination_mix)
			var/allowed_moles = outgoing_mix.gas_pressure_calculate(
				outlet_destination_mix,
				outlet_target_pressure,
				abs(outgoing_mix.temperature - outlet_destination_mix.temperature) <= 5,
			)
			var/excess_moles = max(outgoing_mix.total_moles() - allowed_moles, 0)
			if(excess_moles > 0)
				internal_coolant_mix.merge(outgoing_mix.remove(excess_moles))
	if(incoming_mix?.total_moles() > 0)
		last_inlet_moles_moved = incoming_mix.total_moles()
		last_inlet_flow_rate = last_inlet_moles_moved / max(seconds_per_tick, 0.1)
		internal_coolant_mix.merge(incoming_mix)
		inlet.update_parents()
	if(outgoing_mix?.total_moles() > 0)
		last_outlet_moles_moved = outgoing_mix.total_moles()
		last_outlet_flow_rate = last_outlet_moles_moved / max(seconds_per_tick, 0.1)
		if(outlet_pipe_mix)
			outlet_pipe_mix.merge(outgoing_mix)
			outlet.update_parents()
		else if(outlet_turf)
			outlet_turf.assume_air(outgoing_mix)
	// Exchange heat on the same clock as gas flow, in smaller steps. Even a
	// stationary coolant inventory conducts heat; no flow must not skip this.
	if(!meltdown_in_progress && !supermatter_rod)
		rbmk_coolant_exchange(seconds_per_tick)
	pressure = max(internal_coolant_mix.return_pressure(), 0)

/** Creates the reactor's coolant mixture and telemetry histories. */
/obj/machinery/rbmk/reactor/proc/rbmk_init_coolant()
	coolant_internal = new /datum/gas_mixture()
	coolant_internal.volume = RBMK_COOLANT_VOLUME_MAX
	coolant_internal.temperature = RBMK_AMBIENT_TEMP
	coolant_pressure_history = list()
	coolant_temperature_history = list()
	coolant_total_moles_history = list()
	coolant_gas_hist = list()

/** Deletes the coolant ports and internal gas mixture owned by the reactor. */
/obj/machinery/rbmk/reactor/proc/rbmk_cleanup_atmos()
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	QDEL_NULL(coolant_internal)

/** Recreates the reactor's coolant ports on their adjacent tiles. */
/obj/machinery/rbmk/reactor/proc/relink_ports()
	var/turf/center_turf = get_turf(src)
	if(!center_turf)
		return
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	var/turf/inlet_turf = get_step(center_turf, WEST)
	if(inlet_turf)
		var/obj/machinery/atmospherics/components/unary/rbmk/inlet/new_inlet = new(inlet_turf)
		new_inlet.parent_reactor = src
		new_inlet.dir = WEST
		inlet = new_inlet
	var/turf/outlet_turf = get_step(center_turf, EAST)
	if(outlet_turf)
		var/obj/machinery/atmospherics/components/unary/rbmk/outlet/new_outlet = new(outlet_turf)
		new_outlet.parent_reactor = src
		new_outlet.dir = EAST
		outlet = new_outlet

/** Wakes both coolant ports after a control change. */
/obj/machinery/rbmk/reactor/proc/wake_coolant_ports()
	if(inlet)
		SSair.start_processing_machine(inlet)
	if(outlet)
		SSair.start_processing_machine(outlet)

/** Returns the gas connected to the coolant inlet. */
/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
	if(length(inlet?.airs) < 1)
		return null
	return inlet.airs[1]

/** Returns the gas connected to the coolant outlet. */
/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
	if(length(outlet?.airs) < 1)
		return null
	return outlet.airs[1]

/** Appends the current coolant state to the bounded telemetry histories. */
/obj/machinery/rbmk/reactor/proc/rbmk_sample_coolant()
	var/datum/gas_mixture/coolant_mix = coolant_internal
	if(!coolant_mix)
		return
	coolant_pressure_history += coolant_mix.return_pressure()
	if(length(coolant_pressure_history) > RBMK_TELEMETRY_HISTORY_LENGTH)
		coolant_pressure_history.Cut(1, 2)
	coolant_temperature_history += coolant_mix.temperature
	if(length(coolant_temperature_history) > RBMK_TELEMETRY_HISTORY_LENGTH)
		coolant_temperature_history.Cut(1, 2)
	coolant_total_moles_history += coolant_mix.total_moles()
	if(length(coolant_total_moles_history) > RBMK_TELEMETRY_HISTORY_LENGTH)
		coolant_total_moles_history.Cut(1, 2)
	var/total_coolant_moles = coolant_mix.total_moles()
	if(total_coolant_moles <= 0)
		return
	for(var/gas_path in coolant_mix.gases)
		var/list/gas_data = coolant_mix.gases[gas_path]
		var/percent = (gas_data[MOLES] / total_coolant_moles) * 100
		var/list/gas_history = coolant_gas_hist[gas_path]
		if(!gas_history)
			gas_history = coolant_gas_hist[gas_path] = list()
		gas_history += percent
		if(length(gas_history) > RBMK_TELEMETRY_HISTORY_LENGTH)
			gas_history.Cut(1, 2)
