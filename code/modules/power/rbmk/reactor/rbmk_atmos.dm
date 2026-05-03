/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3

	/// Reactor this port belongs to.
	var/obj/machinery/rbmk/reactor/parent_reactor

	/// Compatibility for SSair.add_to_active() on this custom atmos machinery.
	/// Some atmos machinery parents expect this var to exist when the object is activated.
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

	var/total_moles = source_mix.total_moles()
	if(total_moles <= 0)
		return null

	desired_moles = clamp(desired_moles, 0, total_moles)
	if(desired_moles <= 0)
		return null

	var/remove_ratio = CLAMP01(desired_moles / total_moles)
	if(remove_ratio <= 0)
		return null

	return source_mix.remove_ratio(remove_ratio)


/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST


/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos()
	if(!parent_reactor?.inlet_open)
		return

	var/datum/gas_mixture/in_mix = airs[1]
	if(!in_mix || in_mix.total_moles() <= 0)
		return

	if(!parent_reactor.coolant_internal)
		return

	// Treat inlet_rate as a direct circulation throughput cap.
	var/desired_moles = clamp(parent_reactor.inlet_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
	if(desired_moles <= 0)
		return

	var/datum/gas_mixture/moved_mix = remove_moles_capped(in_mix, desired_moles)
	if(!moved_mix || moved_mix.total_moles() <= 0)
		return

	parent_reactor.coolant_internal.merge(moved_mix)
	update_parents()


/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST


/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos()
	if(!parent_reactor?.outlet_open)
		return

	var/datum/gas_mixture/store = parent_reactor.coolant_internal
	if(!store || store.total_moles() <= 0)
		return

	var/current_pressure = store.return_pressure()
	var/target_pressure = max(parent_reactor.outlet_target_pressure, RBMK_OUTLET_PRESSURE_BASE)

	// Outlet should always circulate when open.
	// Pressure only adds extra relief; it no longer gates all flow.
	var/desired_release_moles = clamp(parent_reactor.inlet_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)

	if(current_pressure > target_pressure)
		var/pressure_delta = current_pressure - target_pressure
		var/pressure_ratio = clamp(pressure_delta / max(RBMK_PRESSURE_CRITICAL, 1), 0.05, 1)
		desired_release_moles = max(desired_release_moles, max(10, RBMK_INLET_RATE_MAX * pressure_ratio))

	if(desired_release_moles <= 0)
		return

	var/datum/gas_mixture/released_mix = remove_moles_capped(store, desired_release_moles)
	if(!released_mix || released_mix.total_moles() <= 0)
		return

	if(length(airs))
		airs[1].merge(released_mix)
		update_parents()
		return

	var/turf/port_turf = get_turf(src)
	if(port_turf)
		port_turf.assume_air(released_mix)


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
	var/turf/center = get_turf(src)
	if(!center)
		return

	QDEL_NULL(inlet)
	QDEL_NULL(outlet)

	var/turf/in_tile = get_step(center, WEST)
	if(in_tile)
		var/obj/machinery/atmospherics/components/unary/rbmk/inlet/I = new(in_tile)
		I.parent_reactor = src
		I.dir = WEST
		inlet = I

	var/turf/out_tile = get_step(center, EAST)
	if(out_tile)
		var/obj/machinery/atmospherics/components/unary/rbmk/outlet/O = new(out_tile)
		O.parent_reactor = src
		O.dir = EAST
		outlet = O


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
	var/datum/gas_mixture/mix = coolant_internal
	if(!mix)
		return

	coolant_pressure_history += mix.return_pressure()
	if(length(coolant_pressure_history) > 60)
		coolant_pressure_history.Cut(1, 2)

	coolant_temperature_history += mix.temperature
	if(length(coolant_temperature_history) > 60)
		coolant_temperature_history.Cut(1, 2)

	coolant_total_moles_history += mix.total_moles()
	if(length(coolant_total_moles_history) > 60)
		coolant_total_moles_history.Cut(1, 2)

	var/total = mix.total_moles()
	if(total <= 0)
		return

	for(var/gas in mix.gases)
		var/list/gas_data = mix.gases[gas]
		var/percent = (gas_data[MOLES] / total) * 100

		var/list/history = coolant_gas_hist[gas]
		if(!history)
			history = coolant_gas_hist[gas] = list()

		history += percent
		if(length(history) > 60)
			history.Cut(1, 2)
