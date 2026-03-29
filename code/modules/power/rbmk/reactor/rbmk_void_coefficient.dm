/*************************************************************
 * RBMK Void Coefficient System — Canonical V1
 * -----------------------------------------------------------
 * Design rules:
 * - Void coefficient depends ONLY on reactor temperature
 * - No poisoning mechanics
 * - No coolant gas density effects
 * - No rod-type contributions
 * - This proc computes ONLY the extra multiplier term
 *
 * Process loop usage:
 *     flux *= (1 + void_coefficient)
 *************************************************************/

/// Recalculate void coefficient and return the extra multiplier term
/obj/machinery/rbmk/reactor/proc/update_void_coefficient()
	// No active reaction means no meaningful void feedback
	if (!running || meltdown_in_progress)
		void_coefficient = 0
		return void_coefficient

	// Linear temperature-driven VC
	var/temperature_coefficient = temperature * RBMK_VC_TEMP_COEFF

	// Prevent negative contribution
	temperature_coefficient = max(temperature_coefficient, 0)

	// Clamp to configured ceiling
	void_coefficient = clamp(
		temperature_coefficient,
		0,
		RBMK_VC_MAX
	)

	return void_coefficient
