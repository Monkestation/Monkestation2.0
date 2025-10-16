/*************************************************************
 * RBMK Process Logic
 * - Runs every tick while the reactor is active
 * - Handles rods, flux, heat, radiation, coolant interaction
 *************************************************************/

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

                // Record gas history snapshot
                var/datum/gas_mixture/mix = coolant_internal
                var/total = mix.total_moles()
                if(total > 0)
                    var/list/snapshot = list()
                    for(var/gas_path in mix.gases)
                        var/moles = mix.gases[gas_path][MOLES]
                        var/percent = (moles / total) * 100
                        snapshot[gas_path] = percent
                    coolant_gas_hist += list(snapshot)
                    if(length(coolant_gas_hist) > 50)
                        coolant_gas_hist.Cut(1, 2)

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

    // --- Transfer heat to coolant ---
    rbmk_coolant_exchange(src)

    // --- Coolant loop integration ---
    rbmk_sample_coolant(src)
    if(coolant_internal)
        pressure = coolant_internal.return_pressure()

        // Record gas history snapshot
        var/datum/gas_mixture/mix = coolant_internal
        var/total = mix.total_moles()
        if(total > 0)
            var/list/snapshot = list()
            for(var/gas_path in mix.gases)
                var/moles = mix.gases[gas_path][MOLES]
                var/percent = (moles / total) * 100
                snapshot[gas_path] = percent
            coolant_gas_hist += list(snapshot)
            if(length(coolant_gas_hist) > 50)
                coolant_gas_hist.Cut(1, 2)

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


/*************************************************************
 * RBMK Coolant Energy Exchange
 * - Moves thermal energy between core and coolant_internal
 *************************************************************/

/// Reactor-to-coolant heat & pressure transfer
/proc/rbmk_coolant_exchange(obj/machinery/rbmk/reactor/R)
    if(!R || !R.coolant_internal)
        return

    var/datum/gas_mixture/mix = R.coolant_internal
    var/temp_diff = R.temperature - mix.temperature
    if(abs(temp_diff) < 0.5)
        return

    // --- Gas-based efficiency curve ---
    var/efficiency = 1.0
    for(var/gas_path in mix.gases)
        switch(gas_path)
            if(/datum/gas/nitrogen)        efficiency += 0.10
            if(/datum/gas/carbon_dioxide)  efficiency += 0.25
            if(/datum/gas/oxygen)          efficiency -= 0.05
            if(/datum/gas/plasma)          efficiency -= 0.40

    // --- Thermal transfer ---
    var/transfer = temp_diff * 0.03 * efficiency
    R.temperature -= transfer
    mix.temperature += transfer * 0.5

    // --- Pressure response ---
    var/new_pressure = mix.return_pressure() + (transfer / 50)
    if(new_pressure > RBMK_PRESSURE_CRITICAL)
        R.instability += 5
    R.pressure = clamp(new_pressure, 0, RBMK_PRESSURE_EXTREME)

    // --- Waste gas buildup ---
    mix.assert_gases(/datum/gas/oxygen)
    mix.gases[/datum/gas/oxygen][MOLES] += clamp(transfer / 2000, 0, 10)

    // --- History ---
    R.coolant_pressure_history += R.pressure
    if(length(R.coolant_pressure_history) > 50)
        R.coolant_pressure_history.Cut(1, 2)
