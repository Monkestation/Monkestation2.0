/************************************************************
 * RBMK Fuel Rod (Base Type)
 * - Provides standardized depletion & data output
 * - Subtypes override only what they need (fuel, outputs, visuals)
 ************************************************************/

/// Base RBMK Fuel Rod
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
    var/fuel_amount = 100
    var/heat_per_tick = 1
    var/rad_output = 5
    var/flux_output = 0
    var/active = TRUE

    var/depleted_icon_state = "empty"
    var/depleted_desc = "A spent fuel rod, inert and useless."

    var/rod_type = "generic"
    var/rod_color = "white"

    var/thermal_mult = 1.0
    var/flux_mult = 1.0
    var/rad_mult = 1.0 // affects radiation emission

    /************************************************************
     * Optional subtype vars (used by specific rods)
     ************************************************************/
    // Telecrystal
    var/charge_progress = 0
    var/charge_max = 0
    var/charged = FALSE

    // Supermatter
    var/sm_meltdown = FALSE

/************************************************************
 * Interaction — insert directly into a reactor
 ************************************************************/

/// When clicked on a reactor, hand off to the reactor's insertion logic
/obj/item/rbmk/fuel_rod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
    if(!target || QDELETED(target))
        return ..()

    if(istype(target, /obj/machinery/rbmk/reactor))
        var/obj/machinery/rbmk/reactor/R = target

        if(R.try_insert_rod(src, user))
            // Success → sound, animation, delete rod
            playsound(R, 'sound/machines/click.ogg', 50, TRUE)
            user.do_attack_animation(R)
            qdel(src)
        else
            to_chat(user, span_warning("The [R.name] has no available rod slots!"))
        return

    return ..()

/************************************************************
 * Processing (still available if a rod exists independently)
 ************************************************************/

/// Handles the rod’s ongoing behavior inside a reactor
/obj/item/rbmk/fuel_rod/proc/process_rod()
    if(fuel_amount <= 0)
        if(active)
            active = FALSE
            icon_state = depleted_icon_state
            desc = depleted_desc
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
