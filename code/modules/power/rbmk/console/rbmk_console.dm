/obj/machinery/computer/rbmk_console
    name = "RBMK Reactor Console"
    desc = "A console used to monitor and control an RBMK nuclear reactor."
    icon = 'icons/obj/reactor_controller.dmi'
    icon_state = "reactorcontrol-1"
    density = TRUE
    anchored = TRUE

    var/obj/machinery/rbmk/reactor/linked_reactor = null
    var/list/children = list()   // east-side child overlays

/obj/machinery/computer/rbmk_console/Initialize(mapload)
    . = ..()
    auto_link()
    spawn_children()
    update_icon()

/obj/machinery/computer/rbmk_console/Destroy()
    for (var/obj/structure/rbmk_console_child/C in children)
        if (C) qdel(C)
    children.Cut()
    return ..()

/obj/machinery/computer/rbmk_console/proc/auto_link()
    linked_reactor = null
    for (var/obj/machinery/rbmk/reactor/R in range(7, src))
        linked_reactor = R
        break
    update_icon()

/obj/machinery/computer/rbmk_console/proc/spawn_children()
    // Console is 3x1, parent on westmost tile
    var/turf/T1 = get_step(src, EAST)
    var/turf/T2 = get_step(T1, EAST)

    if (T1)
        var/obj/structure/rbmk_console_child/C1 = new(T1)
        C1.parent_console = src
        children += C1

    if (T2)
        var/obj/structure/rbmk_console_child/C2 = new(T2)
        C2.parent_console = src
        children += C2

/obj/machinery/computer/rbmk_console/update_icon()
    . = ..()
    if (!linked_reactor)
        icon_state = "reactorcontrol-1"
        return

    var/integrity = linked_reactor.reactor_integrity
    var/max_integrity = linked_reactor.max_reactor_integrity

    if (integrity >= (max_integrity * 0.66))
        icon_state = "reactorcontrol-1"
    else if (integrity >= (max_integrity * 0.33))
        icon_state = "reactorcontrol-2"
    else
        icon_state = "reactorcontrol-3"

/obj/machinery/computer/rbmk_console/ui_state(mob/user)
    return GLOB.physical_state

/obj/machinery/computer/rbmk_console/ui_status(mob/user)
    return ..()

/obj/machinery/computer/rbmk_console/ui_interact(mob/user, datum/tgui/ui)
    . = ..()
    if (.) return .

    ui = SStgui.try_update_ui(user, src, ui)
    if (!ui)
        ui = new(user, src, "RBMKConsole", name)
        ui.open()
    return ui

/obj/machinery/computer/rbmk_console/ui_data(mob/user)
    var/list/data = list()
    if (!linked_reactor)
        data["status"] = "No reactor linked"
        return data

    data["control_rods"]   = linked_reactor.control_rod_depth
    data["temperature"]    = linked_reactor.temperature || 0
    data["instability"]    = linked_reactor.instability || 0
    data["radiation"]      = linked_reactor.radiation || 0
    data["flux"]           = linked_reactor.flux || 0
    data["integrity"]      = linked_reactor.reactor_integrity || 0
    data["max_integrity"]  = linked_reactor.max_reactor_integrity || 100

    if (!linked_reactor.pressure_history)
        linked_reactor.pressure_history = list()
    if (!linked_reactor.moderator_history)
        linked_reactor.moderator_history = list()

    data["pressure"]  = linked_reactor.pressure_history
    data["moderator"] = linked_reactor.moderator_history

    // --- Rod slots ---
    var/list/rods_list = list()
    for (var/i = 1, i <= linked_reactor.max_normal_slots, i++)
        var/obj/item/rbmk/fuel_rod/R = (i <= length(linked_reactor.normal_slots)) ? linked_reactor.normal_slots[i] : null
        rods_list += list(list(
            "type" = R ? R.name : "Empty",
            "color" = R ? R.rod_color : "grey",
            "depleted" = (R && !R.active),
            "slot_kind" = "normal",
            "slot_index" = i
        ))
    for (var/j = 1, j <= linked_reactor.max_special_slots, j++)
        var/obj/item/rbmk/fuel_rod/RS = (j <= length(linked_reactor.special_slots)) ? linked_reactor.special_slots[j] : null
        rods_list += list(list(
            "type" = RS ? RS.name : "Empty",
            "color" = RS ? RS.rod_color : "grey",
            "depleted" = (RS && !RS.active),
            "slot_kind" = "special",
            "slot_index" = j
        ))
    data["rods"] = rods_list

    // --- Coolant state ---
    data["inlet_open"]  = linked_reactor.inlet_open
    data["outlet_open"] = linked_reactor.outlet_open

    // Inlet live state
    if (linked_reactor.inlet)
        data["inlet_rate"] = linked_reactor.inlet.volume_rate
    else
        data["inlet_rate"] = linked_reactor.inlet_rate
    data["inlet_min"]      = linked_reactor.inlet_rate_min
    data["inlet_max"]      = linked_reactor.inlet_rate_max
    data["inlet_pressure"] = round(max(linked_reactor.get_inlet_pressure(), 0), 0.1)

    // Outlet live state
    if (linked_reactor.outlet)
        data["outlet_target_pressure"] = linked_reactor.outlet.internal_pressure_bound
    else
        data["outlet_target_pressure"] = linked_reactor.outlet_target_pressure
    data["outlet_pressure_max"] = linked_reactor.outlet_pressure_max
    data["outlet_pressure"]     = round(max(linked_reactor.get_outlet_pressure(), 0), 0.1)

    return data

