/// Special moderator rod that raises the reactor's thermal limits.
/obj/item/rbmk/fuel_rod/plasma
	name = "Plasma Moderator Rod"
	desc = "A stabilized plasma moderator rod. It raises the reactor's thermal tolerance while installed, but produces no direct heat or radiation."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plasma"
	depleted_icon_state = "plasma_empty"
	depleted_description = "An inert plasma moderator rod. Its thermal buffering charge has fully dissipated."
	rod_type = RBMK_ROD_TYPE_PLASMA
	uses_special_slot = TRUE
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

/// Special moderator rod that improves vessel-to-coolant heat exchange.
/obj/item/rbmk/fuel_rod/bluespace
	name = "Bluespace Moderator Rod"
	desc = "A bluespace-anchored moderator rod. It improves heat transfer from the core into the coolant loop."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "tc_empty"
	depleted_icon_state = "tc_full"
	depleted_description = "A spent bluespace moderator rod. Its anchor lattice has collapsed."
	rod_type = RBMK_ROD_TYPE_BLUESPACE
	uses_special_slot = TRUE
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

/// Special moderator rod that increases reactor neutron flux.
/obj/item/rbmk/fuel_rod/diamond
	name = "Diamond Moderator Rod"
	desc = "A diamond-lensed moderator rod. It focuses neutron flux from installed fuel rods without producing heat on its own."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	depleted_icon_state = "rod_empty"
	depleted_description = "A dulled diamond moderator rod. Its lattice no longer focuses neutron flux."
	rod_type = RBMK_ROD_TYPE_DIAMOND
	uses_special_slot = TRUE
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
