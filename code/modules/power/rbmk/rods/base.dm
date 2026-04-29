/obj/item/rbmk/fuel_rod
	name = "Fuel Rod"
	desc = "A generic fuel rod designed for RBMK reactors."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	layer = OBJ_LAYER + 0.02
	plane = GAME_PLANE

	var/rod_type = "empty"
	var/rod_color = "grey"

	var/fuel_amount = 100
	var/fuel_consumption = 1

	var/reactivity = 10
	var/flux_multiplier = 1.0
	var/radiation_multiplier = 1.0
	var/thermal_multiplier = 1.0

	var/active = TRUE

	var/depleted_icon_state = "rod_empty"
	var/depleted_description = "An empty fuel rod ready for packing."


/obj/item/rbmk/fuel_rod/proc/deplete_rod()
	active = FALSE
	icon_state = depleted_icon_state
	desc = depleted_description


/obj/item/rbmk/fuel_rod/proc/get_zero_output()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0
	)


/obj/item/rbmk/fuel_rod/proc/process_rod()
	if(!active)
		return get_zero_output()

	if(fuel_amount <= 0)
		deplete_rod()
		return get_zero_output()

	fuel_amount = max(0, fuel_amount - fuel_consumption)

	// Let the last unit of fuel still produce output this tick,
	// then mark the rod spent afterward.
	var/should_deplete_after_output = (fuel_amount <= 0)

	var/rod_flux_output = reactivity * flux_multiplier
	var/rod_radiation_output = reactivity * radiation_multiplier
	var/rod_heat_output = reactivity * thermal_multiplier

	if(should_deplete_after_output)
		deplete_rod()

	return list(
		"flux" = rod_flux_output,
		"radiation" = rod_radiation_output,
		"heat" = rod_heat_output
	)
