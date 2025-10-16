/************************************************************
 * Uranium Fuel Rod
 * - A classic uranium fuel rod, powerful but unstable.
 ************************************************************/

/obj/item/rbmk/fuel_rod/uranium
    name = "Uranium Fuel Rod"
    desc = "A classic uranium fuel rod, powerful but unstable."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "uranium"

    fuel_amount = 1000            // Total fuel charge
    heat_per_tick = 5            // Generates high heat
    rad_output = 10              // High radiation output
    flux_output = 2              // Moderate neutron flux
    rod_type = "uranium"
    rod_color = "green"

/************************************************************
 * Uranium Rod Processing Logic
 ************************************************************/

/obj/item/rbmk/fuel_rod/uranium/process_rod()
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
        "flux"        = flux_output,     // Moderate neutron production
        "heat"        = heat_per_tick,   // Generates significant heat
        "radiation"   = rad_output,      // High radiation output
        "thermal_mult" = 1.0             // No stabilizing effect (makes it very unstable)
    )
