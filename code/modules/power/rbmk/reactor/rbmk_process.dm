/*************************************************************
 * RBMK Process Logic (Rod-Driven Core Model)
 * FINAL 2025 – Balanced & Stable Revision
 *************************************************************/

/// Main process loop
/obj/machinery/rbmk/reactor/process(delta_time)
    if (reactor_integrity <= 0)
        running = FALSE
        return

    // --- Mark repairable state ---
    repairable = (temperature < (RBMK_MAX_TEMP * RBMK_REPAIRABLE_TEMP_RATIO))

    /*************************************************************
     * Control Rod Auto-Shutdown
     *************************************************************/
    if (control_rod_depth >= RBMK_CONTROL_ROD_MAX)
        if (running)
            running = FALSE
            scrammed = TRUE
            to_chat(src, span_notice("Control rods fully inserted — reactor shutting down."))
        rbmk_decay_process(src)
        update_linked_consoles()
        return

    /*************************************************************
     * SCRAM / Cooldown Handling
     *************************************************************/
    if (!running)
        rbmk_decay_process(src)
        update_linked_consoles()
        return

    /*************************************************************
     * Reset core variables before computation
     *************************************************************/
    flux = 0
    radiation = 0
    thermal_output = 0

    var/has_active_rods = FALSE
    var/total_flux = 0
    var/total_heat = 0
    var/total_rads = 0
    var/rod_reactivity = 0.0

    /*************************************************************
     * Process all active rods
     *************************************************************/
    var/list/all_rods = normal_slots + special_slots
    for (var/obj/item/rbmk/fuel_rod/fuelRod in all_rods)
        if (!fuelRod || QDELETED(fuelRod))
            continue

        var/list/result = fuelRod.process_rod(temperature, flux)
        if (!result)
            continue

        total_flux += result["flux"]
        total_rads += result["radiation"]
        total_heat += result["heat"]

        rod_reactivity += (fuelRod.flux_multiplier + fuelRod.thermal_multiplier)

        if (fuelRod.fuel_amount > 0)
            has_active_rods = TRUE

        // --- Special rods ---
        if (fuelRod.rod_type == "telecrystal" && temperature >= 2000)
            var/inc = (temperature >= 10000 ? 3 : temperature >= 5000 ? 2 : 1)
            fuelRod.charge_progress += inc

            if (fuelRod.charge_progress >= fuelRod.charge_max && !fuelRod.charged)
                fuelRod.charged = TRUE
                to_chat(src, span_warning("A telecrystal rod hums violently as it finishes charging with bluespace energy!"))

        else if (fuelRod.rod_type == "supermatter" && prob(2))
            trigger_meltdown("Supermatter destabilization within fuel rod array!")

    /*************************************************************
     * Reactor Core Scaling (Balanced Reactivity Curve)
     *************************************************************/
    var/rod_ratio = clamp(control_rod_depth / RBMK_CONTROL_ROD_MAX, 0, 1)

    // New balanced curve:
    // - Very little power until 30%
    // - Strong but safe growth 30–70%
    // - Dangerous runaway >85%
    var/control_effect

    if (rod_ratio < 0.30)
        control_effect = 0.10
    else if (rod_ratio < 0.50)
        control_effect = 0.35
    else if (rod_ratio < 0.70)
        control_effect = 0.60
    else if (rod_ratio < 0.85)
        control_effect = 0.85
    else
        control_effect = (1 - rod_ratio) ** 2.3

    var/reactivity_factor = clamp(rod_reactivity / max(1, length(all_rods)), 0.8, 1.45)

    // Core output
    flux        = clamp(total_flux * control_effect * reactivity_factor, 0, RBMK_MAX_FLUX)
    radiation   = clamp(total_rads * control_effect * reactivity_factor, 0, RBMK_MAX_RADIATION)
    temperature += (total_heat * control_effect * reactivity_factor * 0.20)

    // --- Power & decay heat ---
    var/generated_power = (flux + radiation + total_heat)
    decay_heat = clamp(decay_heat + (generated_power * 0.0008), 0, 250)
    thermal_output = (temperature * RBMK_HEAT_SCALING) * reactivity_factor

    /*************************************************************
     * Coolant Energy Exchange (Balanced)
     *************************************************************/
    rbmk_coolant_exchange(src)
    rbmk_sample_coolant(src)

    if (coolant_internal)
        pressure = clamp(coolant_internal.return_pressure(), 0, RBMK_PRESSURE_EXTREME)
        rbmk_record_gas_snapshot()

    /*************************************************************
     * Natural Flux / Radiation Bleed
     *************************************************************/
    flux = max(0, flux - RBMK_FLUX_DECAY)
    radiation = max(0, radiation - RBMK_RADIATION_DECAY)

    /*************************************************************
     * Instability & Integrity
     *************************************************************/
    update_instability()
    update_reactor_integrity()

    /*************************************************************
     * Auto SCRAM Failsafe
     *************************************************************/
    if (!has_active_rods || temperature > (RBMK_MAX_TEMP * 1.35) || reactor_integrity <= 0)
        running = FALSE
        scrammed = TRUE
        to_chat(src, span_danger("⚠ Emergency SCRAM: core exceeded safe temperature limits!"))
        update_reactor_icon()
        update_linked_consoles()
        return

    /*************************************************************
     * Visuals & UI
     *************************************************************/
    update_reactor_icon()
    update_linked_consoles()


