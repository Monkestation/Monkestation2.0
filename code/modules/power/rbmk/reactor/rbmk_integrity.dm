/*************************************************************
 * RBMK Integrity Module (Rod-Driven Version)
 * - Applies thermal, flux, instability, and pressure stress
 * - Damage scales with rod reactivity and cooling performance
 * - Stops integrity decay when reactor is shut down
 *************************************************************/

/// Applies cumulative integrity stress each reactor tick
/obj/machinery/rbmk/reactor/proc/update_reactor_integrity()
    // --- Skip integrity checks if destroyed ---
    if(reactor_integrity <= 0)
        return

    /*************************************************************
     * Offline / Fully Inserted Control Rods
     * - No active reaction → minimal passive fatigue only
     *************************************************************/
    if(!running || control_rod_depth >= RBMK_CONTROL_ROD_MAX)
        if(temperature > RBMK_AMBIENT_TEMP + 25)
            reactor_integrity = max(reactor_integrity - 0.01, 0)
        return

    var/total_damage = 0.0

    /*************************************************************
     * Temperature Stress
     * - Gentle slope above threshold, steeper near max temp
     *************************************************************/
    if(temperature > RBMK_TEMP_STRESS_THRESHOLD)
        var/temp_excess = temperature - RBMK_TEMP_STRESS_THRESHOLD
        total_damage += (temp_excess / RBMK_TEMP_STRESS_DIVISOR) ** 1.05

    if(temperature > (max_temp * RBMK_TEMP_NEAR_MAX_RATIO))
        var/near_max_excess = temperature - (max_temp * RBMK_TEMP_NEAR_MAX_RATIO)
        total_damage += (near_max_excess / RBMK_TEMP_NEAR_MAX_DIVISOR) ** 1.25

    /*************************************************************
     * Flux Stress
     * - Gentle rise near safe flux, steep increase at extremes
     *************************************************************/
    if(flux > RBMK_FLUX_STRESS_THRESHOLD)
        var/flux_excess = flux - RBMK_FLUX_STRESS_THRESHOLD
        total_damage += (flux_excess / RBMK_FLUX_STRESS_DIVISOR) ** 1.1

    if(flux > RBMK_FLUX_HIGH_THRESHOLD)
        var/severe_flux = flux - RBMK_FLUX_HIGH_THRESHOLD
        total_damage += (severe_flux / RBMK_FLUX_HIGH_DIVISOR) ** 1.25

    /*************************************************************
     * Instability Stress
     * - Reflects chaotic internal oscillations
     * - Adds passive wear even under safe heat/flux
     *************************************************************/
    if(instability > RBMK_INSTABILITY_THRESHOLD)
        var/instability_excess = instability - RBMK_INSTABILITY_THRESHOLD
        total_damage += (instability_excess / RBMK_INSTABILITY_DIVISOR) ** 1.1

    /*************************************************************
     * Pressure Stress
     * - Coolant overpressure adds direct mechanical load
     *************************************************************/
    if(pressure > RBMK_PRESSURE_WARNING)
        var/pressure_excess = pressure - RBMK_PRESSURE_WARNING
        total_damage += (pressure_excess / RBMK_PRESSURE_WARNING_DIVISOR) ** 1.05

    if(pressure > RBMK_PRESSURE_CRITICAL)
        var/pressure_critical_excess = pressure - RBMK_PRESSURE_CRITICAL
        total_damage += (pressure_critical_excess / RBMK_PRESSURE_CRITICAL_DIVISOR) ** 1.15

    if(pressure > RBMK_PRESSURE_EXTREME)
        var/pressure_extreme_excess = pressure - RBMK_PRESSURE_EXTREME
        total_damage += (pressure_extreme_excess / RBMK_PRESSURE_EXTREME_DIVISOR) ** 1.25

    /*************************************************************
     * Rod Structural Load
     * - Each active rod adds a baseline mechanical stress
     *************************************************************/
    var/rod_count = length(normal_slots) + length(special_slots)
    if(rod_count > 0)
        total_damage += rod_count * 0.005   // formerly 0.02

    /*************************************************************
     * Apply Stress Damage
     *************************************************************/
    if(total_damage > 0)
        reactor_integrity = max(reactor_integrity - total_damage, 0)

        if(reactor_integrity <= 0)
            trigger_meltdown("⚠ Reactor breached from combined overload!")

    /*************************************************************
     * Update Repairable State
     *************************************************************/
    repairable = (temperature < (max_temp * RBMK_REPAIRABLE_TEMP_RATIO) && flux < RBMK_REPAIRABLE_FLUX_LIMIT && pressure < RBMK_REPAIRABLE_PRESSURE_LIMIT)
