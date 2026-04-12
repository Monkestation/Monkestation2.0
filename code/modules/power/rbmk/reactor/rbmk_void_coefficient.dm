/obj/machinery/rbmk/reactor/proc/update_void_coefficient()
	// No active reaction means no useful feedback term.
	if(!running || meltdown_in_progress)
		void_coefficient = 0
		return void_coefficient

	var/temperature_coefficient = temperature * RBMK_VC_TEMP_COEFF
	temperature_coefficient = max(temperature_coefficient, 0)

	void_coefficient = clamp(
		temperature_coefficient,
		0,
		RBMK_VC_MAX
	)

	return void_coefficient
