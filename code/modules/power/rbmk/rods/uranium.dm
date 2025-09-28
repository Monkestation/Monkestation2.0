/obj/item/rbmk/fuel_rod/uranium
	name = "Uranium Fuel Rod"
	desc = "A classic uranium fuel rod, powerful but unstable."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "uranium"

	fuel_amount = 1000
	heat_per_tick = 5
	rad_output = 10
	flux_output = 2
	rod_type = "uranium"
	rod_color = "green"

/// Uranium rod processing
/obj/item/rbmk/fuel_rod/uranium/process_rod()
	// Fuel burn
	if (fuel_amount > 0)
		fuel_amount -= 1
	else
		if (active)
			active = FALSE
			icon_state = depleted_icon_state
			desc = depleted_desc
		return list()

	// Returns
	return list(
		"flux"       = flux_output,     // neutron production
		"heat"       = heat_per_tick,   // generates heat quickly
		"radiation"  = rad_output,      // high radiation
		"thermal_mult" = 1.0            // no stabilizing effect
	)
