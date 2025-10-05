/*************************************************************
 * RBMK Reactor Core (logic core = center of 3x3 footprint)
 * - Core handles rods, flux, instability, temperature
 * - Delegates all atmos/coolant logic to rbmk_atmos.dm
 *************************************************************/

/// RBMK Reactor
/obj/machinery/rbmk/reactor
    name = "RBMK Reactor Core"
    desc = "A massive nuclear reactor core. Insert rods at your own risk."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = "reactor_off"
    bound_width = 96
    bound_height = 96
    pixel_x = -32
    pixel_y = -32
    anchored = TRUE
    density = FALSE
    mouse_opacity = MOUSE_OPACITY_ICON
    plane = GAME_PLANE
    layer = OBJ_LAYER - 0.01

    // Ports (spawned by atmos)
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

    // Children for 3x3 footprint
    var/list/children = list()

    // Fuel rod slots (stored internally)
    var/list/normal_slots = list()
    var/list/special_slots = list()
    var/max_normal_slots = 12
    var/max_special_slots = 4

    // Reactor state
    var/temperature = 0
    var/radiation = 0
    var/thermal_output = 0
    var/max_temp = RBMK_MAX_TEMP
    var/running = FALSE

    // Control rods
    var/control_rod_depth = 0

    // Flux / Instability
    var/flux = 0
    var/instability = 0

    // Moderator tracking
    var/moderator_level = 0
    var/list/moderator_history = list()

    // Integrity
    var/max_reactor_integrity = RBMK_MAX_INTEGRITY
    var/reactor_integrity = RBMK_MAX_INTEGRITY
    var/repairable = FALSE

    // Coolant internals (handled in rbmk_atmos)
    var/datum/gas_mixture/coolant_internal
    var/coolant_volume_max = RBMK_COOLANT_VOLUME_MAX
    var/pressure = 0

    // Console/atmos vars
    var/inlet_open = FALSE
    var/outlet_open = FALSE
    var/inlet_rate = RBMK_INLET_RATE_MIN
    var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE

    // Telemetry history
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

    // No relocation (stay on turf center)
    var/turf/T = get_turf(src)
    if (istype(T))
        var/datum/gas_mixture/env = T.return_air()
        temperature = env ? env.temperature : (T0C + 20)
    else
        temperature = T0C + 20

    rbmk_init_coolant(src)
    START_PROCESSING(SSmachines, src)

    // Spawn child tiles (3x3 visual fillers)
    for (var/dx in -1 to 1)
        for (var/dy in -1 to 1)
            if(dx == 0 && dy == 0)
                continue
            var/turf/CT = locate(x+dx, y+dy, z)
            if(CT)
                var/obj/structure/rbmk/reactor_child/C = new(CT)
                C.parent = src
                children += C

    rbmk_relink_ports(src)

/// Cleanup
/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    for(var/C in children)
        qdel(C)
    rbmk_cleanup_atmos(src)
    return ..()

/*************************************************************
 * Processing
 *************************************************************/

/// Tick
/obj/machinery/rbmk/reactor/process(delta_time)
    if (!running)
        return

    var/rod_effect = (100 - control_rod_depth) / 100.0

    temperature = clamp(
        temperature + (rod_effect * RBMK_TEMP_GAIN_PER_TICK) - (control_rod_depth * RBMK_TEMP_LOSS_PER_DEPTH),
        0,
        RBMK_MAX_TEMP
    )

    radiation = clamp(
        (temperature * RBMK_RADIATION_TEMP_MULT) + (flux * RBMK_RADIATION_FLUX_MULT),
        0,
        RBMK_MAX_RADIATION
    )

    instability = clamp(
        instability + (rod_effect * RBMK_INSTABILITY_GAIN) + (flux * RBMK_INSTABILITY_FLUX_MULT),
        0,
        RBMK_MAX_INSTABILITY
    )

    flux = clamp(
        flux + (rod_effect * RBMK_FLUX_GAIN) - (moderator_level * RBMK_FLUX_MODERATOR_MULT),
        0,
        RBMK_MAX_FLUX
    )

    moderator_level = clamp(
        moderator_level - (rod_effect * RBMK_MODERATOR_DECAY) + (control_rod_depth * RBMK_MODERATOR_RECOVERY),
        0,
        RBMK_MAX_MODERATOR
    )

    moderator_history += moderator_level
    if (length(moderator_history) > 50)
        moderator_history.Cut(1, 2)

    rbmk_sample_coolant(src)
    if(coolant_internal)
        pressure = coolant_internal.return_pressure()

    update_linked_consoles()

