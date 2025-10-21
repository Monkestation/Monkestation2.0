/************************************************************
 * Bananium Fuel Rod
 * - Ridiculous and silly, but still a functional moderator.
 * - Produces minor heat and radiation; acts as a weak stabilizer.
 ************************************************************/

/// Bananium Fuel Rod
/obj/item/rbmk/fuel_rod/bananium
    name = "Bananium Fuel Rod"
    desc = "Ridiculous and silly, but somehow still a functional moderator."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "bananium"

    fuel_amount = 600
    heat_per_tick = 2
    rad_output = 3
    flux_output = 1
    active = TRUE

    rod_type = "bananium"
    rod_color = "yellow"

    thermal_mult = 0.8  // goofy but stabilizing
    flux_mult = 1.0
    rad_mult = 1.0

/************************************************************
 * Bananium Rod Processing Logic
 ************************************************************/

/// Slowly burns, offering mild output and silly moderation
/obj/item/rbmk/fuel_rod/bananium/process_rod()
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    fuel_amount -= 1

    return list(
        "flux"         = flux_output * flux_mult,      // weak neutron moderation
        "heat"         = heat_per_tick * thermal_mult, // banana heat
        "radiation"    = rad_output * rad_mult,        // mild radiation
        "thermal_mult" = thermal_mult,                 // slightly stabilizing
        "flux_mult"    = flux_mult
    )
