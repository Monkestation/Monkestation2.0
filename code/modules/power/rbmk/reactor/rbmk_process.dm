/*************************************************************
 * RBMK PROCESS LOGIC — MODEL A (2025 FINAL, CLEAN VERSION)
 * -----------------------------------------------------------
 * Rods → Reactivity → Flux → Heat → Void Coefficient → Flux
 * Clean linear model — no instability, only VC.
 *************************************************************/


/*************************************************************
 * 0. SUPPORT PROCS
 *************************************************************/

/// Idle-state decay when the reactor is not running
/proc/rbmk_decay_process(obj/machinery/rbmk/reactor/reactor)
    if (!reactor)
        return

    reactor.flux = max(reactor.flux - RBMK_FLUX_DECAY, 0)
    reactor.radiation = max(reactor.radiation - RBMK_RADIATION_DECAY, 0)


/// Simple coolant heat transfer placeholder
/proc/rbmk_coolant_exchange(obj/machinery/rbmk/reactor/reactor)
    if (!reactor || !reactor.coolant_internal)
        return

    var/temperature_drop = min(5, reactor.temperature)

    reactor.temperature -= temperature_drop
    reactor.coolant_internal.temperature += (temperature_drop * 0.8)



/*************************************************************
 * 1. MAIN REACTOR PROCESS
 *************************************************************/

/// Main per-tick process logic
/obj/machinery/rbmk/reactor/process()
    /*******************************************************
     * A. SAFETY & SCRAM CHECKS
     *******************************************************/

    // 1 — destroyed → cannot run
    if(reactor_integrity <= 0)
        running = FALSE
        return

    // 2 — full insertion = SCRAM
    if (control_rod_depth >= RBMK_CONTROL_ROD_MAX)
        if (running)
            running = FALSE
            scrammed = TRUE
            to_chat(src, span_notice("Control rods fully inserted — reactor shutting down."))
            update_reactor_icon()
            update_linked_consoles()
        return

    // 3 — idle → only decay processing
    if (!running)
        rbmk_decay_process(src)
        update_linked_consoles()
        return



    /*******************************************************
     * B. COLLECT REACTIVITY FROM FUEL RODS
     *******************************************************/
    var/total_reactivity_value = 0
    var/active_fuel_rod_count = 0

    for (var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
        if (!fuel_rod || !fuel_rod.active)
            continue

        // Fuel burn
        fuel_rod.fuel_amount = max(fuel_rod.fuel_amount - fuel_rod.fuel_consumption, 0)

        // Burned out
        if (fuel_rod.fuel_amount <= 0)
            fuel_rod.active = FALSE
            continue

        total_reactivity_value += fuel_rod.reactivity
        active_fuel_rod_count++

    if (active_fuel_rod_count == 0)
        running = FALSE
        scrammed = TRUE
        to_chat(src, span_danger("⚠ Reactor SCRAM: All fuel rods depleted!"))
        update_reactor_icon()
        update_linked_consoles()
        return

    last_tick_rod_count = active_fuel_rod_count



    /*******************************************************
     * C. CONTROL ROD DAMPENING
     *******************************************************/
    var/control_multiplier = clamp(
        1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX),
        0,
        1
    )

    total_reactivity_value *= control_multiplier



    /*******************************************************
     * D. REACTIVITY → FLUX
     *******************************************************/
    var/generated_flux = total_reactivity_value * RBMK_FLUX_GAIN
    flux = clamp(generated_flux, 0, RBMK_MAX_FLUX)



    /*******************************************************
     * E. FLUX → TEMPERATURE (HEAT)
     *******************************************************/
    var/generated_heat = flux * RBMK_HEAT_SCALING

    temperature += generated_heat
    thermal_output = generated_heat
    last_tick_flux = flux
    last_tick_temp_gain = generated_heat



    /*******************************************************
     * F. VOID COEFFICIENT FEEDBACK LOOP
     *******************************************************/
    void_coefficient = temperature * RBMK_VC_TEMP_COEFF
    void_coefficient = clamp(void_coefficient, 0, RBMK_VC_MAX)

    flux = clamp(flux * (1 + void_coefficient), 0, RBMK_MAX_FLUX)



    /*******************************************************
     * G. RADIATION OUTPUT
     *******************************************************/
    radiation = clamp(
    (flux * RBMK_RADIATION_FLUX_MULT) + (temperature * RBMK_RADIATION_TEMP_MULT),
    0,
    RBMK_MAX_RADIATION
)




    /*************************************************************
 * H. TRITIUM PRODUCTION (OPTIONAL)
 *************************************************************/

    if (coolant_internal)
        var/tritium_delta = flux * RBMK_TRITIUM_RATE
        if (tritium_delta > 0)
            coolant_internal.assert_gases(/datum/gas/tritium)
            coolant_internal.gases[/datum/gas/tritium][MOLES] += tritium_delta

    /*******************************************************
     * I. COOLANT HEAT TRANSFER + PRESSURE + TELEMETRY
     *******************************************************/
    rbmk_coolant_exchange(src)
    rbmk_sample_coolant(src)

    if (coolant_internal)
        pressure = clamp(coolant_internal.return_pressure(), 0, RBMK_PRESSURE_EXTREME)



    /*******************************************************
     * J. NATURAL DECAY
     *******************************************************/
    flux = max(flux - RBMK_FLUX_DECAY, 0)
    radiation = max(radiation - RBMK_RADIATION_DECAY, 0)



    /*******************************************************
     * K. STRUCTURAL INTEGRITY CHECK
     *******************************************************/
    update_reactor_integrity()

    if (temperature > RBMK_MAX_TEMP || reactor_integrity <= 0)
        running = FALSE
        scrammed = TRUE
        to_chat(src, span_danger("⚠ EMERGENCY SCRAM — Core temperature or structural failure!"))
        update_reactor_icon()
        update_linked_consoles()
        return



    /*******************************************************
     * L. UI + ICON UPDATES
     *******************************************************/
    update_reactor_icon()
    update_linked_consoles()
