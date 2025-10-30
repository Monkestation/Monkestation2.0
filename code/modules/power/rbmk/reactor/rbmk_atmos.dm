/*************************************************************
 * RBMK Atmos Module (Enhanced Realism v2)
 * - Handles coolant reservoir, inlet/outlet flow, and telemetry
 * - Adds dynamic heat blending, coolant loss hazards, and safer cleanup
 *************************************************************/

/*************************************************************
 * Initialization & Cleanup
 *************************************************************/

/// Initialize internal coolant reservoir
/proc/rbmk_init_coolant(obj/machinery/rbmk/reactor/reactor)
	if(!reactor)
		return
	reactor.coolant_internal = new /datum/gas_mixture()
	reactor.coolant_internal.volume = RBMK_COOLANT_VOLUME_MAX

/// Cleanup for linked atmos components
/proc/rbmk_cleanup_atmos(obj/machinery/rbmk/reactor/reactor)
	if(reactor.inlet)
		qdel(reactor.inlet)
	if(reactor.outlet)
		qdel(reactor.outlet)
	QDEL_NULL(reactor.coolant_internal)

/// Rebuild inlet/outlet ports around reactor center
/proc/rbmk_relink_ports(obj/machinery/rbmk/reactor/reactor)
	var/turf/center = get_turf(reactor)
	if(!center)
		return

	if(reactor.inlet)  qdel(reactor.inlet)
	if(reactor.outlet) qdel(reactor.outlet)

	// Inlet on west, outlet on east
	var/turf/inlet_tile = get_step(center, WEST)
	if(inlet_tile)
		reactor.inlet = new /obj/machinery/atmospherics/components/unary/rbmk/inlet(inlet_tile)
		reactor.inlet.parent_reactor = reactor
		reactor.inlet.dir = WEST

	var/turf/outlet_tile = get_step(center, EAST)
	if(outlet_tile)
		reactor.outlet = new /obj/machinery/atmospherics/components/unary/rbmk/outlet(outlet_tile)
		reactor.outlet.parent_reactor = reactor
		reactor.outlet.dir = EAST


/*************************************************************
 * Flow Control
 *************************************************************/

/// Toggle inlet valve
/obj/machinery/rbmk/reactor/proc/toggle_inlet()
	inlet_open = !inlet_open
	update_linked_consoles()
	return inlet_open

/// Toggle outlet valve
/obj/machinery/rbmk/reactor/proc/toggle_outlet()
	outlet_open = !outlet_open
	update_linked_consoles()
	return outlet_open

