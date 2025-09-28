/obj/item/rbmk/fuel_rod
	name = "Fuel Rod"
	desc = "A generic RBMK fuel rod."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "rod"
	anchored = FALSE
	w_class = WEIGHT_CLASS_NORMAL

	// Core variables shared by all rods
	var/fuel_amount = 100
	var/heat_per_tick = 1
	var/rad_output = 5
	var/flux_output = 0
	var/active = TRUE

	// Depletion
	var/depleted_icon_state = "empty"
	var/depleted_desc = "A spent fuel rod, inert and useless."

	// Visuals
	var/rod_type = "generic"
	var/rod_color = "white"
	var/icon_color = "white"

/// Default proc: may be overridden by subtypes
/obj/item/rbmk/fuel_rod/proc/process_rod()
	// Check if fuel remains
	if (fuel_amount > 0)
		fuel_amount -= 1
	else
		// Mark as inactive when fuel is gone
		if (active)
			active = FALSE
			icon_state = depleted_icon_state
			desc = depleted_desc
		return list()

	// Provide reactor contributions
	return list(
		"flux"       = flux_output,
		"heat"       = heat_per_tick,
		"radiation"  = rad_output,
		"thermal_mult" = 1.0
	)
