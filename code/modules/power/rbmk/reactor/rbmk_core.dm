/*************************************************************
 * RBMK Reactor Core (logic core = center of 3x3 footprint)
 * - Reactor anchored on center turf
 * - Spawns child shell tiles for 3x3 body
 * - Coolant inlet/outlet placed flush left/right of center
 * - Internal coolant reservoir added (14,000 L)
 *************************************************************/

/// RBMK Reactor
/obj/machinery/rbmk/reactor
    name = "RBMK Reactor Core"
    desc = "A massive nuclear reactor core. Insert rods at your own risk."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = "reactor_off"
    bound_width = 96
    bound_height = 96
    pixel_x = -32
    pixel_y = -32
    anchored = TRUE
    density = FALSE
    mouse_opacity = MOUSE_OPACITY_ICON
    plane = GAME_PLANE
    layer = OBJ_LAYER

    // Coolant IO
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

    // Children for 3x3 footprint
    var/list/children = list()

    // Fuel rod slots
    var/list/normal_slots = list()
    var/list/special_slots = list()
    var/max_normal_slots = 12
    var/max_special_slots = 4

    // Reactor state
    var/temperature = 0
    var/radiation = 0
    var/thermal_output = 0
    var/max_temp = 20000
    var/running = FALSE

    // Control rods
    var/control_rod_depth = 0

    // Flux / Instability (integrity handled in rbmk_integrity.dm)
    var/flux = 0
    var/instability = 0

    // Moderator tracking
    var/moderator_level = 0
    var/list/moderator_history = list()

	// Integrity variables
    var/max_reactor_integrity = 100
    var/reactor_integrity = 100
    var/repairable = FALSE

    // ---- Coolant valve/flow control ----
    var/inlet_open = TRUE
    var/outlet_open = TRUE

    var/inlet_rate = 1.0                   // liters/sec
    var/inlet_rate_min = 0.1
    var/inlet_rate_max = 2000.0

    var/outlet_target_pressure = 101.3     // regulator target kPa
    var/outlet_pressure_max = 25000        // hard ceiling

    // ---- Internal coolant tank ----
    var/datum/gas_mixture/coolant_internal
    var/coolant_volume_max = 14000  // liters cap

    // ---- Pressure Quick Reference ----
    var/pressure = 0

    // ---- Coolant telemetry histories ----
    var/list/coolant_pressure_history = list()
    var/list/coolant_temperature_history = list()
    var/list/coolant_total_moles_history = list()
    var/list/coolant_gas_hist = list()   // Assoc: gas_path -> percentages

/obj/machinery/rbmk/reactor/Initialize(mapload)
    . = ..()
    loc = locate(x+1, y+1, z)

    var/turf/T = get_turf(src)
    if (istype(T))
        var/datum/gas_mixture/env = T.return_air()
        temperature = env ? env.temperature : T0C + 20
    else
        temperature = T0C + 20

    // Create empty internal coolant tank
    coolant_internal = new
    coolant_internal.volume = coolant_volume_max

    START_PROCESSING(SSmachines, src)

    // Spawn child tiles
    for (var/dx in -1 to 1)
        for (var/dy in -1 to 1)
            if(dx == 0 && dy == 0)
                continue
            var/turf/CT = locate(x+dx, y+dy, z)
            if(CT)
                var/obj/structure/rbmk/reactor_child/C = new(CT)
                C.parent = src
                children += C

    // Place coolant ports
    relink_ports()

/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    for(var/C in children)
        qdel(C)
    if (inlet)  qdel(inlet)
    if (outlet) qdel(outlet)
    QDEL_NULL(coolant_internal)
    return ..()

/obj/machinery/rbmk/reactor/proc/relink_ports()
    var/turf/center = get_turf(src)
    if(!center) return

    if(inlet)  qdel(inlet)
    if(outlet) qdel(outlet)

    var/turf/inlet_tile = get_step(center, WEST)
    if(inlet_tile)
        inlet = new /obj/machinery/atmospherics/components/unary/rbmk/inlet(inlet_tile)
        inlet.parent_reactor = src
        inlet.dir = WEST

    var/turf/outlet_tile = get_step(center, EAST)
    if(outlet_tile)
        outlet = new /obj/machinery/atmospherics/components/unary/rbmk/outlet(outlet_tile)
        outlet.parent_reactor = src
        outlet.dir = EAST

