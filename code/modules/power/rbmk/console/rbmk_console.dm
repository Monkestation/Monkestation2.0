/*************************************************************
 * RBMK Reactor Console (2025 Linear RBMK Final Version)
 * Medium clarity variable naming — no single letter vars.
 *************************************************************/


/*************************************************************
 * Console Definition
 *************************************************************/

/// RBMK control console
/obj/machinery/computer/rbmk_console
    name = "RBMK Reactor Console"
    desc = "A console used to monitor and control an RBMK nuclear reactor."
    icon = 'icons/obj/reactor_controller.dmi'
    icon_state = "reactorcontrol-1"
    density = TRUE
    anchored = TRUE

    bound_width = 96
    bound_height = 32
    bound_x = -32
    pixel_x = -32
    pixel_y = 0

    mouse_opacity = MOUSE_OPACITY_ICON
    layer = OBJ_LAYER
    plane = GAME_PLANE

    var/obj/machinery/rbmk/reactor/linked_reactor = null



/*************************************************************
 * Initialization / Cleanup
 *************************************************************/

/// Startup
/obj/machinery/computer/rbmk_console/Initialize(mapload)
    . = ..()
    auto_link()
    update_icon()

/// Cleanup
/obj/machinery/computer/rbmk_console/Destroy()
    linked_reactor = null
    return ..()



/*************************************************************
 * Reactor Linking & Console Visual State
 *************************************************************/

/// Automatically link to nearest RBMK reactor
/obj/machinery/computer/rbmk_console/proc/auto_link()
    linked_reactor = null
    var/shortest_distance_found = 999

    for (var/obj/machinery/rbmk/reactor/R in range(7, src))
        var/current_distance = get_dist(src, R)
        if (current_distance < shortest_distance_found)
            shortest_distance_found = current_distance
            linked_reactor = R

    update_icon()

/// Update console icon appearance based on reactor integrity
/obj/machinery/computer/rbmk_console/update_icon()
    . = ..()

    if (!linked_reactor)
        icon_state = "reactorcontrol-1"
        return

    var/integrity_value = linked_reactor.reactor_integrity
    var/max_integrity_value = linked_reactor.max_reactor_integrity

    if (integrity_value >= max_integrity_value * 0.7)
        icon_state = "reactorcontrol-1"
    else if (integrity_value >= max_integrity_value * 0.4)
        icon_state = "reactorcontrol-2"
    else
        icon_state = "reactorcontrol-3"



/*************************************************************
 * UI / TGUI Framework
 *************************************************************/

/// physical-only UI state
/obj/machinery/computer/rbmk_console/ui_state(mob/user)
    return GLOB.physical_state

/// Open TGUI
/obj/machinery/computer/rbmk_console/ui_interact(mob/user, datum/tgui/ui)
    . = ..()
    if (.) return .

    ui = SStgui.try_update_ui(user, src, ui)
    if (!ui)
        ui = new(user, src, "RBMKConsole", name)
        ui.open()

    return ui



/*************************************************************
 * Helper Utilities
 *************************************************************/

/// round to 0.01 precision
/proc/rbmk_round2(number_value)
    return round(number_value, 0.01)



/*************************************************************
 * UI DATA EXPORT (Telemetry)
 *************************************************************/

