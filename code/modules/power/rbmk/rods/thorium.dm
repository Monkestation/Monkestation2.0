/obj/item/rbmk/fuel_rod/thorium
	name = "Thorium Fuel Rod"
	desc = "More stable than uranium, but less efficient."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "thorium"

	fuel_amount = 1200
	heat_per_tick = 3
	rad_output = 6
	flux_output = 1
	rod_type = "thorium"
	rod_color = "lightblue"

/// Thorium rod processing
/obj/item/rbmk/fuel_rod/thorium/process_rod()
	// Burn fuel
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
		"flux"        = flux_output,     // weaker neutron production
		"heat"        = heat_per_tick,   // generates less heat
		"radiation"   = rad_output,      // lower radiation
		"thermal_mult" = 0.9             // stabilizing: slows temp growth
	)
