/*************************************************************
 * RBMK Reactor Core (single 3×3 sprite)
 * - Handles rod storage, visuals, atmos ports, and console sync
 * - Processing logic handled in rbmk_process.dm
 *************************************************************/

/// Reactor core
/obj/machinery/rbmk/reactor
    name = "RBMK Reactor Core"
    desc = "A massive nuclear reactor core. Insert rods at your own risk."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = "reactor_off"

    // --- Physical properties ---
    anchored = TRUE
    density = TRUE
    mouse_opacity = 2
    bound_width = 96
    bound_height = 96
    bound_x = -32
    bound_y = -32
    pixel_x = -32
    pixel_y = -32

    // --- Layering ---
    layer = BELOW_OBJ_LAYER
    plane = GAME_PLANE

    // --- Atmos / port vars ---
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

    // --- Fuel slots (now hold data lists, not objects) ---
    var/list/normal_slots = list()
    var/list/special_slots = list()
    var/max_normal_slots = 12
    var/max_special_slots = 4

    // --- State ---
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

    // --- Moderator ---
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
    pixel_x = -32
    pixel_y = -32

    var/turf/T = get_turf(src)
    var/datum/gas_mixture/env = T ? T.return_air() : null
    temperature = env ? env.temperature : (T0C + 20)

    // Init empty slots
    normal_slots = list()
    special_slots = list()
    for(var/i in 1 to max_normal_slots)
        normal_slots[i] = null
    for(var/j in 1 to max_special_slots)
        special_slots[j] = null

    rbmk_init_coolant(src)
    START_PROCESSING(SSmachines, src)
    rbmk_relink_ports(src)

/// Cleanup
/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    rbmk_cleanup_atmos(src)
    return ..()

/*************************************************************
 * Interaction — click handling
 *************************************************************/

/// Click with hand — if holding a rod, insert it
/obj/machinery/rbmk/reactor/attack_hand(mob/user)
    if(QDELETED(user))
        return
    var/obj/item/I = user.get_active_held_item()
    if(istype(I, /obj/item/rbmk/fuel_rod))
        world.log << "🧪 attack_hand(): Holding [I.type]"
        if(try_insert_rod(I, user))
            playsound(src, 'sound/machines/click.ogg', 50, TRUE)
            play_center_click(user)
            return
    else
        world.log << "❌ attack_hand(): [I] is not a /obj/item/rbmk/fuel_rod"

/*************************************************************
 * Visual click helper
 *************************************************************/

/// Plays a centered attack animation on the reactor
/obj/machinery/rbmk/reactor/proc/play_center_click(mob/user)
    if(!user) return
    var/turf/T = get_turf(src)
    if(!T) return
    var/turf/center = locate(T.x + 1, T.y + 1, T.z)
    if(center)
        user.do_attack_animation(center)

/*************************************************************
 * Rod Handling (debug + qdel)
 *************************************************************/

/// Inserts a rod and stores its data internally
/obj/machinery/rbmk/reactor/proc/try_insert_rod(obj/item/rbmk/fuel_rod/R, mob/user)
    if(!R)
        world.log << "❌ No rod reference!"
        return FALSE

    world.log << "⚙️ try_insert_rod() called with [R] ([R.type])"
    if(QDELETED(R))
        world.log << "❌ Rod already deleted!"
        return FALSE

    // Ensure slots exist
    if(!length(normal_slots))
        normal_slots = list()
        for(var/i in 1 to max_normal_slots)
            normal_slots[i] = null
    if(!length(special_slots))
        special_slots = list()
        for(var/j in 1 to max_special_slots)
            special_slots[j] = null

    // Choose slot type
    var/list/target_slots
    var/slot_type = "normal"
    if(R.rod_type in list("plasma", "telecrystal", "supermatter"))
        target_slots = special_slots
        slot_type = "special"
    else
        target_slots = normal_slots

    world.log << "➡ Target slot type: [slot_type] ([length(target_slots)] slots)"

    // Try insertion
    for(var/i in 1 to length(target_slots))
        if(!target_slots[i])
            world.log << "✅ Found empty slot #[i], inserting..."
            var/list/rod_data = list(
                "fuel_amount"   = R.fuel_amount,
                "heat_per_tick" = R.heat_per_tick,
                "rad_output"    = R.rad_output,
                "flux_output"   = R.flux_output,
                "thermal_mult"  = R.thermal_mult,
                "flux_mult"     = R.flux_mult,
                "rad_mult"      = R.rad_mult,
                "rod_type"      = R.rod_type,
                "rod_color"     = R.rod_color
            )

            target_slots[i] = rod_data
            qdel(R)
            to_chat(user, span_notice("You insert a [rod_data["rod_type"]] fuel rod into the [slot_type] reactor slot."))
            world.log << "✅ qdel called successfully for [R.type] (slot #[i])"
            running = TRUE
            update_linked_consoles()
            return TRUE

    to_chat(user, span_warning("No available [slot_type] rod slots in the reactor!"))
    world.log << "❌ No available [slot_type] slots for [R.type]"
    return FALSE

/*************************************************************
 * Console Sync
 *************************************************************/

/// Update linked consoles
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for(var/obj/machinery/computer/rbmk_console/C in range(7, src))
        if(C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)
