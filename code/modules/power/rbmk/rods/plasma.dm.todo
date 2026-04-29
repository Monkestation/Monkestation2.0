/obj/item/rbmk/fuel_rod/plasma
	name = "Plasma Moderator Rod"
	desc = "A moderator rod infused with stabilized plasma. It boosts flux but does not produce direct heat or radiation."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plasma"

	depleted_icon_state = "plasma_empty"
	depleted_description = "An inert plasma rod. Its energy has fully dissipated."

	rod_type = "plasma"
	rod_color = "purple"

	// Effectively infinite lifespan.
	fuel_amount = 1e30
	fuel_consumption = 0

	// No direct output of its own.
	reactivity = 0

	flux_multiplier = 1.10
	thermal_multiplier = 1.0
	radiation_multiplier = 1.0

/obj/item/rbmk/fuel_rod/plasma/process_rod()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0
	)
