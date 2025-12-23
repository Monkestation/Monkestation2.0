/*************************************************************
 * RBMK Reactor Core (Stable-Core Rod-Driven Model)
 * -----------------------------------------------------------
 * - Fuel rods → reactivity → flux → heat
 * - Coolant absorbs heat → produces pressure
 * - Structural integrity damaged by temp / pressure
 * - Void Coefficient (VC) amplifies flux
 * - Instability fully removed
 *************************************************************/

/*************************************************************
 * Reactor Object Definition
 *************************************************************/

/// RBMK Core Machine
/obj/machinery/rbmk/reactor
    name = "RBMK Reactor Core"
    desc = "A massive nuclear reactor core. Insert rods at your own risk."
    icon = 'icons/obj/machines/rbmk.dmi'
    icon_state = "reactor_off"

    anchored = TRUE
    density = FALSE
    mouse_opacity = MOUSE_OPACITY_ICON

    bound_width = 96
    bound_height = 96
    bound_x = -32
    bound_y = -32
    pixel_x = -32
    pixel_y = -32

    layer = OBJ_LAYER + 0.01
    plane = GAME_PLANE


    /************************************************
     * Atmos / Port Variables
     ************************************************/
    var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet
    var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet


    /*********************************************************
     * Rod Storage
     *********************************************************/
    var/list/normal_slots = list()
    var/list/special_slots = list()
    var/max_normal_slots = 12
    var/max_special_slots = 4


    /*********************************************************
     * Core State
     *********************************************************/
    var/temperature = 0
    var/radiation = 0
    var/thermal_output = 0
    var/max_temp = RBMK_MAX_TEMP
    var/running = FALSE
    var/scrammed = FALSE
    var/decay_heat = 0


    /*********************************************************
     * Reactivity & VC
     *********************************************************/
    var/control_rod_depth = 0
    var/flux = 0
    var/void_coefficient = 0


    /*********************************************************
     * Structural Integrity
     *********************************************************/
    var/max_reactor_integrity = RBMK_MAX_INTEGRITY
    var/reactor_integrity = RBMK_MAX_INTEGRITY
    var/repairable = FALSE


    /*********************************************************
     * Coolant & Pressure
     *********************************************************/
    var/datum/gas_mixture/coolant_internal
    var/coolant_volume_max = RBMK_COOLANT_VOLUME_MAX
    var/pressure = 0
    var/inlet_open = FALSE
    var/outlet_open = FALSE
    var/inlet_rate = RBMK_INLET_RATE_MIN
    var/outlet_target_pressure = RBMK_OUTLET_PRESSURE_BASE


    /*********************************************************
     * Telemetry History (required for console + sampling)
     *********************************************************/
    var/list/coolant_pressure_history       = list()
    var/list/coolant_temperature_history    = list()
    var/list/coolant_total_moles_history    = list()
    var/list/coolant_gas_hist               = list()
    var/list/reactor_temperature_history    = list()


    /*********************************************************
     * Tick Snapshot
     *********************************************************/
    var/last_tick_flux = 0
    var/last_tick_temp_gain = 0
    var/last_tick_rod_count = 0



/*************************************************************
 * Initialization
 *************************************************************/

/// Initialize
/obj/machinery/rbmk/reactor/Initialize(mapload)
    . = ..()

    var/turf/reactor_turf = get_turf(src)
    var/datum/gas_mixture/environment_mix = reactor_turf ? reactor_turf.return_air() : null

    temperature = environment_mix ? environment_mix.temperature : (T0C + 20)
    if (temperature < RBMK_AMBIENT_TEMP)
        temperature = RBMK_AMBIENT_TEMP

    normal_slots = list()
    special_slots = list()

    rbmk_init_coolant(src)
    START_PROCESSING(SSmachines, src)
    relink_ports()

    return INITIALIZE_HINT_NORMAL



/// Destroy
/obj/machinery/rbmk/reactor/Destroy()
    STOP_PROCESSING(SSmachines, src)
    rbmk_cleanup_atmos(src)
    return ..()



/*************************************************************
 * SCRAM (ADDED — DOES NOT REMOVE ANY LOGIC)
 *************************************************************/

/// Emergency shutdown (AZ-5)
/obj/machinery/rbmk/reactor/proc/force_scram()
    if (scrammed)
        return

    control_rod_depth = RBMK_CONTROL_ROD_MAX
    inlet_open = FALSE
    outlet_open = FALSE
    running = FALSE
    scrammed = TRUE

    update_icon()
    update_linked_consoles()



/*************************************************************
 * Main Reactor Tick
 *************************************************************/

