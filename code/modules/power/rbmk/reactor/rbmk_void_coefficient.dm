/*************************************************************
 * RBMK Void Coefficient System (Linear Base Model – 2025)
 * -----------------------------------------------------------
 * - VC depends ONLY on temperature
 * - No poisoning or gas density effects
 * - No rod-type contributions
 * - update_void_coefficient() computes ONLY the "extra" VC term:
 *
 *       void_coefficient = temperature * RBMK_VC_TEMP_COEFF
 *
 *   The process loop applies it as:
 *
 *       flux *= (1 + void_coefficient)
 *
 *************************************************************/

/// Recalculate void coefficient (VC)
/// Returns the EXTRA multiplier (not the full VC)
/// Example: if temperature is high, void_coefficient = 0.7
/// Process loop then does: flux *= 1.7
/obj/machinery/rbmk/reactor/proc/update_void_coefficient()

    // Reactor off → no void effect
    if (!running)
        void_coefficient = 0
        return void_coefficient

    // Compute linear void coefficient (extra term only)
    var/temp_coeff = temperature * RBMK_VC_TEMP_COEFF

    // VC cannot be negative
    if (temp_coeff < 0)
        temp_coeff = 0

    // Clamp to configured max
    temp_coeff = clamp(temp_coeff, 0, RBMK_VC_MAX)

    void_coefficient = temp_coeff
    return void_coefficient