/*************************************************************
 * RBMK Decay Process (Cool-down Model)
 *************************************************************/
/obj/machinery/rbmk/reactor/proc/rbmk_decay_process(obj/machinery/rbmk/reactor/reactor)
    if (!reactor)
        return

    rbmk_sample_coolant(reactor)

    if (reactor.coolant_internal)
        reactor.pressure = reactor.coolant_internal.return_pressure()
        reactor.rbmk_record_gas_snapshot()

    if (reactor.decay_heat > 0)
        var/transfer = reactor.decay_heat * 0.035

        if (reactor.coolant_internal)
            reactor.coolant_internal.temperature += transfer * 0.65
            reactor.temperature -= transfer * 0.30

        reactor.flux       = max(0, reactor.flux - (reactor.decay_heat * 0.03))
        reactor.radiation  = max(0, reactor.radiation - (reactor.decay_heat * 0.02))
        reactor.temperature = max(RBMK_AMBIENT_TEMP, reactor.temperature - (reactor.decay_heat * 0.05))
        reactor.decay_heat *= 0.988

    else
        if (reactor.temperature > RBMK_AMBIENT_TEMP)
            reactor.temperature = max(RBMK_AMBIENT_TEMP, reactor.temperature - RBMK_IDLE_COOL_RATE)
        else
            reactor.icon_state = "reactor_off"

    reactor.update_reactor_icon()


/*************************************************************
 * Gas History Tracking
 *************************************************************/
/obj/machinery/rbmk/reactor/proc/rbmk_record_gas_snapshot()
    if (!coolant_internal)
        return

    var/datum/gas_mixture/mix = coolant_internal
    var/total = mix.total_moles()
    if (total <= 0)
        return

    var/list/snapshot = list()
    for (var/gas_path in mix.gases)
        var/moles = mix.gases[gas_path][MOLES]
        var/percent = (moles / total) * 100
        snapshot[gas_path] = percent

    coolant_gas_hist += list(snapshot)

    if (length(coolant_gas_hist) > 60)
        coolant_gas_hist.Cut(1, 2)


/*************************************************************
 * Coolant Exchange — Balanced Version
 *************************************************************/
/obj/machinery/rbmk/reactor/proc/rbmk_coolant_exchange(obj/machinery/rbmk/reactor/reactor)
    if (!reactor || !reactor.coolant_internal)
        return

    var/datum/gas_mixture/mix = reactor.coolant_internal
    var/temp_diff = reactor.temperature - mix.temperature

    if (temp_diff <= 0)
        return

    var/reactivity_scale = clamp((reactor.flux / 120) + 0.5, 0.7, 1.6)
    var/base_eff = 0.0012
    var/flow_mod = log(1 + reactor.inlet_rate / 50) + 1

    var/transfer = temp_diff * base_eff * reactivity_scale * flow_mod
    transfer = clamp(transfer, 0, reactor.temperature * 0.12)

    // Apply heat transfer
    mix.temperature += transfer * 0.80
    reactor.temperature -= transfer * 0.20

    // Pressure
    var/new_pressure = mix.return_pressure() + (transfer / 32)
    reactor.pressure = clamp(new_pressure, 0, RBMK_PRESSURE_EXTREME)

    if (reactor.pressure > RBMK_PRESSURE_CRITICAL)
        reactor.instability += ((reactor.pressure - RBMK_PRESSURE_CRITICAL) / 350)

    // Gas byproducts
    mix.assert_gases(/datum/gas/oxygen, /datum/gas/carbon_dioxide)
    mix.gases[/datum/gas/oxygen][MOLES] += clamp(transfer / 7500, 0, 10)
    mix.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(transfer / 9500, 0, 6)

    // Pressure history
    reactor.coolant_pressure_history += reactor.pressure
    if (length(reactor.coolant_pressure_history) > 60)
        reactor.coolant_pressure_history.Cut(1, 2)
