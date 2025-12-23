/*************************************************************
 * URANIUM FUEL ROD — (2025 Model A)
 * -----------------------------------------------------------
 * - Hot, volatile, high-radiation output
 * - Standard SS13 uranium characteristics
 * - Balanced for RBMK Model-A flux system
 *************************************************************/

/// Uranium Fuel Rod
/obj/item/rbmk/fuel_rod/uranium
    name = "Uranium Fuel Rod"
    desc = "A volatile uranium fuel rod. Produces high heat and dangerous levels of radiation."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "uranium"

    // Depleted visual state
    depleted_icon_state = "uranium_used"
    depleted_description = "A spent uranium fuel rod."

    // Identification
    rod_type = "uranium"
    rod_color = "green"

    // Fuel system
    fuel_amount = 1000
    fuel_consumption = 1

    // Output characteristics
    reactivity = 12              // medium-high flux output
    thermal_multiplier = 1.2     // runs hot
    flux_multiplier = 1.0
    radiation_multiplier = 2.5   // uranium → strong radiation

    // Activation state
    active = TRUE


/*************************************************************
 * Uranium uses the default base process_rod().
 * Base logic handles:
 *   - fuel burn
 *   - active/depleted transitions
 *   - flux/radiation yield
 *   - thermal effects via multipliers
 *************************************************************/
