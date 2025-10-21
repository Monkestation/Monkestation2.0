/************************************************************
 * Thorium Fuel Rod
 * - More stable than uranium, but less efficient.
 * - Produces moderate heat and radiation with stabilizing effect.
 ************************************************************/

/// Thorium Fuel Rod
/obj/item/rbmk/fuel_rod/thorium
    name = "Thorium Fuel Rod"
    desc = "More stable than uranium, but less efficient."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "thorium"

    fuel_amount = 1200           // Total fuel charge
    heat_per_tick = 3            // Generates moderate heat
    rad_output = 6               // Moderate radiation output
    flux_output = 1              // Weaker neutron flux
    active = TRUE

    rod_type = "thorium"
    rod_color = "lightblue"

    thermal_mult = 0.9           // Stabilizing effect
    flux_mult = 1.0
    rad_mult = 1.0

/************************************************************
 * Thorium Rod Processing Logic
 ************************************************************/

/// Thorium burns slowly and stabilizes reactor temperature
/obj/item/rbmk/fuel_rod/thorium/process_rod()
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    fuel_amount -= 1

    return list(
        "flux"         = flux_output * flux_mult,       // weak neutron production
        "heat"         = heat_per_tick * thermal_mult,  // slightly moderated heat
        "radiation"    = rad_output * rad_mult,         // moderate radiation
        "thermal_mult" = thermal_mult,
        "flux_mult"    = flux_mult
    )
