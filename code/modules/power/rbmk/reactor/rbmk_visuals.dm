/*************************************************************
 * RBMK Visual Logic
 * - Handles reactor icon states, integrity overlays, and lighting
 *************************************************************/

/*************************************************************
 * Main Visual Update
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
    // --- Prevent overlay spam ---
    var/old_state = icon_state
    var/old_overlays = overlays.len

    // --- Destroyed / Slagged State ---
    if (reactor_integrity <= 0)
        icon_state = "reactor_slagged"
        clear_and_add_integrity_overlay()
        set_light(0)
        return

    // --- Normal Damage Overlay ---
    clear_and_add_integrity_overlay()

    // --- Temperature → Sprite ---
    if (!running && temperature <= RBMK_TEMP_OFF)
        icon_state = "reactor_off"
        set_light(0)
        return

    if (!running && temperature > RBMK_TEMP_OFF)
        icon_state = "reactor_on"
        set_light(RBMK_LIGHT_RUNNING_RADIUS, RBMK_LIGHT_RUNNING_POWER, RBMK_LIGHT_RUNNING_COLOR)
        return

    if (temperature < RBMK_TEMP_RUNNING)
        icon_state = "reactor_on"
        set_light(RBMK_LIGHT_RUNNING_RADIUS, RBMK_LIGHT_RUNNING_POWER, RBMK_LIGHT_RUNNING_COLOR)
    else if (temperature < RBMK_TEMP_HOT)
        icon_state = "reactor_hot"
        set_light(RBMK_LIGHT_HOT_RADIUS, RBMK_LIGHT_HOT_POWER, RBMK_LIGHT_HOT_COLOR)
    else if (temperature < RBMK_TEMP_VERYHOT)
        icon_state = "reactor_veryhot"
        set_light(RBMK_LIGHT_VERYHOT_RADIUS, RBMK_LIGHT_VERYHOT_POWER, RBMK_LIGHT_VERYHOT_COLOR)
    else if (temperature < RBMK_TEMP_OVERHEAT)
        icon_state = "reactor_overheat"
        set_light(RBMK_LIGHT_OVERHEAT_RADIUS, RBMK_LIGHT_OVERHEAT_POWER, RBMK_LIGHT_OVERHEAT_COLOR)
    else
        icon_state = "reactor_meltdown"
        set_light(RBMK_LIGHT_MELTDOWN_RADIUS, RBMK_LIGHT_MELTDOWN_POWER, RBMK_LIGHT_MELTDOWN_COLOR)

    // --- Optimization: Only redraw overlays if state changed ---
    if (icon_state != old_state || overlays.len != old_overlays)
        update_reactor_overlays()


/*************************************************************
 * Integrity Overlay Management
 *************************************************************/

/// Clear overlays and add the correct integrity damage layer
/obj/machinery/rbmk/reactor/proc/clear_and_add_integrity_overlay()
    cut_overlays()
    add_integrity_overlay()

/// Adds integrity overlays depending on current reactor health
/obj/machinery/rbmk/reactor/proc/add_integrity_overlay()
    if (max_reactor_integrity <= 0)
        return

    var/integrity_pct = (reactor_integrity / max_reactor_integrity) * 100

    if (integrity_pct < RBMK_DAMAGE_OVERLAY_4)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_4")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_3)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_3")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_2)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_2")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_1)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_1")


/*************************************************************
 * Overlay Refresh (renamed to avoid engine conflict)
 *************************************************************/

/// Ensures overlays stay synced without flickering
/obj/machinery/rbmk/reactor/proc/update_reactor_overlays()
    // ✅ We DO NOT override /atom/update_overlays(), avoids duplicate definition
    update_reactor_icon()
