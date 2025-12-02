/*************************************************************
 * RBMK Fuel Rod (Base Type)
 * - Provides standardized depletion & output behavior
 * - Scales dynamically with reactor temperature and flux
 * - Compatible with modular RBMK system (2025 revision)
 *************************************************************/

/// Base RBMK Fuel Rod
/obj/item/rbmk/fuel_rod
    name = "Fuel Rod"
    desc = "A generic RBMK fuel rod used to sustain fission reactions."
    icon = 'icons/obj/fuel_rod.dmi'
    layer = OBJ_LAYER
    plane = GAME_PLANE

    /*************************************************************
     * Core variables
     *************************************************************/
    var/fuel_amount = 100                   // Remaining fuel
    var/base_heat_output = 25               // Base thermal output per tick
    var/base_flux_output = 8                // Base neutron flux per tick
    var/base_radiation_output = 4           // Base radiation per tick
    var/depletion_rate = 1                  // Fuel consumed per tick
    var/reactivity_sensitivity = 0.002      // Sensitivity to temperature & flux
    var/core_feedback_last = 1.0            // Last calculated reactivity factor

    // Multipliers for behavior tuning (used by subtypes)
    var/thermal_multiplier = 1.0
    var/flux_multiplier = 1.0
    var/radiation_multiplier = 1.0

    // Thresholds for special effects (used by subtypes)
    var/heat_penalty_threshold = 0
    var/flux_boost_threshold = 0

    // Operational state
    var/active = TRUE                       // Whether the rod is producing output
    var/usable = TRUE                       // Whether the rod can be inserted into a reactor
    var/rod_type = "generic"
    var/rod_color = "white"

    // Derived runtime value
    var/fuel_power = 0                      // Calculated during Initialize()

    // Visual and descriptive changes when depleted
    var/depleted_icon_state = "empty"
    var/depleted_description = "A spent fuel rod, inert and useless."

    /*************************************************************
     * Universal charge system (for special rods)
     * - Used by telecrystal, supermatter, plasma variants
     *************************************************************/
    var/charge_progress = 0                 // Current accumulated charge level
    var/charge_max = 100                    // Maximum charge threshold
    var/charged = FALSE                     // Whether rod is fully charged


/*************************************************************
 * Initialization — runtime setup
 *************************************************************/

/// Initialize rod and compute fuel power dynamically
/obj/item/rbmk/fuel_rod/Initialize()
    . = ..()
    fuel_power = (base_flux_output + base_heat_output) * 0.5


/*************************************************************
 * Interaction — insertion into reactor
 *************************************************************/

/// Handles direct click interaction on reactor
/obj/item/rbmk/fuel_rod/afterattack(atom/target_atom, mob/user, proximity_flag, click_parameters)
    if (!target_atom || QDELETED(target_atom))
        return ..()

    if (istype(target_atom, /obj/machinery/rbmk/reactor))
        var/obj/machinery/rbmk/reactor/reactor_core = target_atom

        if (reactor_core.attackby(src, user))
            playsound(reactor_core, 'sound/machines/click.ogg', 50, TRUE)
            user.do_attack_animation(reactor_core)
        else
            to_chat(user, span_warning("The reactor cannot accept that rod right now."))
        return TRUE

    return ..()


/*************************************************************
 * Processing — core response to reactor feedback
 *************************************************************/

/// Called every process tick by reactor
/obj/item/rbmk/fuel_rod/proc/process_rod(var/reactor_temperature = RBMK_AMBIENT_TEMP, var/reactor_flux = 0, var/core_feedback_factor = 1.0)
    // Depleted rod behavior
    if (fuel_amount <= 0)
        if (active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_description
        return list(
            "heat" = 0,
            "flux" = 0,
            "radiation" = 0,
            "thermal_mult" = 1.0,
            "flux_mult" = 1.0
        )

    // Consume fuel gradually
    fuel_amount = max(0, fuel_amount - depletion_rate)

    // Calculate environmental multipliers
    var/temperature_factor = 1 + ((reactor_temperature - RBMK_AMBIENT_TEMP) * reactivity_sensitivity)
    var/flux_factor = 1 + (reactor_flux * 0.01)
    var/reactivity_factor = clamp(core_feedback_factor * temperature_factor * flux_factor, 0.5, 3.5)
    core_feedback_last = reactivity_factor

    // Output calculations
    var/heat_output = base_heat_output * reactivity_factor * thermal_multiplier
    var/flux_output = base_flux_output * reactivity_factor * flux_multiplier
    var/radiation_output = base_radiation_output * sqrt(reactivity_factor) * radiation_multiplier

    return list(
        "heat" = heat_output,
        "flux" = flux_output,
        "radiation" = radiation_output,
        "thermal_mult" = thermal_multiplier,
        "flux_mult" = flux_multiplier
    )
