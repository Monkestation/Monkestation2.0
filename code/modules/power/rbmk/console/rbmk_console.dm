/*************************************************************
 * RBMK Reactor Console (Monke TG-Style Final Revision, Cleaned)
 * - Handles reactor monitoring and limited control
 * - Visuals handled strictly via icon_state
 * - Fully clickable 3×1 bounds layout
 * - Clean variable naming for maintainability
 *************************************************************/

/*************************************************************
 * Console Core Definition
 *************************************************************/

/// Primary control console
/obj/machinery/computer/rbmk_console
    name = "RBMK Reactor Console"
    desc = "A console used to monitor and control an RBMK nuclear reactor."
    icon = 'icons/obj/reactor_controller.dmi'
    icon_state = "reactorcontrol-1"
    density = TRUE
    anchored = TRUE

    // --- Bounds-based 3×1 layout ---
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

/// Initialize console
/obj/machinery/computer/rbmk_console/Initialize(mapload)
    . = ..()
    auto_link()
    update_icon()

/// Cleanup
/obj/machinery/computer/rbmk_console/Destroy()
    linked_reactor = null
    return ..()


/*************************************************************
 * Linking & Visuals
 *************************************************************/

/// Automatically link to nearest reactor in range
/obj/machinery/computer/rbmk_console/proc/auto_link()
    linked_reactor = null
    var/shortest_distance = 999

    for (var/obj/machinery/rbmk/reactor/reactorCandidate in range(7, src))
        var/distance = get_dist(src, reactorCandidate)
        if (distance < shortest_distance)
            linked_reactor = reactorCandidate
            shortest_distance = distance

    update_icon()

/// Update visuals based on reactor integrity
/obj/machinery/computer/rbmk_console/update_icon()
    . = ..()
    if (!linked_reactor)
        icon_state = "reactorcontrol-1"
        return

    var/currentIntegrity = linked_reactor.reactor_integrity
    var/maxIntegrity = linked_reactor.max_reactor_integrity

    if (currentIntegrity >= (maxIntegrity * 0.7))
        icon_state = "reactorcontrol-1"
    else if (currentIntegrity >= (maxIntegrity * 0.4))
        icon_state = "reactorcontrol-2"
    else
        icon_state = "reactorcontrol-3"


/*************************************************************
 * TGUI / UI Layer
 *************************************************************/

/// Use global physical state
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


/*************************************************************
 * UI Data Export (Clean 2-decimal Output)
 *************************************************************/

/// Round helper for 2-decimal precision
/proc/rbmk_round2(x)
    return round(x, 0.01)


/// Main console → UI payload
/obj/machinery/computer/rbmk_console/ui_data(mob/user)
    var/list/data = list()

    if (!linked_reactor)
        data["status"] = "No reactor linked"
        return data

    // --- Primary telemetry (rounded to 2 decimals) ---
    data["control_rods"]   = rbmk_round2(linked_reactor.control_rod_depth)
    data["running"]        = linked_reactor.running
    data["temperature"]    = rbmk_round2(linked_reactor.temperature)
    data["instability"]    = rbmk_round2(linked_reactor.instability)
    data["radiation"]      = rbmk_round2(linked_reactor.radiation)
    data["flux"]           = rbmk_round2(linked_reactor.flux)
    data["integrity"]      = rbmk_round2(linked_reactor.reactor_integrity)
    data["max_integrity"]  = linked_reactor.max_reactor_integrity

    // --- History data ---
    data["pressure"] = list()
    for (var/p in linked_reactor.coolant_pressure_history)
        data["pressure"] += rbmk_round2(p)

    data["moderator"] = list()
    for (var/m in linked_reactor.moderator_history)
        data["moderator"] += rbmk_round2(m)

    /*************************************************************
     * Rod Data
     *************************************************************/
    var/list/rods_list = list()

    for (var/slotIndex = 1, slotIndex <= linked_reactor.max_normal_slots, slotIndex++)
        var/obj/item/rbmk/fuel_rod/normalRod = (slotIndex <= length(linked_reactor.normal_slots)) ? linked_reactor.normal_slots[slotIndex] : null
        rods_list += list(list(
            "type" = normalRod ? normalRod.name : "Empty",
            "color" = normalRod ? normalRod.rod_color : "grey",
            "depleted" = (normalRod && !normalRod.active),
            "slot_kind" = "normal",
            "slot_index" = slotIndex
        ))

    for (var/specialIndex = 1, specialIndex <= linked_reactor.max_special_slots, specialIndex++)
        var/obj/item/rbmk/fuel_rod/specialRod = (specialIndex <= length(linked_reactor.special_slots)) ? linked_reactor.special_slots[specialIndex] : null
        rods_list += list(list(
            "type" = specialRod ? specialRod.name : "Empty",
            "color" = specialRod ? specialRod.rod_color : "grey",
            "depleted" = (specialRod && !specialRod.active),
            "slot_kind" = "special",
            "slot_index" = specialIndex
        ))

    data["rods"] = rods_list

    /*************************************************************
     * Coolant & Pressure Data
     *************************************************************/
    data["inlet_open"]  = linked_reactor.inlet_open
    data["outlet_open"] = linked_reactor.outlet_open
    data["inlet_rate"]  = rbmk_round2(linked_reactor.inlet_rate)
    data["inlet_min"]   = RBMK_INLET_RATE_MIN
    data["inlet_max"]   = RBMK_INLET_RATE_MAX
    data["outlet_target_pressure"] = rbmk_round2(linked_reactor.outlet_target_pressure)
    data["outlet_pressure_max"]    = RBMK_OUTLET_PRESSURE_MAX
    data["pressure_now"]           = rbmk_round2(linked_reactor.pressure)

    /*************************************************************
     * Gas Composition Snapshot (2 decimals)
     *************************************************************/
    var/list/gas_comp = list()
    if (linked_reactor.coolant_internal)
        var/datum/gas_mixture/mix = linked_reactor.coolant_internal
        var/total_moles = mix.total_moles()

        if (total_moles > 0)
            for (var/gas_path in mix.gases)
                var/moles = mix.gases[gas_path][MOLES]
                var/percent = rbmk_round2((moles / total_moles) * 100)
                var/datum/gas/gasType = new gas_path()
                gas_comp[gasType.id] = list(
                    "percent" = percent
                )

    data["gas_composition"] = gas_comp

    return data


