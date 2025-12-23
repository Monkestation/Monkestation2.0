/*************************************************************
 * RBMK Meltdown Logic — 2025 Linear-Core Revision
 * -----------------------------------------------------------
 * This version removes ALL instability mechanics.
 *
 * Meltdown now occurs from:
 *   - Extreme temperature
 *   - Extreme pressure
 *   - Integrity reaching zero
 *   - Post-SCRAM decay heat runaway
 *
 * Coolant only leaks during meltdown_atmos_release().
 *************************************************************/


/obj/machinery/rbmk/reactor
    var/meltdown_announced = FALSE
    var/meltdown_in_progress = FALSE

    // When SCRAMMED: meltdown risk increases if decay heat rises
    var/decay_meltdown_threshold = RBMK_MAX_TEMP * 0.92
    var/decay_check_interval = 2 SECONDS
    var/last_decay_check = 0


/*************************************************************
 * DECAY HEAT MELTDOWN CHECK
 * Runs ONLY when reactor is SCRAMMED, not running.
 *************************************************************/

/// Checks if decay heat causes a meltdown after shutdown
/obj/machinery/rbmk/reactor/proc/check_decay_meltdown()

    // Reactor must be SCRAMMED but not melted yet
    if (running || meltdown_in_progress)
        return

    // Time-gated checks
    if (world.time < last_decay_check + decay_check_interval)
        return

    last_decay_check = world.time

    // If temperature is climbing dangerously → meltdown
    if (temperature >= decay_meltdown_threshold)
        trigger_meltdown("Post-SCRAM decay heat runaway")



/*************************************************************
 * MELTDOWN TRIGGER
 *************************************************************/

/// Called when the RBMK irreversibly fails
/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)

    // Prevent double-triggering
    if (meltdown_in_progress)
        return

    meltdown_in_progress = TRUE

    // Global announcement
    if (!meltdown_announced)
        meltdown_announced = TRUE
        world << span_danger("[RBMK_MELTDOWN_PREFIX]: [reason]!")
        priority_announce("[RBMK_MELTDOWN_BROADCAST] [reason]", "RBMK Reactor Alert")

    /*********************************************************
     * PERMANENT SHUTDOWN STATE
     *********************************************************/
    running = FALSE
    scrammed = TRUE
    icon_state = "reactor_slagged"
    cut_overlays()      // We removed add_integrity_overlay() entirely.

    /*********************************************************
     * MELTDOWN EFFECTS
     *********************************************************/
    #ifdef RBMK_MELTDOWN_RADIATION
    meltdown_radiation_pulse()
    #endif

    #ifdef RBMK_MELTDOWN_ATMOS_DUMP
    meltdown_atmos_release()
    #endif

    #ifdef RBMK_MELTDOWN_EXPLOSIONS
    meltdown_explosions()
    #endif

    #ifdef RBMK_MELTDOWN_ALARMS
    meltdown_area_alarms()
    #endif

    // UI + log updates
    update_linked_consoles()
    log_game("[src] MELTDOWN triggered: [reason]")

    // Stop all ticking
    decay_heat = 0
    STOP_PROCESSING(SSmachines, src)



/*************************************************************
 * RADIATION BURST
 *************************************************************/

/// Large, instant reactor radiation pulse
/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
    radiation_pulse(
        loc,
        RBMK_MELTDOWN_RAD_RANGE,
        RBMK_MELTDOWN_RAD_THRESHOLD
    )
    playsound(src, 'sound/effects/supermatter.ogg', 90, TRUE)



/*************************************************************
 * COOLANT RELEASE (ONLY IN MELTDOWN)
 *************************************************************/

/// Releases ~50% coolant as toxic fallout
/obj/machinery/rbmk/reactor/proc/meltdown_atmos_release()
    if (!coolant_internal)
        return

    var/datum/gas_mixture/released = coolant_internal.remove_ratio(0.5)
    if (!released || released.total_moles() <= 0)
        return

    var/turf/T = get_turf(src)
    if (T)
        T.assume_air(released)



/*************************************************************
 * EXPLOSION PACKAGE
 *************************************************************/

/// Large reactor explosion + hotspot creation
/obj/machinery/rbmk/reactor/proc/meltdown_explosions()

    explosion(
        src,
        RBMK_MELTDOWN_DEV_RANGE,
        RBMK_MELTDOWN_HEAVY_RANGE,
        RBMK_MELTDOWN_LIGHT_RANGE,
        RBMK_MELTDOWN_FLASH_RANGE,
        TRUE
    )

    // Aftermath hotspot
    new /obj/effect/hotspot(loc)
    temperature = RBMK_MAX_TEMP * 2



/*************************************************************
 * ALARMS AND AUDIO
 *************************************************************/

/// Plays reactor meltdown alarms for nearby areas
/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
    playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE)
