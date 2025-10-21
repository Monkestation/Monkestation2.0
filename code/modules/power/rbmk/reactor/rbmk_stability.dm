/*************************************************************
 * RBMK Instability Logic (List-Based Rod System)
 * - Converts flux, temperature, and radiation into instability
 * - Scales with multipliers from stored rod data (no obj refs)
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/update_instability()
    // --- Base normalized factors ---
    var/flux_factor = flux / RBMK_SAFE_FLUX
    var/temp_factor = temperature / max_temp
    var/rad_factor  = radiation / RBMK_SAFE_RADIATION

    // --- Weighted instability ---
    // Flux has the strongest effect, temperature second, radiation third
    instability = (flux_factor * RBMK_FLUX_WEIGHT + temp_factor * RBMK_TEMP_WEIGHT + rad_factor * RBMK_RAD_WEIGHT) * 100

    // --- Synergy danger spike ---
    if (flux > RBMK_SYNERGY_FLUX_THRESHOLD && temperature > (max_temp * RBMK_SYNERGY_TEMP_RATIO))
        instability *= RBMK_SYNERGY_MULT

    // --- Radiation hazard kicker ---
    if (radiation > RBMK_RADIATION_KICKER_THRESHOLD)
        instability += RBMK_RADIATION_KICKER_BONUS

    /*************************************************************
     * Influence from Rod Multipliers
     * Now supports list-based data instead of object references.
     *************************************************************/
    var/multiplier = 1.0
    for (var/rod_data in normal_slots + special_slots)
        if (!rod_data)
            continue
        if ("flux_mult" in rod_data)
            multiplier *= rod_data["flux_mult"]
        if ("thermal_mult" in rod_data)
            multiplier *= rod_data["thermal_mult"]

    // Apply combined multiplier
    instability *= multiplier

    // --- Clamp to safe range ---
    instability = clamp(instability, 0, RBMK_INSTABILITY_MAX)

    return instability
