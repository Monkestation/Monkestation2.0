/************************************************************
 * RBMK Fuel Rod (Base Type)
 * - Provides standardized depletion & data output
 * - Subtypes override only what they need (fuel, outputs, visuals)
 ************************************************************/

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
    var/fuel_amount = 100                // total fuel charge (ticks of life)
    var/heat_per_tick = 1                // base temperature contribution
    var/rad_output = 5                   // radiation per tick
    var/flux_output = 0                  // neutron flux per tick
    var/active = TRUE                    // is this rod currently producing power?

    // Depletion visuals
    var/depleted_icon_state = "empty"
    var/depleted_desc = "A spent fuel rod, inert and useless."

    // Classification
    var/rod_type = "generic"
    var/rod_color = "white"

    /************************************************************
     * Multipliers (for subtypes / modifiers)
     ************************************************************/
    var/thermal_mult = 1.0               // affects heat generation
    var/flux_mult = 1.0                  // affects neutron output
    var/rad_mult = 1.0                   // affects radiation emission

/************************************************************
 * Processing (called every reactor cycle)
 ************************************************************/
/obj/item/rbmk/fuel_rod/proc/process_rod()
    // Handle depletion first
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
        // once depleted, return no contribution
        return list()

    fuel_amount -= 1

    // Return contribution payload
    return list(
        "flux"         = flux_output * flux_mult,
        "heat"         = heat_per_tick * thermal_mult,
        "radiation"    = rad_output * rad_mult,
        "thermal_mult" = thermal_mult,
        "flux_mult"    = flux_mult
    )
