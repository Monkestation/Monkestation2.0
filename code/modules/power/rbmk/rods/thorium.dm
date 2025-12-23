/*************************************************************
 * THORIUM FUEL ROD — (2025 Model A)
 * -----------------------------------------------------------
 * - Long-lasting
 * - Extremely stable
 * - Low heat + flux
 * - Moderate radiation
 * - Ideal “balancing” rod for stable RBMK operation
 *************************************************************/

/// Thorium Fuel Rod
/obj/item/rbmk/fuel_rod/thorium
    name = "Thorium Fuel Rod"
    desc = "A stable, long-lasting fuel rod with moderate radiation output and low thermal load."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "thorium"

    // Depleted rod appearance
    depleted_icon_state = "thorium_used"
    depleted_description = "A spent thorium fuel rod."

    // Identification
    rod_type = "thorium"
    rod_color = "lightblue"

    // Fuel system
    fuel_amount = 1200
    fuel_consumption = 1

    // Output behavior
    reactivity = 8                 // stable, moderate neutron yield
    thermal_multiplier = 0.8       // runs cool
    flux_multiplier = 0.8          // slightly moderates neutron flux
    radiation_multiplier = 1.4     // modest radiation output

    // Activation state
    active = TRUE


/*************************************************************
 * Thorium uses the DEFAULT fuel rod process behavior.
 * Base rod logic handles:
 * - fuel burn
 * - active/depleted state changes
 * - reactivity → flux/radiation mapping
 * - reactor integration
 *************************************************************/
