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
    layer = OBJ_LAYER

    // Ports (spawned by atmos)
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

    // Children for 3x3 footprint
    var/list/children = list()

    // Fuel rod slots
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

    // Flux / Instability (integrity handled in rbmk_integrity.dm)
    var/flux = 0
    var/instability = 0

    // Moderator tracking
    var/moderator_level = 0
    var/list/moderator_history = list()

    // Integrity variables
    var/max_reactor_integrity = RBMK_MAX_INTEGRITY
    var/reactor_integrity = RBMK_MAX_INTEGRITY
    var/repairable = FALSE

    // Coolant internals (managed by rbmk_atmos)
    var/datum/gas_mixture/coolant_internal
    var/coolant_volume_max = RBMK_COOLANT_VOLUME_MAX
    var/pressure = 0 // synced to coolant_internal pressure each tick

    // Console/atmos vars
    var/inlet_open = FALSE
    var/outlet_open = FALSE
    var/inlet_rate = RBMK_INLET_RATE_MIN
    var/inlet_rate_min = RBMK_INLET_RATE_MIN
    var/inlet_rate_max = RBMK_INLET_RATE_MAX
    var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE
    var/outlet_pressure_max = RBMK_OUTLET_PRESSURE_MAX

    // Coolant telemetry history (for graphs)
    var/list/coolant_pressure_history = list()
    var/list/coolant_temperature_history = list()
    var/list/coolant_total_moles_history = list()
    var/list/coolant_gas_hist = list()   // keyed by gas id → list of % values

/obj/machinery/rbmk/reactor/Initialize(mapload)
    . = ..()
    loc = locate(x+1, y+1, z)

    var/turf/T = get_turf(src)
    if (istype(T))
        var/datum/gas_mixture/env = T.return_air()
        temperature = env ? env.temperature : T0C + 20
    else
        temperature = T0C + 20

    // Setup internal coolant tank
    rbmk_init_coolant(src)

    START_PROCESSING(SSmachines, src)

    // Spawn child tiles
    for (var/dx in -1 to 1)
        for (var/dy in -1 to 1)
            if(dx == 0 && dy == 0)
                continue
            var/turf/CT = locate(x+dx, y+dy, z)
            if(CT)
                var/obj/structure/rbmk/reactor_child/C = new(CT)
                C.parent = src
                children += C

    // Place coolant ports
    rbmk_relink_ports(src)

/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    for(var/C in children)
        qdel(C)
    rbmk_cleanup_atmos(src)
    return ..()

/obj/machinery/rbmk/reactor/process(delta_time)
    if (!running)
        return

    // --- Reactor physics ---
    var/rod_effect = (100 - control_rod_depth) / 100.0

    // Temperature
    temperature = clamp(
        temperature + (rod_effect * RBMK_TEMP_GAIN_PER_TICK) - (control_rod_depth * RBMK_TEMP_LOSS_PER_DEPTH),
        0,
        RBMK_MAX_TEMP
    )

    // Radiation
    radiation = clamp(
        (temperature * RBMK_RADIATION_TEMP_MULT) + (flux * RBMK_RADIATION_FLUX_MULT),
        0,
        RBMK_MAX_RADIATION
    )

    // Instability
    instability = clamp(
        instability + (rod_effect * RBMK_INSTABILITY_GAIN) + (flux * RBMK_INSTABILITY_FLUX_MULT),
        0,
        RBMK_MAX_INSTABILITY
    )

    // Flux
    flux = clamp(
        flux + (rod_effect * RBMK_FLUX_GAIN) - (moderator_level * RBMK_FLUX_MODERATOR_MULT),
        0,
        RBMK_MAX_FLUX
    )

    // Moderator
    moderator_level = clamp(
        moderator_level - (rod_effect * RBMK_MODERATOR_DECAY) + (control_rod_depth * RBMK_MODERATOR_RECOVERY),
        0,
        RBMK_MAX_MODERATOR
    )

    moderator_history += moderator_level
    if (length(moderator_history) > 50)
        moderator_history.Cut(1, 2)

    // --- Atmos handling ---
    // Ports now handle gas transfer directly; we only sample
    rbmk_sample_coolant(src)

    // Sync pressure var for console/integrity
    if(coolant_internal)
        pressure = coolant_internal.return_pressure()

    update_linked_consoles()

/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for (var/obj/machinery/computer/rbmk_console/C in range(7, src))
        if (C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)

/*************************************************************
 * Reactor Child Tiles
 *************************************************************/

/// Children
/obj/structure/rbmk/reactor_child
    name = "RBMK Reactor Core"
    desc = "Part of a massive nuclear reactor core."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = ""
    anchored = TRUE
    density = FALSE
    mouse_opacity = MOUSE_OPACITY_ICON
    var/obj/machinery/rbmk/reactor/parent

/obj/structure/rbmk/reactor_child/attackby(obj/item/I, mob/user, params)
    if(parent)
        return parent.attackby(I, user, params)
    return ..()

/obj/structure/rbmk/reactor_child/attack_hand(mob/user)
    if(parent)
        return parent.attack_hand(user)
    return ..()
