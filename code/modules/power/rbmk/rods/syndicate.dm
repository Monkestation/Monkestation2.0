/************************************************************
 * Supermatter Fuel Rod
 * - A Syndicate-engineered rod containing a supermatter sliver
 * - Extremely dangerous and capable of meltdown events
 ************************************************************/

/// Supermatter Fuel Rod
/obj/item/rbmk/fuel_rod/supermatter
    name = "Supermatter Fuel Rod"
    desc = "A Syndicate-engineered rod containing a supermatter sliver. Extremely dangerous."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "supermatter"
    depleted_icon_state = "supermatter_empty"
    depleted_desc = "A shattered rod that once contained supermatter."

    fuel_amount = 50
    heat_per_tick = 200
    rad_output = 100
    flux_output = 0
    active = TRUE

    rod_type = "supermatter"
    rod_color = "gold"

    thermal_mult = 1.5
    flux_mult = 1.2

/************************************************************
 * Supermatter rod processing
 ************************************************************/

/// Supermatter rods can meltdown and produce huge radiation
/obj/item/rbmk/fuel_rod/supermatter/process_rod()
    // --- If inactive or out of fuel, return nothing ---
    if(!active || fuel_amount <= 0)
        return list()

    fuel_amount--

    // --- Handle depletion ---
    if(fuel_amount <= 0)
        active = FALSE
        icon_state = depleted_icon_state
        desc = depleted_desc

    // --- Contribution payload ---
    return list(
        "flux"         = 0,              // SM doesn’t produce neutrons
        "heat"         = heat_per_tick,  // massive heat output
        "radiation"    = rad_output,     // extreme radiation
        "thermal_mult" = thermal_mult,   // destabilizes temperature
        "flux_mult"    = flux_mult,      // amplifies flux
        "meltdown_chance" = 2            // pass chance for meltdown (percent)
    )
