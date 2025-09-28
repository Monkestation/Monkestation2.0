/obj/item/rbmk/fuel_rod/supermatter
	name = "Supermatter Fuel Rod"
	desc = "A Syndicate-engineered rod containing a supermatter sliver. Extremely dangerous."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "supermatter"
	depleted_icon_state = "supermatter_empty"
	depleted_desc = "A shattered rod that once contained supermatter."

	fuel_amount = 50
	heat_per_tick = 200
	rad_output = 100
	flux_output = 0
	rod_type = "supermatter"
	rod_color = "gold"

/// Supermatter rod processing
/obj/item/rbmk/fuel_rod/supermatter/process_rod()
	// If inactive or fuel gone → inert
	if (!active || fuel_amount <= 0)
		return list()

	fuel_amount--

	// Rare meltdown event
	var/obj/machinery/rbmk/reactor/core = null
	if (istype(loc, /obj/machinery/rbmk/reactor))
		core = loc

	if (core && prob(2)) // 2% meltdown risk each tick
		core.trigger_meltdown("Supermatter destabilization!")

	// Handle depletion
	if (fuel_amount <= 0)
		active = FALSE
		icon_state = depleted_icon_state
		desc = depleted_desc

	// Contribute outputs like a normal rod
	return list(
		"flux"        = 0,              // SM doesn’t contribute neutrons
		"heat"        = heat_per_tick,  // insane heat per tick
		"radiation"   = rad_output,     // heavy radiation
		"thermal_mult" = 1.5,           // destabilizes temperature heavily
		"flux_mult"    = 1.2            // makes existing flux nastier
	)
