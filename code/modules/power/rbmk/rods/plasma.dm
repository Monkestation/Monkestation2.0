/obj/item/rbmk/fuel_rod/plasma
	name = "Plasma Moderator Rod"
	desc = "Amplifies the reactor’s thermal output without depleting, but makes flux more dangerous."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "plasma"

	fuel_amount = INFINITY   // never depletes
	heat_per_tick = 0
	rad_output = 0
	flux_output = 0
	active = TRUE
	rod_type = "plasma"
	rod_color = "purple"

/// Plasma rod processing
/obj/item/rbmk/fuel_rod/plasma/process_rod()
	// Plasma rods never deplete, always active
	return list(
		"flux"        = 0,        // no direct neutron contribution
		"heat"        = 0,        // no direct heat
		"radiation"   = 0,        // no radiation
		"thermal_mult" = 1.25,    // amplifies reactor heat output
		"flux_mult"    = 1.1      // makes flux slightly more dangerous
	)
