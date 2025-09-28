// rbmk_process.dm
// Handles per-tick reactor operations

/obj/machinery/rbmk/reactor/process(delta_time)
    // --- Repairable if cool enough ---
    repairable = (temperature < (max_temp * 0.7))

    // --- If not running, idle cooling ---
    if(!running)
        // bleed heat to ambient + coolant loop if any
        if(temperature > 293)
            temperature = max(293, temperature - 5)
            handle_coolant(delta_time)
            update_reactor_icon()
        else
            icon_state = "reactor_off"
            set_light(0)
        update_linked_consoles()
        return

    // --- Reset per-tick values ---
    radiation = 0
    thermal_output = 0
    flux = 0
    var/has_active_rods = FALSE
    var/thermal_mult = 1
    var/flux_mult = 1

    // --- Process rods ---
    for(var/obj/item/rbmk/fuel_rod/R in normal_slots + special_slots)
        if(!R || !R.active)
            continue

        var/contrib = R.process_rod()

        // Base contributions
        flux        += contrib["flux"]
        radiation   += contrib["radiation"]
        temperature += contrib["heat"]

        // Multipliers
        if("thermal_mult" in contrib)
            thermal_mult *= contrib["thermal_mult"]
        if("flux_mult" in contrib)
            flux_mult *= contrib["flux_mult"]

        if(contrib["flux"] > 0 || contrib["heat"] > 0 || contrib["radiation"] > 0)
            has_active_rods = TRUE

    // --- Apply control rod scaling ---
    var/rod_effect = (100 - control_rod_depth) / 100
    flux           = round((flux * flux_mult) * rod_effect)
    thermal_output = round(((temperature * 0.1) * thermal_mult) * rod_effect)
    radiation      = round(radiation * rod_effect)

    // --- Coolant loop integration ---
    handle_coolant(delta_time)

    // --- Natural decay ---
    flux = max(0, flux - 1)
    radiation = max(0, radiation - 0.5)

    // --- Instability ---
    update_instability()

    // --- Integrity ---
    update_reactor_integrity()

    // --- Running state logic ---
    if(!has_active_rods)
        running = FALSE
    else if(control_rod_depth < 100)
        running = TRUE   // restart allowed after SCRAM if rods raised

    // --- Visuals & consoles ---
    update_reactor_icon()
    update_linked_consoles()
