/obj/item/rbmk/fuel_rod/bananium
	name = "Bananium Fuel Rod"
	desc = "Ridiculous and silly, but still a functional moderator."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "bananium"

	fuel_amount = 600
	heat_per_tick = 2
	rad_output = 3
	flux_output = 1
	rod_type = "bananium"
	rod_color = "yellow"

/// Bananium rod processing
/obj/item/rbmk/fuel_rod/bananium/process_rod()
	// Consume fuel
	if (fuel_amount > 0)
		fuel_amount -= 1
	else
		active = FALSE
		return list()

	// Return contributions
	return list(
		"flux"        = flux_output,     // neutron moderation
		"heat"        = heat_per_tick,   // banana heat
		"radiation"   = rad_output,      // radiation output
		"thermal_mult" = 0.8             // less efficient moderator
	)
