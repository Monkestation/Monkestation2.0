// rbmk_meltdown.dm
// Handles meltdown state and visual effects

/obj/machinery/rbmk/reactor
    var/meltdown_announced = FALSE

/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
    if (!meltdown_announced)
        meltdown_announced = TRUE

        // Global announcement
        world << span_danger("[RBMK_MELTDOWN_PREFIX]: [reason]!")

        // TODO: Tie into station announcement system?
        priority_announce("[RBMK_MELTDOWN_BROADCAST] [reason]", "RBMK Reactor Alert")

    // --- Visuals ---
    icon_state = "reactor_slagged"
    set_light(1, 1, RBMK_MELTDOWN_LIGHT_COLOR)
    cut_overlays()
    add_integrity_overlay()

    // --- Core meltdown effects ---
    // --- Core meltdown effects ---
    meltdown_radiation_pulse()
    meltdown_atmos_release()
    meltdown_explosions()
    meltdown_area_alarms()


/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
    // TODO: Tune range & intensity
    radiation_pulse(
        source = loc,
        max_range = RBMK_MELTDOWN_RAD_RANGE,
        threshold = RBMK_MELTDOWN_RAD_THRESHOLD
    )

/obj/machinery/rbmk/reactor/proc/meltdown_atmos_release()
    if(!coolant_internal)
        return

    // Release half the internal coolant mix into the turf
    var/datum/gas_mixture/release = coolant_internal.remove_ratio(0.5)
    if(release && release.total_moles() > 0)
        var/turf/T = get_turf(src)
        if(T)
            T.assume_air(release)

/obj/machinery/rbmk/reactor/proc/meltdown_explosions()
    explosion(
        origin = src,
        devastation_range = RBMK_MELTDOWN_DEV_RANGE,
        heavy_impact_range = RBMK_MELTDOWN_HEAVY_RANGE,
        light_impact_range = RBMK_MELTDOWN_LIGHT_RANGE,
        flash_range = RBMK_MELTDOWN_FLASH_RANGE,
        adminlog = TRUE
    )

/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
    playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE)
