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
	if(parent_reactor)
		parent_reactor.last_inlet_moles_moved = 0
		parent_reactor.last_inlet_flow_rate = 0
		parent_reactor.last_inlet_pressure = 0

	if(!parent_reactor?.inlet_open)
		return

	if(length(airs) < 1)
		return

	var/datum/gas_mixture/inlet_pipe_mix = airs[1]
	parent_reactor.last_inlet_pressure = inlet_pipe_mix?.return_pressure() || 0

	if(!inlet_pipe_mix || inlet_pipe_mix.total_moles() <= 0)
		return

	if(!parent_reactor.coolant_internal)
		return

	var/internal_pressure = parent_reactor.coolant_internal.return_pressure()
	var/available_pressure_head = parent_reactor.last_inlet_pressure + RBMK_INLET_PUMP_HEAD - internal_pressure
	if(available_pressure_head <= 0)
		return

	var/pressure_flow_ratio = CLAMP01(available_pressure_head / RBMK_INLET_PUMP_HEAD)

	var/desired_moles = clamp(parent_reactor.inlet_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
	desired_moles *= pressure_flow_ratio * seconds_per_tick
	if(desired_moles <= 0)
		return

	var/datum/gas_mixture/moved_mix = remove_moles_capped(inlet_pipe_mix, desired_moles)
	if(!moved_mix || moved_mix.total_moles() <= 0)
		return

	parent_reactor.last_inlet_moles_moved = moved_mix.total_moles()
	parent_reactor.last_inlet_flow_rate = parent_reactor.last_inlet_moles_moved / max(seconds_per_tick, 0.1)
	parent_reactor.coolant_internal.merge(moved_mix)
	update_parents()


/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST


/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	if(parent_reactor)
		parent_reactor.last_outlet_moles_moved = 0
		parent_reactor.last_outlet_flow_rate = 0
		parent_reactor.last_outlet_pressure = 0

	if(!parent_reactor?.outlet_open)
		return

	var/datum/gas_mixture/internal_coolant_mix = parent_reactor.coolant_internal
	if(!internal_coolant_mix || internal_coolant_mix.total_moles() <= 0)
		return

	var/current_pressure = internal_coolant_mix.return_pressure()
	parent_reactor.last_outlet_pressure = current_pressure

	var/downstream_pressure = 0
	if(length(airs))
		downstream_pressure = airs[1].return_pressure()

	// The outlet is a commanded mass-flow control. Pressure is an outcome of
	// coolant inventory and temperature, while downstream pressure remains a
	// physical backpressure interlock.
	if(current_pressure <= downstream_pressure)
		return

	var/desired_release_moles = clamp(parent_reactor.outlet_rate, RBMK_OUTLET_RATE_MIN, RBMK_OUTLET_RATE_MAX)
	desired_release_moles *= seconds_per_tick
	if(desired_release_moles <= 0)
		return

	var/datum/gas_mixture/released_mix = remove_moles_capped(internal_coolant_mix, desired_release_moles)
	if(!released_mix || released_mix.total_moles() <= 0)
		return

	parent_reactor.last_outlet_moles_moved = released_mix.total_moles()
	parent_reactor.last_outlet_flow_rate = parent_reactor.last_outlet_moles_moved / max(seconds_per_tick, 0.1)
	if(length(airs))
		airs[1].merge(released_mix)
		update_parents()
		return

	var/turf/outlet_turf = get_turf(src)
	if(outlet_turf)
		outlet_turf.assume_air(released_mix)


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
