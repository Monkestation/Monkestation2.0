/// Starter fissile rod with high heat, flux, and radiation output.
/obj/item/rbmk/fuel_rod/uranium
	name = "Uranium Fuel Rod"
	desc = "A volatile uranium fuel rod. Produces high heat and dangerous levels of radiation."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "uranium"
	depleted_icon_state = "uranium_used"
	depleted_description = "A spent uranium fuel rod."
	rod_type = RBMK_ROD_TYPE_URANIUM
	rod_color = "green"
	fuel_amount = 500
	fuel_consumption = 0.5
	reactivity = 14
	flux_multiplier = 2.4
	radiation_multiplier = 2.5
	thermal_multiplier = 1.3

/// Mid-tier fissile rod produced from material recovered from spent uranium fuel.
/obj/item/rbmk/fuel_rod/thorium
	name = "Thorium Fuel Rod"
	desc = "A stable, long-lasting fuel rod with moderate radiation output and low thermal load."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "thorium"
	depleted_icon_state = "thorium_used"
	depleted_description = "A spent thorium fuel rod."
	rod_type = RBMK_ROD_TYPE_THORIUM
	rod_color = "lightblue"
	fuel_amount = 800
	fuel_consumption = 0.5
	reactivity = 9
	flux_multiplier = 1.6
	radiation_multiplier = 1.2
	thermal_multiplier = 1

/// High-tier fissile rod produced from material recovered from spent thorium fuel.
/obj/item/rbmk/fuel_rod/plutonium
	name = "Plutonium Fuel Rod"
	desc = "A dangerously potent fuel rod with a massive neutron output. Requires aggressive cooling."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "plutonium"
	depleted_icon_state = "plutonium_used"
	depleted_description = "A spent plutonium rod. Still faintly warm."
	rod_type = RBMK_ROD_TYPE_PLUTONIUM
	rod_color = "crimson"
	fuel_amount = 400
	fuel_consumption = 0.5
	reactivity = 18
	flux_multiplier = 3.4
	radiation_multiplier = 3.0
	thermal_multiplier = 2.6
