/obj/machinery/rbmk/reactor/proc/update_void_coefficient()
	// No active reaction means no useful feedback term.
	if(meltdown_in_progress || !running)
		void_coefficient = 0
		return 0

	var/temperature_coefficient = max(temperature * RBMK_VC_TEMP_COEFF, 0)

	void_coefficient = clamp(
		temperature_coefficient,
		0,
		RBMK_VC_MAX
	)

	return void_coefficient
