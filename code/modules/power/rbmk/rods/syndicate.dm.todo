/obj/item/rbmk/fuel_rod/supermatter
	name = "Supermatter Fuel Rod"
	desc = "A Syndicate-engineered rod containing a sliver of supermatter. Emits immense energy and threatens catastrophic meltdown."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "syndicate"

	rod_type = "supermatter"
	rod_color = "gold"

	// Short lifespan, extremely dangerous output
	fuel_amount = 100
	depletion_rate = 1.0

	base_heat_output = 150
	base_radiation_output = 120

	thermal_multiplier = 1.8
	flux_multiplier = 1.2
	radiation_multiplier = 2.0

	reactivity_sensitivity = 0.006

	var/internal_instability = 0
	var/meltdown_threshold = 100
	var/meltdown_triggered = FALSE

	active = TRUE


/obj/item/rbmk/fuel_rod/supermatter/process_rod(reactor_temperature = RBMK_AMBIENT_TEMP, reactor_flux = 0, core_feedback_factor = 1.0)
	if(fuel_amount <= 0)
		if(active)
			active = FALSE
			icon_state = depleted_icon_state
			desc = depleted_description

		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0
		)

	fuel_amount = max(0, fuel_amount - depletion_rate)

	// Build instability from heat + load
	internal_instability += ((reactor_temperature / 3000) + (reactor_flux / 50)) * reactivity_sensitivity

	if(internal_instability >= meltdown_threshold && !meltdown_triggered)
		meltdown_triggered = TRUE

		var/obj/machinery/rbmk/reactor/reactor_core = loc
		if(istype(reactor_core))
			reactor_core.trigger_meltdown("Supermatter containment failure")

	// Scale output with core conditions
	var/reactivity_factor = 1 + ((reactor_temperature / 2000) * reactivity_sensitivity)
	reactivity_factor = clamp(reactivity_factor * core_feedback_factor, 1.0, 3.5)

	var/heat_output = base_heat_output * reactivity_factor * thermal_multiplier
	var/radiation_output = base_radiation_output * reactivity_factor * radiation_multiplier

	// Slight indirect flux contribution
	var/flux_output = reactor_flux * 0.02 * flux_multiplier

	return list(
		"heat" = heat_output,
		"flux" = flux_output,
		"radiation" = radiation_output
	)
