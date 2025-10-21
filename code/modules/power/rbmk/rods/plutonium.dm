/************************************************************
 * Plutonium Fuel Rod
 * - Extremely powerful and unstable
 * - High radiation and flux output
 * - Burns faster and accelerates reactor heat growth
 ************************************************************/

/// Plutonium Fuel Rod
/obj/item/rbmk/fuel_rod/plutonium
    name = "Plutonium Fuel Rod"
    desc = "Extremely powerful and unstable, outputting heavy radiation."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "plutonium"

    fuel_amount = 800                 // shorter lifespan than uranium
    heat_per_tick = 7                 // generates high heat
    rad_output = 15                   // heavy radiation
    flux_output = 4                   // strong neutron production
    active = TRUE

    rod_type = "plutonium"
    rod_color = "white"

    // Behavior multipliers
    thermal_mult = 1.2                // amplifies heat
    flux_mult = 1.1                   // increases instability
    rad_mult = 1.3                    // boosts radiation effects

/************************************************************
 * Plutonium processing logic
 ************************************************************/

/// Plutonium rods burn fuel fast and run hot
/obj/item/rbmk/fuel_rod/plutonium/process_rod()
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    fuel_amount -= 1

    return list(
        "flux"         = flux_output * flux_mult,      // strong neutron flux
        "heat"         = heat_per_tick * thermal_mult, // extreme heat output
        "radiation"    = rad_output * rad_mult,        // high radiation
        "flux_mult"    = flux_mult,
        "thermal_mult" = thermal_mult
    )