/// Set inlet flow rate (L/s)
/obj/machinery/rbmk/reactor/proc/set_inlet_rate(rate)
	inlet_rate = clamp(rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
	update_linked_consoles()
	return inlet_rate

/// Set outlet regulator target pressure (kPa)
/obj/machinery/rbmk/reactor/proc/set_outlet_pressure(value)
	outlet_target_pressure = clamp(value, 0, RBMK_OUTLET_PRESSURE_MAX)
	update_linked_consoles()
	return outlet_target_pressure


/*************************************************************
 * Pressure & Gas Accessors
 *************************************************************/

/// Return inlet and outlet gas mixtures
/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
	if(inlet && inlet.airs && inlet.airs.len && inlet.airs[1])
		return inlet.airs[1]
	return null

/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
	if(outlet && outlet.airs && outlet.airs.len && outlet.airs[1])
		return outlet.airs[1]
	return null

/obj/machinery/rbmk/reactor/proc/get_inlet_pressure()
	var/datum/gas_mixture/in_mix = get_inlet_mix()
	return in_mix ? in_mix.return_pressure() : 0

/obj/machinery/rbmk/reactor/proc/get_outlet_pressure()
	var/datum/gas_mixture/out_mix = get_outlet_mix()
	return out_mix ? out_mix.return_pressure() : 0

/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
	return coolant_internal


/*************************************************************
 * Coolant Sampling (Telemetry)
 *************************************************************/

/// Updates coolant stats for console display
/proc/rbmk_sample_coolant(obj/machinery/rbmk/reactor/reactor)
	var/datum/gas_mixture/mix = reactor.coolant_internal
	if(!mix)
		return

	var/pressure = mix.return_pressure()
	var/temperature = mix.temperature
	var/total_moles = mix.total_moles()

	reactor.coolant_pressure_history += pressure
	if(length(reactor.coolant_pressure_history) > 60)
		reactor.coolant_pressure_history.Cut(1, 2)

	reactor.coolant_temperature_history += temperature
	if(length(reactor.coolant_temperature_history) > 60)
		reactor.coolant_temperature_history.Cut(1, 2)

	reactor.coolant_total_moles_history += total_moles
	if(length(reactor.coolant_total_moles_history) > 60)
		reactor.coolant_total_moles_history.Cut(1, 2)

	if(total_moles <= 0)
		for(var/gp in reactor.coolant_gas_hist)
			var/list/gas_series = reactor.coolant_gas_hist[gp]
			gas_series += 0
			if(length(gas_series) > 60)
				gas_series.Cut(1, 2)
		return

	// Gas composition breakdown for telemetry
	for(var/gas_path in mix.gases)
		var/moles = mix.gases[gas_path][MOLES]
		var/percent = clamp((moles / total_moles) * 100, 0, 100)
		if(!(gas_path in reactor.coolant_gas_hist))
			reactor.coolant_gas_hist[gas_path] = list()
		var/list/series = reactor.coolant_gas_hist[gas_path]
		series += percent
		if(length(series) > 60)
			series.Cut(1, 2)

	for(var/existing_path in reactor.coolant_gas_hist)
		if(!(existing_path in mix.gases))
			var/list/series2 = reactor.coolant_gas_hist[existing_path]
			series2 += 0
			if(length(series2) > 60)
				series2.Cut(1, 2)


/*************************************************************
 * Component Base — Common Behavior
 *************************************************************/

/// Base type for RBMK atmos components
/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	hide = FALSE
	showpipe = TRUE
	shift_underlay_only = TRUE
	layer = OBJ_LAYER - 0.01
	plane = GAME_PLANE
	piping_layer = 3

	var/obj/machinery/rbmk/reactor/parent_reactor = null
	var/volume_rate = RBMK_INLET_RATE_MIN
	var/internal_pressure_bound = RBMK_OUTLET_PRESSURE_BASE

/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
	. = ..()
	airs = list(new /datum/gas_mixture())
	initialize_directions = dir
	connect_nodes()
	update_parents()
	SSair.add_to_active(src)
	return INITIALIZE_HINT_NORMAL

/obj/machinery/atmospherics/components/unary/rbmk/base/Destroy()
	QDEL_NULL(parent_reactor)
	QDEL_NULL(airs)
	return ..()


/*************************************************************
 * Inlet Component — Pulls gas into reactor
 * Includes dynamic heat blending based on flux intensity
 *************************************************************/

/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST

/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos()
	if(parent_reactor && parent_reactor.inlet_open)
		var/amt = clamp(parent_reactor.inlet_rate / 1000, 0, 1)
		var/datum/gas_mixture/in_mix = airs[1]
		if(in_mix && in_mix.total_moles() > 0)
			var/datum/gas_mixture/moved = in_mix.remove_ratio(amt)
			if(moved && moved.total_moles() > 0)
				// Dynamic heat blending based on flux intensity
				var/flux_factor = clamp(parent_reactor.flux / 400, 0.05, 1)
				moved.temperature = (moved.temperature + (parent_reactor.temperature * flux_factor)) / (1 + flux_factor)
				parent_reactor.coolant_internal.merge(moved)
				update_parents()
				SSair.add_to_active(src)


/*************************************************************
 * Outlet Component — Releases excess pressure
 * Includes density scaling, vent instability, and hazard feedback
 *************************************************************/

/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST

/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos()
	if(parent_reactor && parent_reactor.outlet_open && parent_reactor.coolant_internal.total_moles() > 0)
		var/current_pressure = parent_reactor.coolant_internal.return_pressure()
		if(current_pressure > parent_reactor.outlet_target_pressure)
			var/excess_ratio = clamp(
				(current_pressure - parent_reactor.outlet_target_pressure) / max(parent_reactor.outlet_target_pressure, 1),
				0,
				1
			)
			excess_ratio *= clamp(current_pressure / 10000, 0.5, 2)
			var/datum/gas_mixture/released = parent_reactor.coolant_internal.remove_ratio(excess_ratio)
			if(released && released.total_moles() > 0)
				if(parents && length(parents) && airs[1])
					airs[1].merge(released)
					update_parents()
					SSair.add_to_active(src)
				else
					var/turf/vent_tile = get_turf(src)
					if(vent_tile)
						vent_tile.assume_air(released)
						air_update_turf(vent_tile)
						// Coolant loss hazard
						if(released.total_moles() > (parent_reactor.coolant_internal.total_moles() * 0.1))
							to_chat(parent_reactor, span_warning("⚠ Reactor coolant loss exceeding safe margin!"))
							parent_reactor.instability += 10
						// Instability bump from uncontrolled venting
						parent_reactor.instability += clamp(released.total_moles() * 0.02, 0, 50)
