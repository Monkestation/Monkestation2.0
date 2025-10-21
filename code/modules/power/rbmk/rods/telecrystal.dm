/************************************************************
 * Telecrystal Fuel Rod
 * - Charges inside the reactor to accumulate energy
 * - Unstable rewards when cracked open
 ************************************************************/

/// Telecrystal Fuel Rod
/obj/item/rbmk/fuel_rod/telecrystal
    name = "Telecrystal Rod"
    desc = "Charges inside the reactor and can be cracked open for unstable rewards."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "tc_empty"

    fuel_amount = 0
    heat_per_tick = 0
    rad_output = 0
    flux_output = 0

    var/usable = TRUE

    rod_type = "telecrystal"
    rod_color = "crimson"

    thermal_mult = 1
    flux_mult = 1

/************************************************************
 * Telecrystal Rod Processing Logic
 ************************************************************/

/obj/item/rbmk/fuel_rod/telecrystal/process_rod()
    if(!usable || charged)
        return list(
            "flux"         = 0,
            "heat"         = 0,
            "radiation"    = 0,
            "thermal_mult" = 1,
            "flux_mult"    = 1
        )

    var/obj/machinery/rbmk/reactor/core = null
    if(istype(loc, /obj/machinery/rbmk/reactor))
        core = loc

    if(core && core.thermal_output >= 2000)
        var/charge_rate = 1
        if(core.thermal_output >= 10000)
            charge_rate = 3
        else if(core.thermal_output >= 5000)
            charge_rate = 2

        charge_progress += charge_rate

        if(charge_progress >= charge_max)
            charged = TRUE
            icon_state = "tc_full"
            to_chat(core, span_warning("[src] hums violently as it finishes charging with bluespace energy!"))

    return list(
        "flux"         = 0,
        "heat"         = 0,
        "radiation"    = 0,
        "thermal_mult" = 1,
        "flux_mult"    = 1
    )
