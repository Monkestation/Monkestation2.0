/*************************************************************
 * PLUTONIUM FUEL ROD — (2025 Model A)
 * - High flux
 * - High heat
 * - Extremely radioactive
 * - Burns faster than uranium
 * - Must be cooled aggressively
 *************************************************************/

/// Plutonium Fuel Rod
/obj/item/rbmk/fuel_rod/plutonium
    name = "Plutonium Fuel Rod"
    desc = "A dangerously potent fuel rod with a massive neutron output. Requires aggressive cooling."
    icon = 'icons/obj/fuel_rod.dmi'
    icon_state = "plutonium"

    // Depleted state
    depleted_icon_state = "plutonium_used"
    depleted_description = "A spent plutonium rod. Still faintly warm."

    // Identification
    rod_type = "plutonium"
    rod_color = "crimson"

    // Fuel system
    fuel_amount = 800
    fuel_consumption = 1

    // Output behavior
    reactivity = 16                 // very strong base reactivity
    thermal_multiplier = 1.4        // produces a lot of heat
    flux_multiplier = 1.25          // amplifies neutron flux
    radiation_multiplier = 3.0      // extremely radioactive

    // Activation state
    active = TRUE


/*************************************************************
 * Plutonium uses default rod process behavior.
 *
 * Base process_rod() includes:
 * - fuel burn
 * - active state handling
 * - reactivity → flux/radiation mapping
 * - depletion state changes
 *************************************************************/
