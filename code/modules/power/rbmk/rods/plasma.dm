/************************************************************
 * Plasma Moderator Rod
 * - Never depletes
 * - Amplifies reactor heat output and flux danger
 * - Produces no direct radiation or heat itself
 ************************************************************/

/obj/item/rbmk/fuel_rod/plasma
    name = "Plasma Moderator Rod"
    desc = "Amplifies the reactor’s thermal output without depleting, but makes flux more dangerous."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "plasma"

    fuel_amount = INFINITY         // infinite life
    heat_per_tick = 0
    rad_output = 0
    flux_output = 0
    active = TRUE

    rod_type = "plasma"
    rod_color = "purple"

    // These rods amplify core multipliers
    thermal_mult = 1.25
    flux_mult = 1.1
    rad_mult = 1.0

/************************************************************
 * Plasma rods override process_rod entirely
 ************************************************************/
/obj/item/rbmk/fuel_rod/plasma/process_rod()
    // Plasma rods do not burn fuel or deactivate
    return list(
        "flux"         = 0,
        "heat"         = 0,
        "radiation"    = 0,
        "thermal_mult" = thermal_mult,   // amplifies heat effects in reactor
        "flux_mult"    = flux_mult       // makes flux more aggressive
    )
