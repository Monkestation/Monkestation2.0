/*************************************************************
 * RBMK Atmos Module
 * - Handles internal coolant reservoir
 * - Flow control, ports, sampling, and console data
 *************************************************************/

/*************************************************************
 * Initialization & Cleanup
 *************************************************************/

/// Init coolant tank
/proc/rbmk_init_coolant(obj/machinery/rbmk/reactor/R)
    R.coolant_internal = new
    R.coolant_internal.volume = RBMK_COOLANT_VOLUME_MAX

/// Cleanup
/proc/rbmk_cleanup_atmos(obj/machinery/rbmk/reactor/R)
    if(R.inlet)  qdel(R.inlet)
    if(R.outlet) qdel(R.outlet)
    QDEL_NULL(R.coolant_internal)

/// Rebuild inlet/outlet ports
/proc/rbmk_relink_ports(obj/machinery/rbmk/reactor/R)
    var/turf/center = get_turf(R)
    if(!center) return

    if(R.inlet)  qdel(R.inlet)
    if(R.outlet) qdel(R.outlet)

    var/turf/inlet_tile = get_step(center, WEST)
    if(inlet_tile)
        R.inlet = new /obj/machinery/atmospherics/components/unary/rbmk/inlet(inlet_tile)
        R.inlet.parent_reactor = R
        R.inlet.dir = WEST

    var/turf/outlet_tile = get_step(center, EAST)
    if(outlet_tile)
        R.outlet = new /obj/machinery/atmospherics/components/unary/rbmk/outlet(outlet_tile)
        R.outlet.parent_reactor = R
        R.outlet.dir = EAST

/*************************************************************
 * Flow Control
 *************************************************************/

/// Toggle inlet
/obj/machinery/rbmk/reactor/proc/toggle_inlet()
    inlet_open = !inlet_open
    update_linked_consoles()
    return inlet_open

/// Toggle outlet
/obj/machinery/rbmk/reactor/proc/toggle_outlet()
    outlet_open = !outlet_open
    update_linked_consoles()
    return outlet_open

