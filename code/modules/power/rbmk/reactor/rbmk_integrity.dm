/*************************************************************
 * RBMK Integrity Module — 2025 Linear-Core Revision
 * -----------------------------------------------------------
 * Integrity responds ONLY to:
 *   - Temperature overstress
 *   - Pressure overstress
 *   - Flux overstress (small effect)
 *   - Rod count mechanical stress
 *
 * VC does NOT damage the core directly — it only affects flux.
 * Tritium does NOT damage the core — only pressure does.
 *************************************************************/


/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()

    // ---------------------------------------------------------
    // Hard exit: already destroyed
    // ---------------------------------------------------------
    if (reactor_integrity <= 0)
        return


    /*************************************************************
     * SCRAMMED CONDITION — cooling damage only
     *************************************************************/
    if (!running)
        // When shut down but still hot, slowly damages the shell
        if (temperature > RBMK_AMBIENT_TEMP + 20)
            reactor_integrity = max(reactor_integrity - 0.003, 0)

            if (reactor_integrity <= 0)
                trigger_meltdown("Core failure during cooldown")

        return


    /*************************************************************
     * STRESSOR COLLECTION
     *************************************************************/
    var/temperature_excess = max(0, temperature - RBMK_TEMP_STRESS_THRESHOLD)
    var/pressure_excess    = max(0, pressure    - RBMK_PRESSURE_WARNING)
    var/flux_excess        = max(0, flux        - RBMK_FLUX_STRESS_THRESHOLD)
    var/rod_count          = length(normal_slots) + length(special_slots)


    /*************************************************************
     * DAMAGE CALCULATION — LINEAR + EDGE BOOSTS
     *************************************************************/
    var/total_damage = 0.0

    // --------------------
    // Temperature overstress
    // --------------------
    if (temperature_excess > 0)
        total_damage += temperature_excess / 850

        // Near-meltdown acceleration
        if (temperature > RBMK_MAX_TEMP * 0.92)
            total_damage += (temperature - (RBMK_MAX_TEMP * 0.92)) / 300


    // --------------------
    // Pressure overstress
    // --------------------
    if (pressure_excess > 0)
        total_damage += pressure_excess / 1700

        // Deep-red pressure zone
        if (pressure > RBMK_PRESSURE_CRITICAL)
            total_damage += (pressure - RBMK_PRESSURE_CRITICAL) / 1000


    // --------------------
    // Flux overstress (minor contributor)
    // --------------------
    if (flux_excess > 0)
        total_damage += flux_excess / 2000

        if (flux > RBMK_FLUX_HIGH_THRESHOLD)
            total_damage += (flux - RBMK_FLUX_HIGH_THRESHOLD) / 1400


    // --------------------
    // Mechanical stress from rod count
    // --------------------
    total_damage += rod_count * 0.0008


    /*************************************************************
     * APPLY DAMAGE
     *************************************************************/
    if (total_damage > 0)
        reactor_integrity = max(reactor_integrity - total_damage, 0)

        if (reactor_integrity <= 0)
            trigger_meltdown("⚠ Core breach: Temperature / pressure overload!")
