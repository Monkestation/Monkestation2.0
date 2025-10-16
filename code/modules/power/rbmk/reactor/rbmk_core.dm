/*************************************************************
 * RBMK Reactor Core (single 3×3 sprite)
 * - Handles rods, visuals, atmos ports, and console sync
 * - Process logic handled in rbmk_process.dm
 *************************************************************/

/// RBMK Reactor Core
/obj/machinery/rbmk/reactor
    name = "RBMK Reactor Core"
    desc = "A massive nuclear reactor core. Insert rods at your own risk."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = "reactor_off"

    // --- Physical properties ---
    anchored = TRUE
    density = TRUE                      // solid, holds items
    mouse_opacity = 2                   // full clickable bounds
    bound_width = 96
    bound_height = 96
    pixel_x = -32
    pixel_y = -32

    // --- Layering ---
    plane = GAME_PLANE
    layer = ABOVE_OBJ_LAYER             // ensure rods render on top

    // --- Ports (spawned by atmos) ---
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

    // --- Fuel slots ---
    var/list/normal_slots = list()
    var/list/special_slots = list()
    var/max_normal_slots = 12
    var/max_special_slots = 4

    // --- Reactor state ---
    var/temperature = 0
    var/radiation = 0
    var/thermal_output = 0
    var/max_temp = RBMK_MAX_TEMP
    var/running = FALSE

    // --- Control rods ---
    var/control_rod_depth = 0

    // --- Instability / flux ---
    var/flux = 0
    var/instability = 0

    // --- Moderator tracking ---
    var/moderator_level = 0
    var/list/moderator_history = list()

    // --- Integrity ---
    var/max_reactor_integrity = RBMK_MAX_INTEGRITY
    var/reactor_integrity = RBMK_MAX_INTEGRITY
    var/repairable = FALSE

    // --- Coolant ---
    var/datum/gas_mixture/coolant_internal
    var/coolant_volume_max = RBMK_COOLANT_VOLUME_MAX
    var/pressure = 0

    // --- Console / atmos vars ---
    var/inlet_open = FALSE
    var/outlet_open = FALSE
    var/inlet_rate = RBMK_INLET_RATE_MIN
    var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE

    // --- History / telemetry ---
    var/list/coolant_pressure_history = list()
    var/list/coolant_temperature_history = list()
    var/list/coolant_total_moles_history = list()
    var/list/coolant_gas_hist = list()

/*************************************************************
 * Lifecycle
 *************************************************************/

/// Initialize
/obj/machinery/rbmk/reactor/Initialize(mapload)
    . = ..()

    // Ambient temperature baseline
    var/turf/T = get_turf(src)
    if(istype(T))
        var/datum/gas_mixture/env = T.return_air()
        temperature = env ? env.temperature : (T0C + 20)
    else
        temperature = T0C + 20

    // Initialize slots
    normal_slots = list()
    special_slots = list()
    for(var/i in 1 to max_normal_slots)
        normal_slots[i] = null
    for(var/j in 1 to max_special_slots)
        special_slots[j] = null

    // Setup coolant and processing
    rbmk_init_coolant(src)
    START_PROCESSING(SSmachines, src)
    rbmk_relink_ports(src)

/// Cleanup
/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    rbmk_cleanup_atmos(src)
    return ..()

/*************************************************************
 * Item Interaction (modern system)
 *************************************************************/

/// Called when a player clicks the reactor while holding an item
/obj/machinery/rbmk/reactor/item_interaction(mob/living/user, obj/item/I, list/modifiers)
    if(QDELETED(src) || QDELETED(I))
        return ITEM_INTERACT_BLOCKING

    if(!anchored)
        balloon_alert(user, "not secured!")
        return ITEM_INTERACT_BLOCKING

    // Only handle rods
    if(!istype(I, /obj/item/rbmk/fuel_rod))
        return ..()

    if(try_insert_rod(I, user))
        playsound(src, 'sound/machines/click.ogg', 50, TRUE)
        return ITEM_INTERACT_SUCCESS

    balloon_alert(user, "no available slots")
    return ITEM_INTERACT_BLOCKING

/*************************************************************
 * Rod Handling
 *************************************************************/

/// Disable melee damage
/obj/machinery/rbmk/reactor/attack_generic(mob/user, damage, ...)
    return FALSE

/// Legacy Click fallback (for admin or old calls)
/obj/machinery/rbmk/reactor/Click(location, control, params, mob/user)
    if(!user)
        return
    var/list/p = params2list(params)
    if(p["button"] == "left")
        var/obj/item/I = user.get_active_held_item()
        if(istype(I, /obj/item/rbmk/fuel_rod))
            if(try_insert_rod(I, user))
                return
    return ..()

/// Insert a fuel rod
/obj/machinery/rbmk/reactor/proc/try_insert_rod(obj/item/rbmk/fuel_rod/R, mob/user)
    if(!R || QDELETED(R))
        return FALSE

    var/list/target_slots
    var/slot_type = "normal"
    if(R.rod_type in list("plasma", "telecrystal"))
        target_slots = special_slots
        slot_type = "special"
    else
        target_slots = normal_slots

    var/max_slots = (slot_type == "special") ? max_special_slots : max_normal_slots

    // Find open slot
    for(var/i in 1 to max_slots)
        if(!target_slots[i])
            target_slots[i] = R

            // Move rod into the reactor
            if(!R.forceMove(src))
                to_chat(user, span_warning("The [R.name] failed to seat properly in the reactor!"))
                target_slots[i] = null
                return FALSE

            R.active = TRUE
            R.mouse_opacity = 0
            R.invisibility = 101
            R.anchored = TRUE
            R.density = FALSE
            R.layer = BELOW_MOB_LAYER

            to_chat(user, span_notice("You insert [R.name] into the [slot_type] reactor slot."))
            update_linked_consoles()
            return TRUE

    to_chat(user, span_warning("No available [slot_type] rod slots in the reactor!"))
    return FALSE

/// Eject a rod
/obj/machinery/rbmk/reactor/proc/eject_rod(kind, index, mob/user)
    var/list/slots = (kind == "special") ? special_slots : normal_slots
    if(index > length(slots))
        to_chat(user, span_warning("Invalid slot index."))
        return FALSE

    var/obj/item/rbmk/fuel_rod/R = slots[index]
    if(!R)
        to_chat(user, span_warning("That slot is empty."))
        return FALSE

    slots[index] = null
    R.forceMove(get_turf(src))
    R.invisibility = 0
    R.mouse_opacity = 1
    R.anchored = FALSE
    R.density = TRUE
    R.layer = ABOVE_MOB_LAYER

    to_chat(user, span_notice("You eject [R.name] from the reactor core."))
    update_linked_consoles()
    return TRUE

/*************************************************************
 * Collision / Rendering
 *************************************************************/

/// Let mobs walk across but make items rest visually on top
/obj/machinery/rbmk/reactor/CanPass(atom/movable/mover, turf/target)
    if(ismob(mover))
        return TRUE
    return ..()

/*************************************************************
 * Console Sync
 *************************************************************/

/// Update linked consoles
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for(var/obj/machinery/computer/rbmk_console/C in range(7, src))
        if(C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)
