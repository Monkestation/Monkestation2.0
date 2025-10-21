/*************************************************************
 * RBMK Meltdown Logic
 * - Handles meltdown events, effects, and logging
 *************************************************************/

/obj/machinery/rbmk/reactor
    var/meltdown_announced = FALSE


/*************************************************************
 * Trigger Meltdown
 *************************************************************/

/// Called when the reactor exceeds safe thresholds and collapses
/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
    if (!meltdown_announced)
        meltdown_announced = TRUE

        // --- Global announcement ---
        world << span_danger("[RBMK_MELTDOWN_PREFIX]: [reason]!")
        priority_announce("[RBMK_MELTDOWN_BROADCAST] [reason]", "RBMK Reactor Alert")

    // --- Visual change ---
    icon_state = "reactor_slagged"
    set_light(1, 1, RBMK_MELTDOWN_LIGHT_COLOR)
    cut_overlays()
    add_integrity_overlay()

    /*************************************************************
     * Meltdown Effects
     *************************************************************/

    // These are compile-time toggles from rbmk_defines.dm
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

    // --- Final sync & logging ---
    update_linked_consoles()
    log_game("[src] has entered meltdown due to: [reason]")


/*************************************************************
 * Radiation Pulse
 *************************************************************/

/// Emits a large burst of radiation around the reactor
/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
    radiation_pulse(loc, RBMK_MELTDOWN_RAD_RANGE, RBMK_MELTDOWN_RAD_THRESHOLD)


/*************************************************************
 * Atmos Release
 *************************************************************/

/// Releases stored coolant gases into the atmosphere
/obj/machinery/rbmk/reactor/proc/meltdown_atmos_release()
    if(!coolant_internal)
        return

    var/datum/gas_mixture/release = coolant_internal.remove_ratio(0.5)
    if(release && release.total_moles() > 0)
        var/turf/T = get_turf(src)
        if(T)
            T.assume_air(release)


/*************************************************************
 * Explosions
 *************************************************************/

/// Triggers chain explosions based on meltdown severity
/obj/machinery/rbmk/reactor/proc/meltdown_explosions()
    explosion(
        origin = src,
        devastation_range = RBMK_MELTDOWN_DEV_RANGE,
        heavy_impact_range = RBMK_MELTDOWN_HEAVY_RANGE,
        light_impact_range = RBMK_MELTDOWN_LIGHT_RANGE,
        flash_range = RBMK_MELTDOWN_FLASH_RANGE,
        adminlog = TRUE
    )


/*************************************************************
 * Alarms & Audio Feedback
 *************************************************************/

/// Plays alert sirens after meltdown
/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
    playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE)
