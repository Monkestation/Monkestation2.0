/************************************************************
 * Telecrystal Fuel Rod
 * - Charges inside the reactor to accumulate energy
 * - Unstable rewards when cracked open
 ************************************************************/

/obj/item/rbmk/fuel_rod/telecrystal
    name = "Telecrystal Rod"
    desc = "Charges inside the reactor and can be cracked open for unstable rewards."
    icon = 'icons/obj/control_rod.dmi'
    icon_state = "tc_empty"

    fuel_amount = 0                 // Doesn't consume fuel
    heat_per_tick = 0               // No heat generation
    rad_output = 0                  // No radiation output
    flux_output = 0                 // No flux contribution

    var/charge_progress = 0
    var/charge_max = 720            // ~12 minutes at 1 tick/second
    var/charged = FALSE
    var/usable = TRUE

    rod_type = "telecrystal"
    rod_color = "crimson"

/************************************************************
 * Telecrystal Rod Processing Logic
 ************************************************************/

/obj/item/rbmk/fuel_rod/telecrystal/process_rod()
    // Inert if unusable or fully charged
    if (!usable || charged)
        return list(
            "flux"         = 0,
            "heat"         = 0,
            "radiation"    = 0,
            "thermal_mult" = 1,
            "flux_mult"    = 1
        )

    // Check if the rod is inside a reactor
    var/obj/machinery/rbmk/reactor/core = null
    if (istype(loc, /obj/machinery/rbmk/reactor))
        core = loc

    // Charge the rod if reactor output is sufficient
    if (core && core.thermal_output >= 2000)
        var/charge_rate = 1
        if (core.thermal_output >= 10000)
            charge_rate = 3
        else if (core.thermal_output >= 5000)
            charge_rate = 2

        charge_progress += charge_rate

        // Fully charged
        if (charge_progress >= charge_max)
            charged = TRUE
            icon_state = "tc_full"
            to_chat(core, span_warning("[src] hums violently as it finishes charging with bluespace energy!"))

    // While charging, there is no impact on reactor heat, flux, or radiation
    return list(
        "flux"         = 0,
        "heat"         = 0,
        "radiation"    = 0,
        "thermal_mult" = 1,
        "flux_mult"    = 1
    )