/// Export reactor telemetry to TGUI
/obj/machinery/computer/rbmk_console/ui_data(mob/user)
    var/list/data = list()

    if (!linked_reactor)
        data["status"] = "No reactor linked"
        return data

    data["control_rods"]     = rbmk_round2(linked_reactor.control_rod_depth)
    data["max_control_rod"]  = RBMK_CONTROL_ROD_MAX
    data["running"]          = linked_reactor.running
    data["scrammed"]         = linked_reactor.scrammed
    data["temperature"]      = rbmk_round2(linked_reactor.temperature)
    data["radiation"]        = rbmk_round2(linked_reactor.radiation)
    data["flux"]             = rbmk_round2(linked_reactor.flux)
    data["void_coefficient"] = rbmk_round2(linked_reactor.void_coefficient)
    data["integrity"]        = rbmk_round2(linked_reactor.reactor_integrity)
    data["max_integrity"]    = linked_reactor.max_reactor_integrity

    /* ---- Coolant / Valves ---- */
    data["inlet_open"]  = linked_reactor.inlet_open
    data["outlet_open"] = linked_reactor.outlet_open

    data["inlet_rate"] = linked_reactor.inlet_rate
    data["inlet_min"]  = RBMK_INLET_RATE_MIN
    data["inlet_max"]  = RBMK_INLET_RATE_MAX

    data["outlet_target_pressure"] = linked_reactor.outlet_target_pressure
    data["outlet_pressure_max"]    = RBMK_OUTLET_PRESSURE_MAX

    data["inlet_pressure"]  = linked_reactor.pressure
    data["outlet_pressure"] = linked_reactor.pressure

    data["pressure"] = list()
    for (var/pressure_value in linked_reactor.coolant_pressure_history)
        data["pressure"] += rbmk_round2(pressure_value)

    /* ---- Rod Inventory ---- */
    var/list/rods_list = list()

    for (var/slot_index = 1, slot_index <= linked_reactor.max_normal_slots, slot_index++)
        var/obj/item/rbmk/fuel_rod/rod_reference = null
        if (slot_index <= length(linked_reactor.normal_slots))
            rod_reference = linked_reactor.normal_slots[slot_index]

        rods_list += list(list(
            "type"       = rod_reference ? rod_reference.name : "Empty",
            "color"      = rod_reference ? rod_reference.rod_color : "grey",
            "depleted"   = rod_reference && !rod_reference.active,
            "slot_kind"  = "normal",
            "slot_index" = slot_index
        ))

    for (var/special_index = 1, special_index <= linked_reactor.max_special_slots, special_index++)
        var/obj/item/rbmk/fuel_rod/special_rod_reference = null
        if (special_index <= length(linked_reactor.special_slots))
            special_rod_reference = linked_reactor.special_slots[special_index]

        rods_list += list(list(
            "type"       = special_rod_reference ? special_rod_reference.name : "Empty",
            "color"      = special_rod_reference ? special_rod_reference.rod_color : "grey",
            "depleted"   = special_rod_reference && !special_rod_reference.active,
            "slot_kind"  = "special",
            "slot_index" = special_index
        ))

    data["rods"] = rods_list
    return data



/*************************************************************
 * UI ACTIONS
 *************************************************************/

/// Handle UI actions
/obj/machinery/computer/rbmk_console/ui_act(action, params)
    . = ..()
    if (.)
        return .

    if (!linked_reactor)
        if (action == "rescan")
            auto_link()
            return TRUE
        return FALSE


    /* ---- Control Rods ---- */

    if (action == "rod_up")
        linked_reactor.control_rod_depth = max(linked_reactor.control_rod_depth - 5, 0)
        linked_reactor.running = TRUE
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "rod_down")
        linked_reactor.control_rod_depth = min(
            linked_reactor.control_rod_depth + 5,
            RBMK_CONTROL_ROD_MAX
        )
        linked_reactor.running = TRUE
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "set_rods")
        var/requested_depth = clamp(
            text2num(params["depth"]),
            0,
            RBMK_CONTROL_ROD_MAX
        )
        linked_reactor.control_rod_depth = requested_depth
        linked_reactor.running = (requested_depth < RBMK_CONTROL_ROD_MAX)
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "scram")
        linked_reactor.force_scram()
        return TRUE


    /* ---- Coolant Controls ---- */

    if (action == "toggle_inlet")
        linked_reactor.inlet_open = !linked_reactor.inlet_open
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "set_inlet_rate")
        linked_reactor.inlet_rate = clamp(
            text2num(params["rate"]),
            RBMK_INLET_RATE_MIN,
            RBMK_INLET_RATE_MAX
        )
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "toggle_outlet")
        linked_reactor.outlet_open = !linked_reactor.outlet_open
        linked_reactor.update_linked_consoles()
        return TRUE

    if (action == "set_outlet_pressure")
        linked_reactor.outlet_target_pressure = clamp(
            text2num(params["pressure"]),
            0,
            RBMK_OUTLET_PRESSURE_MAX
        )
        linked_reactor.update_linked_consoles()
        return TRUE


    /* ---- Utility ---- */

    if (action == "rescan")
        auto_link()
        return TRUE

    return FALSE
