/obj/item/rbmk/fuel_rod
    name = "Fuel Rod"
    desc = "A generic RBMK fuel rod."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "rod"
    anchored = FALSE
    w_class = WEIGHT_CLASS_NORMAL

    /************************************************************
     * Core variables
     ************************************************************/
    var/fuel_amount = 100            // total fuel charge
    var/heat_per_tick = 1            // temperature contribution
    var/rad_output = 5               // radiation output per tick
    var/flux_output = 0              // neutron flux contribution
    var/active = TRUE                // operational state

    // Depletion visuals
    var/depleted_icon_state = "empty"
    var/depleted_desc = "A spent fuel rod, inert and useless."

    // Visuals / categorization
    var/rod_type = "generic"
    var/rod_color = "white"
    var/icon_color = "white"

    /************************************************************
     * Contribution multipliers
     * (lets special rods override without redefining process_rod)
     ************************************************************/
    var/thermal_mult = 1.0           // multiplier on heat
    var/flux_mult = 1.0              // multiplier on flux
    var/rad_mult = 1.0               // multiplier on radiation

/************************************************************
 * Default processing (can be overridden by subtypes)
 ************************************************************/
/obj/item/rbmk/fuel_rod/proc/process_rod()
    // --- Fuel depletion ---
    if (fuel_amount > 0)
        fuel_amount -= 1
    else
        if (active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        return list()

    // --- Contribution payload ---
    return list(
        "flux"         = flux_output * flux_mult,
        "heat"         = heat_per_tick * thermal_mult,
        "radiation"    = rad_output * rad_mult,
        "flux_mult"    = flux_mult,       // so core can chain multipliers
        "thermal_mult" = thermal_mult
    )
