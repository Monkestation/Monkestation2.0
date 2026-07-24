/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3

	var/obj/machinery/rbmk/reactor/parent_reactor
	var/list/atmos_adjacent_turfs = list()


/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
	. = ..()

	if(!length(airs))
		airs = list(new /datum/gas_mixture())

	initialize_directions = dir
	connect_nodes()
	update_parents()

	return INITIALIZE_HINT_NORMAL


/obj/machinery/atmospherics/components/unary/rbmk/base/Destroy()
	parent_reactor = null
	atmos_adjacent_turfs = null
	return ..()


/obj/machinery/atmospherics/components/unary/rbmk/base/proc/remove_moles_capped(datum/gas_mixture/source_mix, desired_moles)
	if(!source_mix)
		return null

	var/total_source_moles = source_mix.total_moles()
	if(total_source_moles <= 0)
		return null

	desired_moles = clamp(desired_moles, 0, total_source_moles)
	if(desired_moles <= 0)
		return null

	var/remove_ratio = CLAMP01(desired_moles / total_source_moles)
	if(remove_ratio <= 0)
		return null

	return source_mix.remove_ratio(remove_ratio)


/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST


/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	parent_reactor?.process_coolant_transfer(seconds_per_tick)


/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST


/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	parent_reactor?.process_coolant_transfer(seconds_per_tick)


/// Resolves both coolant ports from one pre-transfer state once per SSair cycle.
/// This prevents damage, graphs, and turbine feed from observing a half-finished
/// inlet/outlet update while preserving the commanded mol/s controls.
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
	last_outlet_pressure = internal_pressure

	var/desired_inlet_moles = 0
	if(inlet_open && inlet_pipe_mix?.total_moles() > 0)
		var/available_pressure_head = last_inlet_pressure + RBMK_INLET_PUMP_HEAD - internal_pressure
		if(available_pressure_head > 0)
			desired_inlet_moles = clamp(inlet_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX) * seconds_per_tick

	var/desired_outlet_moles = 0
	var/downstream_pressure = outlet_pipe_mix?.return_pressure() || 0
	if(outlet_open && internal_moles > 0 && internal_pressure > downstream_pressure)
		desired_outlet_moles = clamp(outlet_rate, RBMK_OUTLET_RATE_MIN, RBMK_OUTLET_RATE_MAX) * seconds_per_tick
		desired_outlet_moles = min(
			desired_outlet_moles,
			internal_moles * RBMK_OUTLET_MAX_INVENTORY_FRACTION,
		)

	// Remove both quantities from the same snapshot before either destination is
	// merged. Equal commands therefore exchange coolant instead of alternately
	// overfilling and evacuating the chamber.
	var/datum/gas_mixture/incoming_mix = inlet?.remove_moles_capped(inlet_pipe_mix, desired_inlet_moles)
	var/datum/gas_mixture/outgoing_mix = outlet?.remove_moles_capped(internal_coolant_mix, desired_outlet_moles)

	if(incoming_mix?.total_moles() > 0)
		last_inlet_moles_moved = incoming_mix.total_moles()
		last_inlet_flow_rate = last_inlet_moles_moved / max(seconds_per_tick, 0.1)
		internal_coolant_mix.merge(incoming_mix)
		inlet.update_parents()

	if(outgoing_mix?.total_moles() <= 0)
		return

	last_outlet_moles_moved = outgoing_mix.total_moles()
	last_outlet_flow_rate = last_outlet_moles_moved / max(seconds_per_tick, 0.1)
	if(outlet_pipe_mix)
		outlet_pipe_mix.merge(outgoing_mix)
		outlet.update_parents()
		return

	var/turf/outlet_turf = get_turf(outlet)
	if(outlet_turf)
		outlet_turf.assume_air(outgoing_mix)


/obj/machinery/rbmk/reactor/proc/rbmk_init_coolant()
	coolant_internal = new /datum/gas_mixture()
	coolant_internal.volume = RBMK_COOLANT_VOLUME_MAX
	coolant_internal.temperature = RBMK_AMBIENT_TEMP

	coolant_pressure_history = list()
	coolant_temperature_history = list()
	coolant_total_moles_history = list()
	coolant_gas_hist = list()


/obj/machinery/rbmk/reactor/proc/rbmk_cleanup_atmos()
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	QDEL_NULL(coolant_internal)


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


/obj/machinery/rbmk/reactor/proc/wake_coolant_ports()
	if(inlet)
		SSair.add_to_active(inlet)
	if(outlet)
		SSair.add_to_active(outlet)


/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
	if(length(inlet?.airs) < 1)
		return null
	return inlet.airs[1]


/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
	if(length(outlet?.airs) < 1)
		return null
	return outlet.airs[1]


/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
	return coolant_internal


/obj/machinery/rbmk/reactor/proc/rbmk_sample_coolant()
	var/datum/gas_mixture/coolant_mix = coolant_internal
	if(!coolant_mix)
		return

	coolant_pressure_history += coolant_mix.return_pressure()
	if(length(coolant_pressure_history) > 60)
		coolant_pressure_history.Cut(1, 2)

	coolant_temperature_history += coolant_mix.temperature
	if(length(coolant_temperature_history) > 60)
		coolant_temperature_history.Cut(1, 2)

	coolant_total_moles_history += coolant_mix.total_moles()
	if(length(coolant_total_moles_history) > 60)
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
		if(length(gas_history) > 60)
			gas_history.Cut(1, 2)
