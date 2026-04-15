/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3

	/// Reactor this port belongs to
	var/obj/machinery/rbmk/reactor/parent_reactor


/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
	. = ..()
	airs = list(new /datum/gas_mixture())
	initialize_directions = dir
	connect_nodes()
	update_parents()
	SSair.add_to_active(src)
	return INITIALIZE_HINT_NORMAL


/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST


/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos()
	if(!parent_reactor?.inlet_open)
		return

	// Keep the port active while enabled so toggles and rate changes
	// continue to take effect on later atmos ticks.
	SSair.add_to_active(src)

	var/datum/gas_mixture/in_mix = airs[1]
	if(!in_mix || in_mix.total_moles() <= 0)
		return

	var/amount_ratio = clamp(parent_reactor.inlet_rate / 1000, 0, 1)
	var/datum/gas_mixture/moved_mix = in_mix.remove_ratio(amount_ratio)
	if(!moved_mix || moved_mix.total_moles() <= 0)
		return

	if(!parent_reactor.coolant_internal)
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

	// Keep the port active while enabled so it keeps checking
	// whether pressure needs to be relieved.
	SSair.add_to_active(src)

	var/datum/gas_mixture/store = parent_reactor.coolant_internal
	if(!store || store.total_moles() <= 0)
		return

	var/current_pressure = store.return_pressure()
	var/target_pressure = parent_reactor.outlet_target_pressure
	if(current_pressure <= target_pressure)
		return

	var/excess_ratio = clamp((current_pressure - target_pressure) / max(target_pressure, 1), 0, 1)
	var/datum/gas_mixture/released_mix = store.remove_ratio(excess_ratio)
	if(!released_mix || released_mix.total_moles() <= 0)
		return

	// Prefer venting into the connected pipe network.
	if(airs?.len)
		airs[1].merge(released_mix)
		update_parents()
		return

	// Fallback to turf if there is no usable pipe mix.
	var/turf/port_turf = get_turf(src)
	if(port_turf)
		port_turf.assume_air(released_mix)
		air_update_turf(port_turf)


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
	if(!inlet || !inlet.airs || inlet.airs.len < 1)
		return null
	return inlet.airs[1]


/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
	if(!outlet || !outlet.airs || outlet.airs.len < 1)
		return null
	return outlet.airs[1]


/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
	return coolant_internal


/obj/machinery/rbmk/reactor/proc/rbmk_sample_coolant()
	var/datum/gas_mixture/mix = coolant_internal
	if(!mix)
		return

	coolant_pressure_history.Add(mix.return_pressure())
	if(coolant_pressure_history.len > 60)
		coolant_pressure_history.Cut(1, 2)

	coolant_temperature_history.Add(mix.temperature)
	if(coolant_temperature_history.len > 60)
		coolant_temperature_history.Cut(1, 2)

	coolant_total_moles_history.Add(mix.total_moles())
	if(coolant_total_moles_history.len > 60)
		coolant_total_moles_history.Cut(1, 2)

	var/total = mix.total_moles()
	if(total <= 0)
		return

	for(var/gas in mix.gases)
		var/list/g = mix.gases[gas]
		var/percent = (g[MOLES] / total) * 100

		var/list/history = coolant_gas_hist[gas]
		if(!history)
			history = coolant_gas_hist[gas] = list()

		history.Add(percent)
		if(history.len > 60)
			history.Cut(1, 2)
