/*************************************************************
 * RBMK FUEL ROD BASE (2025 CANONICAL)
 * -----------------------------------------------------------
 * CONTRACT:
 * - Rods are authoritative over:
 *     • fuel burn
 *     • activation/deactivation
 *     • per-rod output
 *
 * - Reactor integrates:
 *     Rods → Flux → Heat → Void Coefficient → Flux
 *************************************************************/


/obj/item/rbmk/fuel_rod
    name = "Fuel Rod"
    desc = "A generic fuel rod designed for RBMK reactors."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "rod_generic"
    layer = OBJ_LAYER + 0.02
    plane = GAME_PLANE


    // Identification
    var/rod_type = "generic"
    var/rod_color = "white"

    // Fuel system
    var/fuel_amount = 100
    var/fuel_consumption = 1

    // Output characteristics
    var/reactivity = 10                // Base neutronic output
    var/flux_multiplier = 1.0          // Flux scaling
    var/radiation_multiplier = 1.0     // Radiation scaling
    var/thermal_multiplier = 1.0       // Heat scaling

    // Whether the rod is actively contributing
    var/active = TRUE

    // Spent rod appearance/state
    var/depleted_icon_state = "rod_empty"
    var/depleted_description = "A spent fuel rod, inert."


/*************************************************************
 * PROCESS FUNCTION
 * Rods do NOT care about temperature or void coefficient.
 * They output raw physical quantities only.
 *************************************************************/

/// Process this rod for a single tick
/obj/item/rbmk/fuel_rod/proc/process_rod()

    // Spent rod → inert forever
    if (fuel_amount <= 0)
        if (active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_description

        return list(
            "flux" = 0,
            "radiation" = 0,
            "heat" = 0
        )

    // Burn fuel (authoritative)
    fuel_amount = max(0, fuel_amount - fuel_consumption)

    // Per-rod output
    var/rod_flux_output = reactivity * flux_multiplier
    var/rod_radiation_output = reactivity * radiation_multiplier
    var/rod_heat_output = reactivity * thermal_multiplier

    return list(
        "flux" = rod_flux_output,
        "radiation" = rod_radiation_output,
        "heat" = rod_heat_output
    )
