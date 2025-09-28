// rbmk_meltdown.dm
// Handles meltdown state and visual effects

/obj/machinery/rbmk/reactor
    var/meltdown_announced = FALSE

/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
    if (!meltdown_announced)
        meltdown_announced = TRUE
        // Send the warning only once
        world << span_danger("⚠ RBMK MELTDOWN: [reason]!")

    // Update appearance: slagged base + overlay
    icon_state = "reactor_slagged"
    set_light(1, 1, "#663300")
    cut_overlays()
    add_integrity_overlay()

    // Placeholder for future effects:
    // - radiation pulse
    // - atmos dump (superheated gas release)
    // - structural explosions
    // - area-wide alarms
