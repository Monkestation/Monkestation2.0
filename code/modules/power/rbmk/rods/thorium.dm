/************************************************************
 * Thorium Fuel Rod
 * - More stable than uranium, but less efficient.
 ************************************************************/

/obj/item/rbmk/fuel_rod/thorium
    name = "Thorium Fuel Rod"
    desc = "More stable than uranium, but less efficient."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "thorium"

    fuel_amount = 1200            // Total fuel charge
    heat_per_tick = 3            // Generates moderate heat
    rad_output = 6               // Moderate radiation output
    flux_output = 1              // Weaker neutron flux
    rod_type = "thorium"
    rod_color = "lightblue"

/************************************************************
 * Thorium Rod Processing Logic
 ************************************************************/

/obj/item/rbmk/fuel_rod/thorium/process_rod()
    // Fuel burn
    if (fuel_amount > 0)
        fuel_amount -= 1
    else
        if (active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    // Return contributions to reactor
    return list(
        "flux"        = flux_output,     // Weak neutron production
        "heat"        = heat_per_tick,   // Moderate heat generation
        "radiation"   = rad_output,      // Moderate radiation
        "thermal_mult" = 0.9             // Stabilizing effect: slows temperature growth
    )
