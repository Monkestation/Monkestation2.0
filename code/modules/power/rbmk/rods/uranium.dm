/************************************************************
 * Uranium Fuel Rod
 * - The classic choice: powerful but unstable.
 * - Produces significant heat, radiation, and moderate flux.
 ************************************************************/

/// Uranium Fuel Rod
/obj/item/rbmk/fuel_rod/uranium
    name = "Uranium Fuel Rod"
    desc = "A classic uranium fuel rod, powerful but unstable."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "uranium"

    fuel_amount = 1000           // Total fuel charge
    heat_per_tick = 5            // Generates high heat
    rad_output = 10              // High radiation output
    flux_output = 2              // Moderate neutron flux
    active = TRUE

    rod_type = "uranium"
    rod_color = "green"

    thermal_mult = 1.0           // No stabilizing effect (volatile)
    flux_mult = 1.0
    rad_mult = 1.0

/************************************************************
 * Uranium Rod Processing Logic
 ************************************************************/

/// Burns fuel steadily, generating heat, flux, and radiation
/obj/item/rbmk/fuel_rod/uranium/process_rod()
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    fuel_amount -= 1

    return list(
        "flux"         = flux_output * flux_mult,       // moderate neutron production
        "heat"         = heat_per_tick * thermal_mult,  // significant heat output
        "radiation"    = rad_output * rad_mult,         // heavy radiation
        "thermal_mult" = thermal_mult,
        "flux_mult"    = flux_mult
    )