/// Set inlet flow rate
/obj/machinery/rbmk/reactor/proc/set_inlet_rate(val)
    inlet_rate = clamp(val, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
    update_linked_consoles()
    return inlet_rate

/// Set outlet regulator
/obj/machinery/rbmk/reactor/proc/set_outlet_pressure(val)
    outlet_target_pressure = clamp(val, 0, RBMK_OUTLET_PRESSURE_MAX)
    update_linked_consoles()
    return outlet_target_pressure

/obj/machinery/rbmk/reactor/proc/get_flow_state()
    return list(
        "inlet_open" = inlet_open,
        "outlet_open" = outlet_open,
        "inlet_rate" = inlet_rate,
        "inlet_min" = RBMK_INLET_RATE_MIN,
        "inlet_max" = RBMK_INLET_RATE_MAX,
        "outlet_target_pressure" = outlet_target_pressure,
        "outlet_pressure_max" = RBMK_OUTLET_PRESSURE_MAX
    )

/*************************************************************
 * Pressure getters
 *************************************************************/

/// Inlet mix
/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
    if(inlet && inlet.airs && inlet.airs.len && inlet.airs[1])
        return inlet.airs[1]
    return null

/// Outlet mix
/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
    if(outlet && outlet.airs && outlet.airs.len && outlet.airs[1])
        return outlet.airs[1]
    return null

/obj/machinery/rbmk/reactor/proc/get_inlet_pressure()
    var/datum/gas_mixture/in_mix = get_inlet_mix()
    if(in_mix) return in_mix.return_pressure()
    return 0

/obj/machinery/rbmk/reactor/proc/get_outlet_pressure()
    var/datum/gas_mixture/out_mix = get_outlet_mix()
    if(out_mix) return out_mix.return_pressure()
    return 0

/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
    return coolant_internal

/*************************************************************
 * Coolant sampling
 *************************************************************/

/// Sample telemetry
/proc/rbmk_sample_coolant(obj/machinery/rbmk/reactor/R)
    var/datum/gas_mixture/mix = R.coolant_internal
    if(!mix) return

    var/press = mix.return_pressure()
    var/temp  = mix.temperature
    var/total = mix.total_moles()

    R.coolant_pressure_history += press
    if(length(R.coolant_pressure_history) > 50) R.coolant_pressure_history.Cut(1, 2)

    R.coolant_temperature_history += temp
    if(length(R.coolant_temperature_history) > 50) R.coolant_temperature_history.Cut(1, 2)

    R.coolant_total_moles_history += total
    if(length(R.coolant_total_moles_history) > 50) R.coolant_total_moles_history.Cut(1, 2)

    if(total <= 0)
        for (var/gp in R.coolant_gas_hist)
            var/list/L = R.coolant_gas_hist[gp]
            L += 0
            if(length(L) > 50) L.Cut(1, 2)
        return

    for (var/gas_path in mix.gases)
        var/moles = mix.gases[gas_path][MOLES]
        var/percent = clamp((moles / total) * 100, 0, 100)
        if(!(gas_path in R.coolant_gas_hist))
            R.coolant_gas_hist[gas_path] = list()
        var/list/series = R.coolant_gas_hist[gas_path]
        series += percent
        if(length(series) > 50) series.Cut(1, 2)

    for (var/existing_gas_path in R.coolant_gas_hist)
        if(!(existing_gas_path in mix.gases))
            var/list/series2 = R.coolant_gas_hist[existing_gas_path]
            series2 += 0
            if(length(series2) > 50) series2.Cut(1, 2)

/*************************************************************
 * Atmos Component Definitions
 *************************************************************/

/// Common base
/obj/machinery/atmospherics/components/unary/rbmk/base
    parent_type = /obj/machinery/atmospherics/components/unary
    anchored = TRUE
    density = FALSE
    icon = null
    icon_state = null
    hide = FALSE
    showpipe = TRUE
    shift_underlay_only = TRUE
    layer = GAS_PUMP_LAYER
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
    return ..()

/*************************************************************
 * Inlet Component
 *************************************************************/

/// Inlet pulls gas into reactor coolant_internal
/obj/machinery/atmospherics/components/unary/rbmk/inlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Inlet"
    dir = WEST
    layer = OBJ_LAYER - 0.01   // make sure items render above port

/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos()
    if(parent_reactor && parent_reactor.inlet_open)
        var/amt = clamp(parent_reactor.inlet_rate / 1000, 0, 1) // turn L/s into ratio
        var/datum/gas_mixture/in_mix = airs[1]
        if(in_mix && in_mix.total_moles() > 0)
            var/datum/gas_mixture/moved = in_mix.remove_ratio(amt)
            if(moved && moved.total_moles() > 0)
                parent_reactor.coolant_internal.merge(moved)
                update_parents()
                SSair.add_to_active(src)

/*************************************************************
 * Outlet Component
 *************************************************************/

/// Outlet pushes excess coolant gas out if pressure exceeds target
/obj/machinery/atmospherics/components/unary/rbmk/outlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Outlet"
    dir = EAST
    layer = OBJ_LAYER - 0.01   // make sure items render above port

/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos()
    if(parent_reactor && parent_reactor.outlet_open && parent_reactor.coolant_internal.total_moles() > 0)
        var/current_pressure = parent_reactor.coolant_internal.return_pressure()
        if(current_pressure > parent_reactor.outlet_target_pressure)
            var/excess_ratio = clamp(
                (current_pressure - parent_reactor.outlet_target_pressure) / max(parent_reactor.outlet_target_pressure, 1),
                0,
                1
            )
            var/datum/gas_mixture/released = parent_reactor.coolant_internal.remove_ratio(excess_ratio)
            if(released && released.total_moles() > 0)
                // ✅ Push to pipe net if connected
                if(parents && length(parents) && airs[1])
                    airs[1].merge(released)
                    update_parents()
                    SSair.add_to_active(src)
                else
                    // ✅ Leak into turf if not connected
                    var/turf/T = get_turf(src)
                    if(T)
                        T.assume_air(released)