/obj/machinery/computer/rbmk_console/ui_act(action, params)
    . = ..()
    if (.) return .
    if (!linked_reactor)
        if (action == "rescan")
            auto_link()
            return TRUE
        return

    switch(action)
        if ("scram")
            linked_reactor.control_rod_depth = 100
            linked_reactor.running = FALSE
            visible_message(span_danger("All control rods fully inserted!"))
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("rod_up")
            linked_reactor.control_rod_depth = max(linked_reactor.control_rod_depth - 5, 0)
            if (linked_reactor.control_rod_depth < 100)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("rod_down")
            linked_reactor.control_rod_depth = min(linked_reactor.control_rod_depth + 5, 100)
            if (linked_reactor.control_rod_depth < 100)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("set_rods")
            var/depth = clamp(text2num(params["depth"]), 0, 100)
            linked_reactor.control_rod_depth = depth
            if (linked_reactor.control_rod_depth < 100)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("remove_rod")
            var/kind = params?["kind"]
            var/index = clamp(text2num(params?["index"]), 1, 1000)
            if (kind == "normal" && index <= length(linked_reactor.normal_slots))
                var/obj/item/rbmk/fuel_rod/R = linked_reactor.normal_slots[index]
                if (R)
                    linked_reactor.normal_slots.Cut(index, index+1)
                    R.loc = get_turf(linked_reactor)
                    linked_reactor.update_linked_consoles()
                    return TRUE
            else if (kind == "special" && index <= length(linked_reactor.special_slots))
                var/obj/item/rbmk/fuel_rod/RS = linked_reactor.special_slots[index]
                if (RS)
                    linked_reactor.special_slots.Cut(index, index+1)
                    RS.loc = get_turf(linked_reactor)
                    linked_reactor.update_linked_consoles()
                    return TRUE
            return FALSE

        if ("rescan")
            auto_link()
            return TRUE

        // ---- NEW: Coolant controls ----
        if ("set_inlet_rate")
            var/rate = text2num(params["rate"])
            if (linked_reactor.inlet)
                linked_reactor.inlet.volume_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
            linked_reactor.set_inlet_rate(rate)
            return TRUE

        if ("set_outlet_pressure")
            var/press = text2num(params["pressure"])
            if (linked_reactor.outlet)
                linked_reactor.outlet.internal_pressure_bound = clamp(press, 0, ATMOS_PUMP_MAX_PRESSURE)
            linked_reactor.set_outlet_pressure(press)
            return TRUE

        if ("toggle_inlet")
            linked_reactor.toggle_inlet()
            return TRUE

        if ("toggle_outlet")
            linked_reactor.toggle_outlet()
            return TRUE

    return FALSE

/*************************************************************
 * CHILD TILE OBJECT (overlay only)
 *************************************************************/

/obj/structure/rbmk_console_child
    name = "RBMK Reactor Console"
    desc = "Part of a large RBMK reactor control panel."
    icon = 'icons/obj/reactor_controller.dmi'
    icon_state = "reactorcontrol-side"
    density = TRUE
    anchored = TRUE
    var/obj/machinery/computer/rbmk_console/parent_console = null

/obj/structure/rbmk_console_child/ui_interact(mob/user, datum/tgui/ui)
    if (parent_console)
        return parent_console.ui_interact(user, ui)
    return ..()

/obj/structure/rbmk_console_child/attack_hand(mob/user)
    if (parent_console)
        return parent_console.attack_hand(user)
    return ..()

/obj/structure/rbmk_console_child/Destroy()
    parent_console = null
    return ..()
