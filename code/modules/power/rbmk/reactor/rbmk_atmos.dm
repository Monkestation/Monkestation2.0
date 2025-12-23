/*************************************************************
 * RBMK Atmos Module — 2025 Revision (Aligned With New Core)
 * -----------------------------------------------------------
 * - Coolant is PURELY for heat transport
 * - No moderation, no rod interaction
 * - Coolant stabilizes temp & pressure only
 * - Inlet = pull, Outlet = pressure relief
 * - Telemetry-safe, test-merge ready
 *************************************************************/


/*************************************************************
 * Base Component — Shared Atmos Behavior
 *************************************************************/

/// Base atmos component for RBMK ports
/obj/machinery/atmospherics/components/unary/rbmk/base
    parent_type = /obj/machinery/atmospherics/components/unary
    anchored = TRUE
    density = FALSE
    piping_layer = 3

    /// Reactor owning this component
    var/obj/machinery/rbmk/reactor/parent_reactor


/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
    . = ..()
    airs = list(new /datum/gas_mixture())
    initialize_directions = dir
    connect_nodes()
    update_parents()
    SSair.add_to_active(src)
    return INITIALIZE_HINT_NORMAL



/*************************************************************
 * Inlet Component — Pulls coolant IN
 *************************************************************/

/// Inlet pulls gas from pipe INTO reactor
/obj/machinery/atmospherics/components/unary/rbmk/inlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Inlet"
    dir = WEST


/obj/machinery/atmospherics/components/unary/rbmk/inlet/process_atmos()
    if (!parent_reactor || !parent_reactor.inlet_open)
        return

    var/datum/gas_mixture/in_mix = airs[1]
    if (!in_mix || in_mix.total_moles() <= 0)
        return

    var/amt = clamp(parent_reactor.inlet_rate / 1000, 0, 1)
    var/datum/gas_mixture/moved = in_mix.remove_ratio(amt)
    if (!moved || moved.total_moles() <= 0)
        return

    parent_reactor.coolant_internal.merge(moved)

    update_parents()
    SSair.add_to_active(src)



/*************************************************************
 * Outlet Component — Vents coolant OUT
 *************************************************************/

/// Outlet relieves overpressure
/obj/machinery/atmospherics/components/unary/rbmk/outlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Outlet"
    dir = EAST


/obj/machinery/atmospherics/components/unary/rbmk/outlet/process_atmos()
    if (!parent_reactor || !parent_reactor.outlet_open)
        return

    var/datum/gas_mixture/store = parent_reactor.coolant_internal
    if (!store || store.total_moles() <= 0)
        return

    var/current = store.return_pressure()
    var/target = parent_reactor.outlet_target_pressure
    if (current <= target)
        return

    var/excess_ratio = clamp((current - target) / max(target, 1), 0, 1)
    var/datum/gas_mixture/released = store.remove_ratio(excess_ratio)
    if (!released || released.total_moles() <= 0)
        return

    // Vent into connected pipe
    if (airs && airs.len)
        airs[1].merge(released)
        update_parents()
        SSair.add_to_active(src)
        return

    // Fallback: vent to turf
    var/turf/T = get_turf(src)
    if (T)
        T.assume_air(released)
        air_update_turf(T)



/*************************************************************
 * Initialization & Cleanup
 *************************************************************/

/// Create internal coolant reservoir
/proc/rbmk_init_coolant(obj/machinery/rbmk/reactor/reactor)
    if (!reactor)
        return

    reactor.coolant_internal = new /datum/gas_mixture()
    reactor.coolant_internal.volume = RBMK_COOLANT_VOLUME_MAX
    reactor.coolant_internal.temperature = RBMK_AMBIENT_TEMP

    reactor.coolant_pressure_history = list()
    reactor.coolant_temperature_history = list()
    reactor.coolant_total_moles_history = list()
    reactor.coolant_gas_hist = list()


/// Cleanup ports & coolant
/proc/rbmk_cleanup_atmos(obj/machinery/rbmk/reactor/reactor)
    if (reactor.inlet)
        qdel(reactor.inlet)
    if (reactor.outlet)
        qdel(reactor.outlet)

    QDEL_NULL(reactor.coolant_internal)



/*************************************************************
 * Rebuild inlet & outlet ports (REACTOR-OWNED)
 *************************************************************/

/// Build pipes west/east of the reactor
/obj/machinery/rbmk/reactor/proc/relink_ports()
    var/turf/center = get_turf(src)
    if (!center)
        return

    if (inlet)
        qdel(inlet)
    if (outlet)
        qdel(outlet)

    // Inlet (west)
    var/turf/in_tile = get_step(center, WEST)
    if (in_tile)
        var/obj/machinery/atmospherics/components/unary/rbmk/base/I
        I = new /obj/machinery/atmospherics/components/unary/rbmk/inlet(in_tile)
        I.parent_reactor = src
        I.dir = WEST
        inlet = I

    // Outlet (east)
    var/turf/out_tile = get_step(center, EAST)
    if (out_tile)
        var/obj/machinery/atmospherics/components/unary/rbmk/base/O
        O = new /obj/machinery/atmospherics/components/unary/rbmk/outlet(out_tile)
        O.parent_reactor = src
        O.dir = EAST
        outlet = O



/*************************************************************
 * Gas Accessors
 *************************************************************/

/// Inlet gas
/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
    return inlet ? inlet.airs[1] : null

/// Outlet gas
/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
    return outlet ? outlet.airs[1] : null

/// Internal coolant
/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
    return coolant_internal



/*************************************************************
 * Coolant Sampling (Telemetry)
 *************************************************************/

/// Update coolant telemetry history
/proc/rbmk_sample_coolant(obj/machinery/rbmk/reactor/reactor)
    var/datum/gas_mixture/mix = reactor.coolant_internal
    if (!mix)
        return

    reactor.coolant_pressure_history.Add(mix.return_pressure())
    if (reactor.coolant_pressure_history.len > 60)
        reactor.coolant_pressure_history.Cut(1, 2)

    reactor.coolant_temperature_history.Add(mix.temperature)
    if (reactor.coolant_temperature_history.len > 60)
        reactor.coolant_temperature_history.Cut(1, 2)

    reactor.coolant_total_moles_history.Add(mix.total_moles())
    if (reactor.coolant_total_moles_history.len > 60)
        reactor.coolant_total_moles_history.Cut(1, 2)

    var/total = mix.total_moles()
    if (total <= 0)
        return

    for (var/gas in mix.gases)
        var/list/g = mix.gases[gas]
        var/percent = (g[MOLES] / total) * 100

        var/list/history = reactor.coolant_gas_hist[gas]
        if (!history)
            history = reactor.coolant_gas_hist[gas] = list()

        history.Add(percent)
        if (history.len > 60)
            history.Cut(1, 2)
