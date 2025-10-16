// rbmk_visuals.dm
// Handles RBMK reactor icon states and integrity overlays only.

/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
    // Clear overlays each tick
    cut_overlays()

    // --- Destroyed/slagged ---
    if (reactor_integrity <= 0)
        icon_state = "reactor_slagged"
        add_integrity_overlay()
        return

    // --- Add integrity overlays ---
    add_integrity_overlay()

    // --- Temperature-based icon states (pure sprite control) ---
    if (!running && temperature <= RBMK_TEMP_OFF)
        icon_state = "reactor_off"
        return

    if (!running && temperature > RBMK_TEMP_OFF)
        icon_state = "reactor_on"
        return

    if (temperature < RBMK_TEMP_RUNNING)
        icon_state = "reactor_on"
    else if (temperature < RBMK_TEMP_HOT)
        icon_state = "reactor_hot"
    else if (temperature < RBMK_TEMP_VERYHOT)
        icon_state = "reactor_veryhot"
    else if (temperature < RBMK_TEMP_OVERHEAT)
        icon_state = "reactor_overheat"
    else
        icon_state = "reactor_meltdown"

/obj/machinery/rbmk/reactor/proc/add_integrity_overlay()
    var/integrity_pct = (reactor_integrity / max_reactor_integrity) * 100

    if (integrity_pct < RBMK_DAMAGE_OVERLAY_4)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_4")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_3)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_3")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_2)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_2")
    else if (integrity_pct < RBMK_DAMAGE_OVERLAY_1)
        overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_1")
