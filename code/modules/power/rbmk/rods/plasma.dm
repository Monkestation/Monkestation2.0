/obj/item/rbmk/fuel_rod/plasma
	name = "Plasma Moderator Rod"
	desc = "A stabilized plasma moderator rod. It raises the reactor's thermal tolerance while installed, but produces no direct heat or radiation."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plasma"

	depleted_icon_state = "plasma_empty"
	depleted_description = "An inert plasma moderator rod. Its thermal buffering charge has fully dissipated."

	rod_type = "plasma"
	rod_color = "purple"

	fuel_amount = INFINITY
	fuel_consumption = 0
	contributes_to_reaction = FALSE

	reactivity = 0
	flux_multiplier = 1.0
	radiation_multiplier = 1.0
	thermal_multiplier = 1.0

/obj/item/rbmk/fuel_rod/plasma/get_modifier_output()
	return list(
		"temperature_limit_bonus" = RBMK_MODIFIER_PLASMA_TEMP_LIMIT_BONUS,
		"coolant_exchange_bonus" = 0,
		"flux_multiplier_bonus" = 0,
	)

/obj/item/rbmk/fuel_rod/plasma/process_rod(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	activate_in_reactor()
	return get_zero_output()
