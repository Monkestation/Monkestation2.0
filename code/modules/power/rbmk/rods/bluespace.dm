/obj/item/rbmk/fuel_rod/bluespace
	name = "Bluespace Moderator Rod"
	desc = "A bluespace-anchored moderator rod. It improves heat transfer from the core into the coolant loop."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "tc_empty"

	depleted_icon_state = "tc_full"
	depleted_description = "A spent bluespace moderator rod. Its anchor lattice has collapsed."

	rod_type = "bluespace"
	rod_color = "cyan"

	fuel_amount = INFINITY
	fuel_consumption = 0
	contributes_to_reaction = FALSE

	reactivity = 0
	flux_multiplier = 1.0
	radiation_multiplier = 1.0
	thermal_multiplier = 1.0

/obj/item/rbmk/fuel_rod/bluespace/get_modifier_output()
	return list(
		"temperature_limit_bonus" = 0,
		"coolant_exchange_bonus" = RBMK_MODIFIER_BLUESPACE_COOLANT_BONUS,
		"flux_multiplier_bonus" = 0,
	)

/obj/item/rbmk/fuel_rod/bluespace/process_rod(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	activate_in_reactor()
	return get_zero_output()