/obj/machinery/rbmk/reactor/process(delta_time)
    if (!running)
        return

    var/rod_effect = (100 - control_rod_depth) / 100.0
    temperature = clamp(temperature + (rod_effect * 10) - (control_rod_depth * 0.05), 0, max_temp)

    radiation = clamp(temperature * 0.01 + flux * 2, 0, 500)
    instability = clamp(instability + rod_effect * 0.5 + (flux * 0.1), 0, 100)
    flux = clamp(flux + rod_effect * 2 - (moderator_level * 0.05), 0, 100)

    moderator_level = clamp(moderator_level - rod_effect * 0.2 + (control_rod_depth * 0.05), 0, 100)
    moderator_history += moderator_level
    if (length(moderator_history) > 50) moderator_history.Cut(1, 2)

    handle_coolant(delta_time)
    sample_coolant()

    // ✅ Use live coolant pressure for reactor telemetry
    if(coolant_internal)
        pressure = coolant_internal.return_pressure()

    update_linked_consoles()

/*************************************************************
 * Valve/Flow control
 *************************************************************/

/// Toggle valves
/obj/machinery/rbmk/reactor/proc/toggle_inlet()
    inlet_open = !inlet_open
    update_linked_consoles()
    return inlet_open

/obj/machinery/rbmk/reactor/proc/toggle_outlet()
    outlet_open = !outlet_open
    update_linked_consoles()
    return outlet_open

/// Set inlet flow rate
/obj/machinery/rbmk/reactor/proc/set_inlet_rate(val)
    inlet_rate = clamp(val, inlet_rate_min, inlet_rate_max)
    if(inlet)
        inlet.volume_rate = inlet_rate
    update_linked_consoles()
    return inlet_rate

/// Set outlet pressure regulator
/obj/machinery/rbmk/reactor/proc/set_outlet_pressure(val)
    outlet_target_pressure = clamp(val, 0, outlet_pressure_max)
    if(outlet)
        outlet.internal_pressure_bound = outlet_target_pressure
    update_linked_consoles()
    return outlet_target_pressure

/obj/machinery/rbmk/reactor/proc/get_flow_state()
    return list(
        "inlet_open" = inlet_open,
        "outlet_open" = outlet_open,
        "inlet_rate" = inlet_rate,
        "inlet_min" = inlet_rate_min,
        "inlet_max" = inlet_rate_max,
        "outlet_target_pressure" = outlet_target_pressure,
        "outlet_pressure_max" = outlet_pressure_max
    )

/*************************************************************
 * Pressure getters for console UI
 *************************************************************/

/// Pressure getters
/obj/machinery/rbmk/reactor/proc/get_inlet_pressure()
    var/datum/gas_mixture/in_mix = get_inlet_mix()
    if(in_mix) return in_mix.return_pressure()
    return 0

/obj/machinery/rbmk/reactor/proc/get_outlet_pressure()
    var/datum/gas_mixture/out_mix = get_outlet_mix()
    if(out_mix) return out_mix.return_pressure()
    return 0