/// Reactor processing loop
/obj/machinery/rbmk/reactor/process()

    // 1 — Core destroyed
    if (reactor_integrity <= 0)
        return

    // 2 — Control rods fully inserted → SCRAM (FIXED)
    if (control_rod_depth >= RBMK_CONTROL_ROD_MAX)
        force_scram()
        return

    // 3 — Idle reactor → nothing to do
    if (!running)
        return



    /*********************************************************
     * 4 — Collect reactivity from rods
     *********************************************************/
    var/total_reactivity_value = 0
    var/active_rod_count = 0

    for (var/obj/item/rbmk/fuel_rod/rod in (normal_slots + special_slots))
        if (!rod || !rod.active)
            continue

        rod.fuel_amount = max(rod.fuel_amount - rod.fuel_consumption, 0)

        if (rod.fuel_amount <= 0)
            rod.active = FALSE
            continue

        total_reactivity_value += rod.reactivity
        active_rod_count += 1

    if (active_rod_count == 0)
        force_scram()
        return

    last_tick_rod_count = active_rod_count



    /*********************************************************
     * 5 — Control rod dampening
     *********************************************************/
    var/control_multiplier = clamp(
        1 - (control_rod_depth / RBMK_CONTROL_ROD_MAX),
        0,
        1
    )

    total_reactivity_value *= control_multiplier



    /*********************************************************
     * 6 — Convert reactivity → flux + heat
     *********************************************************/
    var/temperature_gain = total_reactivity_value * RBMK_TEMP_GAIN_PER_TICK
    var/flux_gain        = total_reactivity_value * RBMK_FLUX_GAIN

    temperature += temperature_gain
    flux += flux_gain

    last_tick_temp_gain = temperature_gain
    last_tick_flux      = flux_gain



    /*********************************************************
     * 7 — Update Void Coefficient
     *********************************************************/
    update_void_coefficient()

    flux *= (1 + void_coefficient)
    flux = clamp(flux, 0, RBMK_MAX_FLUX)



    /*********************************************************
     * 8 — Coolant absorption
     *********************************************************/
    if (coolant_internal)
        var/absorption_multiplier = inlet_open ? inlet_rate / 100 : 0
        var/heat_absorbed = min(
            temperature * RBMK_HEAT_SCALING * absorption_multiplier,
            temperature
        )

        temperature -= heat_absorbed
        pressure += heat_absorbed * 0.4

        if (outlet_open)
            pressure = max(
                pressure - (outlet_target_pressure / 125),
                0
            )



    /*********************************************************
     * 9 — Radiation generation
     *********************************************************/
    radiation = (temperature * RBMK_RADIATION_TEMP_MULT) + (flux * RBMK_RADIATION_FLUX_MULT)

    /*********************************************************
     * 10 — Structural integrity update
     *********************************************************/
    update_reactor_integrity()



    /*********************************************************
     * 11 — Natural decay
     *********************************************************/
    flux      = max(flux - RBMK_FLUX_DECAY, 0)
    radiation = max(radiation - RBMK_RADIATION_DECAY, 0)



    /*********************************************************
     * 12 — Telemetry Logging
     *********************************************************/
    coolant_pressure_history += pressure
    reactor_temperature_history += temperature

    if (length(coolant_pressure_history) > 60)
        coolant_pressure_history.Cut(1, 2)

    update_linked_consoles()



/*************************************************************
 * Rod Handling
 *************************************************************/

/// Insert rod
/obj/machinery/rbmk/reactor/attackby(obj/item/item, mob/user, params)

    if (istype(item, /obj/item/rbmk/fuel_rod))
        var/obj/item/rbmk/fuel_rod/rod = item
        var/list/slot_list
        var/slot_type

        if (rod.rod_type in list("plasma", "telecrystal", "supermatter"))
            slot_list = special_slots
            slot_type = "special"
            if (length(special_slots) >= max_special_slots)
                to_chat(user, span_warning("All special rod slots are occupied!"))
                return TRUE
        else
            slot_list = normal_slots
            slot_type = "normal"
            if (length(normal_slots) >= max_normal_slots)
                to_chat(user, span_warning("All normal rod slots are occupied!"))
                return TRUE

        if (!user.transferItemToLoc(rod, src))
            return TRUE

        slot_list += rod

        to_chat(user, span_notice("You insert [rod.name] into a [slot_type] slot of the reactor."))
        playsound(src, 'sound/machines/click.ogg', 50, TRUE)

        running = TRUE
        scrammed = FALSE

        update_icon()
        update_linked_consoles()
        return TRUE

    return ..()



/// Remove rod
/obj/machinery/rbmk/reactor/attack_hand(mob/user)

    var/obj/item/rbmk/fuel_rod/rod

    if (length(special_slots))
        rod = special_slots[length(special_slots)]
        special_slots -= rod
    else if (length(normal_slots))
        rod = normal_slots[length(normal_slots)]
        normal_slots -= rod
    else
        to_chat(user, span_notice("No rods installed."))
        return

    rod.forceMove(get_turf(src))

    to_chat(user, span_notice("You remove [rod.name] from the reactor."))
    playsound(src, 'sound/machines/click.ogg', 50, TRUE)

    if (!length(normal_slots) && !length(special_slots))
        force_scram()

    update_icon()
    update_linked_consoles()



/*************************************************************
 * Icon Handling (ADDED)
 *************************************************************/

/// Update reactor sprite
/obj/machinery/rbmk/reactor/update_icon()
    . = ..()  // REQUIRED: let atom do its appearance work

    if (scrammed)
        icon_state = "reactor_scram"
    else if (running)
        icon_state = "reactor_on"
    else
        icon_state = "reactor_off"

/*************************************************************
 * Console Sync
 *************************************************************/

/// Update console UIs nearby
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
    for (var/obj/machinery/computer/rbmk_console/C in range(7, src))
        if (C.linked_reactor == src)
            C.update_icon()
            SStgui.update_uis(C)
