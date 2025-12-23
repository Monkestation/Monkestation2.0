/*************************************************************
 * RBMK FUEL ROD BASE (2025 Revision)
 * -----------------------------------------------------------
 * Rod variables:
 *   - fuel_amount
 *   - fuel_consumption
 *   - reactivity
 *   - flux_multiplier
 *   - radiation_multiplier
 *   - thermal_multiplier
 *   - active (rod inserted & producing output)
 *
 * Rods do *not* handle temperature or void coeff.
 * Reactor converts reactivity → flux → heat → VC → flux.
 *************************************************************/


/obj/item/rbmk/fuel_rod
    name = "Fuel Rod"
    desc = "A generic fuel rod designed for RBMK reactors."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "rod_generic"

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
 * Reactor handles all temperature/VC feedback.
 * Rods output only flux & radiation.
 *************************************************************/

/// Process this rod for a single tick
/obj/item/rbmk/fuel_rod/proc/process_rod()
    // Rod empty → deactivated
    if (fuel_amount <= 0)
        if (active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_description

        return list(
            "flux" = 0,
            "radiation" = 0
        )

    // Burn fuel
    fuel_amount = max(0, fuel_amount - fuel_consumption)

    // Output characteristics
    var/rod_flux_output = reactivity * flux_multiplier
    var/rod_radiation_output = reactivity * radiation_multiplier

    return list(
        "flux" = rod_flux_output,
        "radiation" = rod_radiation_output
    )
