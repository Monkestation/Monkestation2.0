/*************************************************************
 * RBMK Process Logic
 * - Runs every tick while the reactor is active
 * - Handles rods, flux, heat, radiation, coolant interaction
 *************************************************************/

/// Main process loop
/obj/machinery/rbmk/reactor/process(delta_time)
    // --- Repairable if cool enough ---
    repairable = (temperature < (RBMK_MAX_TEMP * RBMK_REPAIRABLE_TEMP_RATIO))

    // --- If not running, idle cooling ---
    if(!running)
        if(temperature > RBMK_AMBIENT_TEMP)
            temperature = max(RBMK_AMBIENT_TEMP, temperature - RBMK_IDLE_COOL_RATE)

            rbmk_sample_coolant(src)
            if(coolant_internal)
                pressure = coolant_internal.return_pressure()
                rbmk_record_gas_snapshot()
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
    var/thermal_mult = 1.0
    var/flux_mult = 1.0

    /*************************************************************
     * Internal Rod Data Processing
     *************************************************************/

    var/new_normal_slots = list()
    var/new_special_slots = list()

    for(var/i in 1 to length(normal_slots))
        var/rod_data = normal_slots[i]
        if(!rod_data)
            new_normal_slots += null
            continue
        var/result = rbmk_process_rod_data(rod_data)
        if(result)
            flux        += result["flux"]
            radiation   += result["radiation"]
            temperature += result["heat"]
            if("thermal_mult" in result)
                thermal_mult *= result["thermal_mult"]
            if("flux_mult" in result)
                flux_mult *= result["flux_mult"]
            if(rod_data["fuel_amount"] > 0)
                new_normal_slots += rod_data
                has_active_rods = TRUE
            else
                new_normal_slots += null
        else
            new_normal_slots += null

    for(var/i in 1 to length(special_slots))
        var/rod_data = special_slots[i]
        if(!rod_data)
            new_special_slots += null
            continue
        var/result = rbmk_process_rod_data(rod_data)
        if(result)
            flux        += result["flux"]
            radiation   += result["radiation"]
            temperature += result["heat"]
            if("thermal_mult" in result)
                thermal_mult *= result["thermal_mult"]
            if("flux_mult" in result)
                flux_mult *= result["flux_mult"]
            if(rod_data["fuel_amount"] > 0)
                new_special_slots += rod_data
                has_active_rods = TRUE
            else
                new_special_slots += null
        else
            new_special_slots += null

    normal_slots = new_normal_slots
    special_slots = new_special_slots

    /*************************************************************
     * Special rod behaviors
     *************************************************************/

    // Telecrystal rods charge if reactor is hot enough
    for(var/rod_data in special_slots)
        if(!rod_data) continue
        if(rod_data["rod_type"] == "telecrystal")
            if(thermal_output >= 2000)
                var/prog = rod_data["charge_progress"]
                var/maxp = rod_data["charge_max"]
                var/rate = 1
                if(thermal_output >= 10000)
                    rate = 3
                else if(thermal_output >= 5000)
                    rate = 2
                prog += rate
                if(prog >= maxp && !rod_data["charged"])
                    rod_data["charged"] = TRUE
                    to_chat(src, span_warning("A telecrystal rod hums violently as it finishes charging with bluespace energy!"))
                rod_data["charge_progress"] = prog

        else if(rod_data["rod_type"] == "supermatter" && prob(2))
            trigger_meltdown("Supermatter destabilization!")

    /*************************************************************
     * Post-processing and cooling
     *************************************************************/

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
        rbmk_record_gas_snapshot()

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
 * Helper: process individual rod data entries
 *************************************************************/

/// Processes a stored rod data entry
/proc/rbmk_process_rod_data(list/rod_data)
    if(!rod_data)
        return null

    // Burn fuel unless infinite
    if(rod_data["fuel_amount"] != INFINITY)
        rod_data["fuel_amount"] -= 1

    if(rod_data["fuel_amount"] <= 0)
        return null

    return list(
        "flux"         = rod_data["flux_output"] * rod_data["flux_mult"],
        "heat"         = rod_data["heat_per_tick"] * rod_data["thermal_mult"],
        "radiation"    = rod_data["rad_output"] * rod_data["rad_mult"],
        "thermal_mult" = rod_data["thermal_mult"],
        "flux_mult"    = rod_data["flux_mult"]
    )


/*************************************************************
 * Helper: record gas mix snapshot for console graphs
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/rbmk_record_gas_snapshot()
    if(!coolant_internal)
        return
    var/datum/gas_mixture/mix = coolant_internal
    var/total = mix.total_moles()
    if(total <= 0)
        return
    var/list/snapshot = list()
    for(var/gas_path in mix.gases)
        var/moles = mix.gases[gas_path][MOLES]
        var/percent = (moles / total) * 100
        snapshot[gas_path] = percent
    coolant_gas_hist += list(snapshot)
    if(length(coolant_gas_hist) > 50)
        coolant_gas_hist.Cut(1, 2)


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