/*************************************************************
 * UI Actions
 *************************************************************/

/// Handle UI input actions
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
            linked_reactor.control_rod_depth = RBMK_CONTROL_ROD_MAX
            linked_reactor.running = FALSE
            visible_message(span_danger("[name]: Emergency SCRAM! All control rods fully inserted!"))
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("rod_up")
            linked_reactor.control_rod_depth = max(linked_reactor.control_rod_depth - 5, 0)
            if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("rod_down")
            linked_reactor.control_rod_depth = min(linked_reactor.control_rod_depth + 5, RBMK_CONTROL_ROD_MAX)
            if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("set_rods")
            var/desiredDepth = clamp(text2num(params["depth"]), 0, RBMK_CONTROL_ROD_MAX)
            linked_reactor.control_rod_depth = desiredDepth
            if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
                linked_reactor.running = TRUE
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("remove_rod")
            var/slotKind = params?["kind"]
            var/slotIndex = clamp(text2num(params?["index"]), 1, 1000)
            var/obj/item/rbmk/fuel_rod/rodToEject = null

            if (slotKind == "normal" && slotIndex <= length(linked_reactor.normal_slots))
                rodToEject = linked_reactor.normal_slots[slotIndex]
                if (rodToEject)
                    linked_reactor.normal_slots.Cut(slotIndex, slotIndex + 1)
                    rodToEject.loc = get_turf(linked_reactor)
                    visible_message(span_notice("[name]: Ejected [rodToEject.name] from normal slot #[slotIndex]!"))

            else if (slotKind == "special" && slotIndex <= length(linked_reactor.special_slots))
                rodToEject = linked_reactor.special_slots[slotIndex]
                if (rodToEject)
                    linked_reactor.special_slots.Cut(slotIndex, slotIndex + 1)
                    rodToEject.loc = get_turf(linked_reactor)
                    visible_message(span_notice("[name]: Ejected [rodToEject.name] from special slot #[slotIndex]!"))

            linked_reactor.update_linked_consoles()
            return TRUE

        if ("set_inlet_rate")
            var/newRate = clamp(text2num(params["rate"]), RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
            linked_reactor.set_inlet_rate(newRate)
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("set_outlet_pressure")
            var/newPressure = clamp(text2num(params["pressure"]), 0, RBMK_OUTLET_PRESSURE_MAX)
            linked_reactor.set_outlet_pressure(newPressure)
            linked_reactor.update_linked_consoles()
            return TRUE

        if ("toggle_inlet")
            linked_reactor.toggle_inlet()
            return TRUE

        if ("toggle_outlet")
            linked_reactor.toggle_outlet()
            return TRUE

        if ("rescan")
            auto_link()
            return TRUE

    return FALSE
