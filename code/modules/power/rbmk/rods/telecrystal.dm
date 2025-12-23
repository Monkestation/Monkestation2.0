/************************************************************
 * Telecrystal Fuel Rod
 * - Absorbs reactor heat and radiation to charge unstable
 *   bluespace energy.
 * - When fully charged, provides passive flux modulation.
 ************************************************************/

/// Telecrystal Fuel Rod Type
/obj/item/rbmk/fuel_rod/telecrystal
    name = "Telecrystal Fuel Rod"
    desc = "A crystalline rod that absorbs heat and radiation to build unstable bluespace charge."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "tc_empty"

    // Depleted / charged appearance
    depleted_icon_state = "tc_full"
    depleted_description = "A cracked, inert telecrystal rod."

    // Identification
    rod_type = "telecrystal"
    rod_color = "cyan"

    // Fuel system (telecrystal effectively does not consume fuel)
    fuel_amount = 1e9
    fuel_consumption = 0   // override base depletion logic

    // Base outputs (do not directly emit flux/heat/rads)
    reactivity = 0
    flux_multiplier = 1.05
    radiation_multiplier = 1.0
    thermal_multiplier = 1.0

    // Activation state
    active = TRUE

    // Charging behavior
    var/charge_progress = 0
    var/charge_max = 500
    var/charged = FALSE
    var/usable = TRUE



/************************************************************
 * Telecrystal Rod Processing — Overrides Base Logic
 * Reactor does NOT call this version yet unless integrated.
 ************************************************************/

/// Processes telecrystal-specific behavior
/obj/item/rbmk/fuel_rod/telecrystal/process_rod(
    var/reactor_temperature = RBMK_AMBIENT_TEMP,
    var/reactor_flux = 0,
    var/core_feedback_factor = 1.0
)
    // Rod disabled or unusable
    if (!active || !usable)
        return list(
            "heat" = 0,
            "flux" = 0,
            "radiation" = 0,
            "thermal_mult" = 1.0,
            "flux_mult" = 1.0
        )

    // Fully charged — provides passive stabilization
    if (charged)
        return list(
            "heat" = 0,
            "flux" = 0,          // telecrystal does not emit direct flux
            "radiation" = 0,
            "thermal_mult" = 1.0,
            "flux_mult" = 1.10   // small reactor-wide flux modulation
        )

    // Determine charge rate based on reactor stress
    var/charge_rate = 0

    if (reactor_temperature >= 10000)
        charge_rate = 3
    else if (reactor_temperature >= 5000)
        charge_rate = 2
    else if (reactor_temperature >= 2000)
        charge_rate = 1

    // Increase charge progression
    if (charge_rate > 0)
        charge_progress = min(charge_max, charge_progress + charge_rate)

    // Completion logic
    if (charge_progress >= charge_max && !charged)
        charged = TRUE
        icon_state = "tc_full"

    // Telecrystal emits mild flux proportional to charge %
    var/flux_output = (charge_progress / charge_max) * 0.5

    return list(
        "heat" = 0,
        "flux" = flux_output,
        "radiation" = 0,
        "thermal_mult" = thermal_multiplier,
        "flux_mult" = flux_multiplier
    )
