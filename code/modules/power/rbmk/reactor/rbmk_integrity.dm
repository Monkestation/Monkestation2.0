/*************************************************************
 * RBMK Integrity Module
 * Handles reactor structural integrity, repair state, and meltdown triggers
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()
    // --- No damage accumulation when inactive ---
    if(!running)
        return

    var/damage = 0

    /*************************************************************
     * Temperature Stress
     *************************************************************/
    if(temperature > RBMK_TEMP_STRESS_THRESHOLD)
        // Damage scales faster the hotter it gets
        damage += (temperature - RBMK_TEMP_STRESS_THRESHOLD) / RBMK_TEMP_STRESS_DIVISOR

    if(temperature > (max_temp * RBMK_TEMP_NEAR_MAX_RATIO))
        // Near max temp = exponential stress
        damage += (temperature - (max_temp * RBMK_TEMP_NEAR_MAX_RATIO)) / RBMK_TEMP_NEAR_MAX_DIVISOR

    /*************************************************************
     * Flux Stress
     *************************************************************/
    if(flux > RBMK_FLUX_STRESS_THRESHOLD)
        damage += (flux - RBMK_FLUX_STRESS_THRESHOLD) / RBMK_FLUX_STRESS_DIVISOR

    if(flux > RBMK_FLUX_HIGH_THRESHOLD)
        // High neutron flux snowballs hard
        damage += (flux - RBMK_FLUX_HIGH_THRESHOLD) / RBMK_FLUX_HIGH_DIVISOR

    /*************************************************************
     * Instability-Driven Stress
     *************************************************************/
    if(instability > RBMK_INSTABILITY_THRESHOLD)
        // Above 100% instability, structural damage accelerates
        damage += (instability - RBMK_INSTABILITY_THRESHOLD) / RBMK_INSTABILITY_DIVISOR

    /*************************************************************
     * Pressure Stress
     *************************************************************/
    if(pressure > RBMK_PRESSURE_WARNING)
        damage += (pressure - RBMK_PRESSURE_WARNING) / RBMK_PRESSURE_WARNING_DIVISOR

    if(pressure > RBMK_PRESSURE_CRITICAL)
        damage += (pressure - RBMK_PRESSURE_CRITICAL) / RBMK_PRESSURE_CRITICAL_DIVISOR

    if(pressure > RBMK_PRESSURE_EXTREME)
        damage += (pressure - RBMK_PRESSURE_EXTREME) / RBMK_PRESSURE_EXTREME_DIVISOR

    /*************************************************************
     * Apply Damage
     *************************************************************/
    if(damage > 0)
        reactor_integrity = max(reactor_integrity - damage, 0)

        if(reactor_integrity <= 0)
            trigger_meltdown("⚠ Reactor breached from combined overload!")

    /*************************************************************
     * Update Repairable State
     *************************************************************/
    repairable = (
        (temperature < (max_temp * RBMK_REPAIRABLE_TEMP_RATIO)) && \
        (flux < RBMK_REPAIRABLE_FLUX_LIMIT) && \
        (pressure < RBMK_REPAIRABLE_PRESSURE_LIMIT)
    )

    return reactor_integrity
