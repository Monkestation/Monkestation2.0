/// rbmk_process.dm
// Handles per-tick reactor operations

/obj/machinery/rbmk/reactor/process(delta_time)
    // --- Repairable if cool enough ---
    repairable = (temperature < (RBMK_MAX_TEMP * RBMK_REPAIRABLE_TEMP_RATIO))

    // --- If not running, idle cooling ---
    if(!running)
        if(temperature > RBMK_AMBIENT_TEMP)
            temperature = max(RBMK_AMBIENT_TEMP, temperature - RBMK_IDLE_COOL_RATE)

            // Sample coolant even when idle
            rbmk_sample_coolant(src)
            if(coolant_internal)
                pressure = coolant_internal.return_pressure()

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
    thermal_output = round(((temperature * RBMK_HEAT_SCALING) * thermal_mult) * rod_effect)
    radiation      = round(radiation * rod_effect)

    // --- Coolant loop integration ---
    rbmk_sample_coolant(src)
    if(coolant_internal)
        pressure = coolant_internal.return_pressure()

    // --- Natural decay ---
    flux = max(0, flux - RBMK_FLUX_DECAY)
    radiation = max(0, radiation - RBMK_RADIATION_DECAY)

    // --- Instability ---
    update_instability()

    // --- Integrity ---
    update_reactor_integrity()

    // --- Running state logic ---
    if(!has_active_rods)
        running = FALSE
    else if(control_rod_depth < RBMK_CONTROL_ROD_MAX)
        running = TRUE

    // --- Visuals & consoles ---
    update_reactor_icon()
    update_linked_consoles()
