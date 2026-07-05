/obj/item/rbmk/fuel_rod/diamond
	name = "Diamond Moderator Rod"
	desc = "A diamond-lensed moderator rod. It focuses neutron flux from installed fuel rods without producing heat on its own."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"

	depleted_icon_state = "rod_empty"
	depleted_description = "A dulled diamond moderator rod. Its lattice no longer focuses neutron flux."

	rod_type = "diamond"
	rod_color = "white"

	fuel_amount = INFINITY
	fuel_consumption = 0
	contributes_to_reaction = FALSE

	reactivity = 0
	flux_multiplier = 1.0
	radiation_multiplier = 1.0
	thermal_multiplier = 1.0

/obj/item/rbmk/fuel_rod/diamond/get_modifier_output()
	return list(
		"temperature_limit_bonus" = 0,
		"coolant_exchange_bonus" = 0,
		"flux_multiplier_bonus" = RBMK_MODIFIER_DIAMOND_FLUX_MULT_BONUS,
	)

/obj/item/rbmk/fuel_rod/diamond/process_rod(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	activate_in_reactor()
	return get_zero_output()
