/*************************************************************
 * PLASMA MODERATOR ROD
 * - Does NOT produce heat or radiation.
 * - Slightly boosts reactor flux via flux_multiplier.
 * - Effectively infinite fuel.
 *************************************************************/

/// Plasma Moderator Rod
/obj/item/rbmk/fuel_rod/plasma
    name = "Plasma Moderator Rod"
    desc = "A moderator rod infused with stabilized plasma. Boosts flux but produces no heat or radiation."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "plasma"

    // Visual, depleted state (never depletes but required for parent behavior)
    depleted_icon_state = "plasma_empty"
    depleted_description = "An inert plasma rod. Its energy has fully dissipated."

    // Identification
    rod_type = "plasma"
    rod_color = "purple"

    // Fuel system — effectively infinite
    fuel_amount = 1e30
    fuel_consumption = 0

    // Plasma rods do not generate direct reactivity
    reactivity = 0

    // Stabilizing behavior / multipliers
    flux_multiplier = 1.10        // +10% flux boost
    thermal_multiplier = 1.0
    radiation_multiplier = 1.0

    // Plasma rods are always active
    active = TRUE


/*************************************************************
 * Plasma Rod Output Logic
 * - Does NOT burn fuel.
 * - Does NOT produce reactivity, heat, or radiation.
 * - Only flux multiplier affects the core.
 *************************************************************/

/// Plasma rods provide modifiers but no direct output
/obj/item/rbmk/fuel_rod/plasma/process_rod()
    return list(
        "flux" = 0,
        "radiation" = 0,
        "thermal_mult" = thermal_multiplier,
        "flux_mult" = flux_multiplier
    )