/*************************************************************
 * Atmos integration
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

/// Prefer internal coolant
/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
    return coolant_internal

/// Sample coolant
/obj/machinery/rbmk/reactor/proc/sample_coolant()
    var/datum/gas_mixture/mix = coolant_internal
    if(!mix) return

    var/press = mix.return_pressure()
    var/temp  = mix.temperature
    var/total = mix.total_moles()

    coolant_pressure_history += press
    if(length(coolant_pressure_history) > 50) coolant_pressure_history.Cut(1, 2)

    coolant_temperature_history += temp
    if(length(coolant_temperature_history) > 50) coolant_temperature_history.Cut(1, 2)

    coolant_total_moles_history += total
    if(length(coolant_total_moles_history) > 50) coolant_total_moles_history.Cut(1, 2)

    if(total <= 0)
        for (var/gp in coolant_gas_hist)
            var/list/L = coolant_gas_hist[gp]
            L += 0
            if(length(L) > 50) L.Cut(1, 2)
        return

    for (var/gas_path in mix.gases)
        var/moles = mix.gases[gas_path][MOLES]
        var/percent = clamp((moles / total) * 100, 0, 100)
        if(!(gas_path in coolant_gas_hist))
            coolant_gas_hist[gas_path] = list()
        var/list/series = coolant_gas_hist[gas_path]
        series += percent
        if(length(series) > 50) series.Cut(1, 2)

    for (var/existing_gas_path in coolant_gas_hist)
        if(!(existing_gas_path in mix.gases))
            var/list/series2 = coolant_gas_hist[existing_gas_path]
            series2 += 0
            if(length(series2) > 50) series2.Cut(1, 2)

/// Handle coolant exchange
/obj/machinery/rbmk/reactor/proc/handle_coolant(seconds_per_tick)
    if(!coolant_internal) return

    // --- Inlet -> internal
    if(inlet_open && inlet)
        var/datum/gas_mixture/in_mix = get_inlet_mix()
        if(in_mix && in_mix.total_moles() > 0)
            if(coolant_internal.total_moles() < coolant_internal.volume)
                var/amt = clamp(inlet_rate / 100, 0, 1)
                var/datum/gas_mixture/moved_in = in_mix.remove_ratio(amt)
                if(moved_in && moved_in.total_moles() > 0)
                    coolant_internal.merge(moved_in)

    // --- Internal -> outlet
    if(outlet_open && outlet && coolant_internal.total_moles() > 0)
        // baseline flow proportional to inlet rate
        var/flow_ratio = clamp(inlet_rate / inlet_rate_max, 0, 1)
        var/datum/gas_mixture/moved_out = coolant_internal.remove_ratio(flow_ratio * 0.05)
        if(moved_out && moved_out.total_moles() > 0)
            outlet.airs[1].merge(moved_out)

        // regulator release if pressure too high
        if(coolant_internal.return_pressure() > outlet_target_pressure)
            var/release_ratio = clamp((coolant_internal.return_pressure() - outlet_target_pressure) / 100, 0, 1)
            var/datum/gas_mixture/released = coolant_internal.remove_ratio(release_ratio)
            if(released && released.total_moles() > 0)
                outlet.airs[1].merge(released)

/*************************************************************
 * UI fanout
 *************************************************************/

/// Update linked consoles
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for (var/obj/machinery/computer/rbmk_console/C in world)
        if (C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)

/*************************************************************
 * Reactor Child Tiles
 *************************************************************/

/// Children
/obj/structure/rbmk/reactor_child
    name = "RBMK Reactor Core"
    desc = "Part of a massive nuclear reactor core."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = ""
    anchored = TRUE
    density = FALSE
    mouse_opacity = MOUSE_OPACITY_ICON
    var/obj/machinery/rbmk/reactor/parent

/obj/structure/rbmk/reactor_child/attackby(obj/item/I, mob/user, params)
    if(parent)
        return parent.attackby(I, user, params)
    return ..()

/obj/structure/rbmk/reactor_child/attack_hand(mob/user)
    if(parent)
        return parent.attack_hand(user)
    return ..()

/*************************************************************
 * Atmos I/O Components
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

    var/volume_rate = 1.0
    var/internal_pressure_bound = 101.3

/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
    . = ..()
    airs = list(new /datum/gas_mixture())
    initialize_directions = dir
    connect_nodes()
    update_parents()

/obj/machinery/atmospherics/components/unary/rbmk/inlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Inlet"
    dir = WEST

/obj/machinery/atmospherics/components/unary/rbmk/outlet
    parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
    name = "RBMK Coolant Outlet"
    dir = EAST
