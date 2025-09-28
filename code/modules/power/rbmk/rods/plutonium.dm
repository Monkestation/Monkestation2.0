/obj/item/rbmk/fuel_rod/plutonium
	name = "Plutonium Fuel Rod"
	desc = "Extremely powerful and unstable, outputting heavy radiation."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "plutonium"

	fuel_amount = 800
	heat_per_tick = 7
	rad_output = 15
	flux_output = 4
	rod_type = "plutonium"
	rod_color = "white"

/// Plutonium rod processing
/obj/item/rbmk/fuel_rod/plutonium/process_rod()
	// Fuel burn
	if (fuel_amount > 0)
		fuel_amount -= 1
	else
		if (active)
			active = FALSE
			icon_state = depleted_icon_state
			desc = depleted_desc
		return list()

	// Return contributions
	return list(
		"flux"        = flux_output,     // strong neutron production
		"heat"        = heat_per_tick,   // very high heat per tick
		"radiation"   = rad_output,      // heavy radiation output
		"thermal_mult" = 1.2             // destabilizing, accelerates heat growth
	)