/*************************************************************
 * Rod Handling
 *************************************************************/

/// Disable taking any melee damage
/obj/machinery/rbmk/reactor/attack_generic(mob/user, damage, ...)
    return FALSE

/// Handle left-click rod insertion only
/obj/machinery/rbmk/reactor/Click(location, control, params)
    if(!usr) return
    if(findtext(control, "left")) // only left-click
        var/obj/item/I = usr.get_active_held_item()
        if(istype(I, /obj/item/rbmk/fuel_rod))
            return try_insert_rod(I, usr)
    return ..()

/// Insert rod
/obj/machinery/rbmk/reactor/proc/try_insert_rod(obj/item/rbmk/fuel_rod/R, mob/user)
    if(!R) return FALSE

    for(var/i = 1, i <= max_normal_slots, i++)
        if(!(i in normal_slots) || !normal_slots[i])
            normal_slots[i] = list(
                "type" = R.type,
                "fuel_amount" = R.fuel_amount,
                "active" = TRUE
            )
            qdel(R)
            flick("reactor_insert", src)
            to_chat(user, span_notice("You insert a fuel rod into the reactor."))
            update_linked_consoles()
            return TRUE

    to_chat(user, span_warning("There are no free rod slots available in the reactor!"))
    return FALSE

/// Eject rod
/obj/machinery/rbmk/reactor/proc/eject_rod(kind, index, mob/user)
    if(kind == "normal" && index <= max_normal_slots)
        var/list/rod_data = normal_slots[index]
        if(rod_data)
            normal_slots[index] = null
            var/typepath = rod_data["type"]
            var/obj/item/rbmk/fuel_rod/newR = new typepath(get_turf(src))
            newR.fuel_amount = rod_data["fuel_amount"]
            newR.active = rod_data["active"]
            flick("reactor_eject", src)
            to_chat(user, span_notice("You eject [newR] from the reactor."))
            update_linked_consoles()
            return TRUE
    return FALSE

/*************************************************************
 * Console Sync
 *************************************************************/

/// Update consoles linked to this reactor
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for (var/obj/machinery/computer/rbmk_console/C in range(7, src))
        if (C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)

/*************************************************************
 * Reactor Child Tiles
 *************************************************************/

/// 3×3 fillers forwarding clicks + anims
/obj/structure/rbmk/reactor_child
    name = "RBMK Reactor Core"
    desc = "Part of a massive nuclear reactor core."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = ""
    anchored = TRUE
    density = TRUE
    mouse_opacity = MOUSE_OPACITY_ICON
    plane = GAME_PLANE
    layer = OBJ_LAYER - 0.01
    var/obj/machinery/rbmk/reactor/parent

/obj/structure/rbmk/reactor_child/Click(location, control, params)
    if(parent)
        if(findtext(control, "left"))
            flick("reactor_hit", src)
            return parent.Click(location, control, params)
    return ..()

/obj/structure/rbmk/reactor_child/attack_generic(mob/user, damage, ...)
    return FALSE

/obj/structure/rbmk/reactor_child/attackby(obj/item/I, mob/user, params)
    if(parent)
        return parent.attackby(I, user, params)
    return ..()

/obj/structure/rbmk/reactor_child/attack_hand(mob/user)
    if(parent)
        return parent.attack_hand(user)
    return ..()

/obj/structure/rbmk/reactor_child/CanPass(atom/movable/mover, turf/target)
    if(ismob(mover))
        return TRUE
    return ..()
