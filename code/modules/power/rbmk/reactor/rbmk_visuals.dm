/*************************************************************
 * RBMK Visual Logic — Clean, Explicit Variable Revision
 * No single-letter variables, no flicker, no overlay duplication.
 *************************************************************/


/obj/machinery/rbmk/reactor
    /// Tracks the current damage overlay stage (0–4)
    var/current_damage_stage = 0



/*************************************************************
 * Update main reactor icon appearance
 *************************************************************/

/// Updates sprite, overlays, lighting, and visual state
/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
    var/previous_damage_stage = current_damage_stage
    var/new_damage_stage = 0   // clear default


    /*************************************************************
     * 1. SLAGGED STATE OVERRIDE
     *************************************************************/
    if (reactor_integrity <= 0)
        icon_state = "reactor_slagged"
        current_damage_stage = 4
        refresh_damage_overlay(4)
        set_light(0)
        return



    /*************************************************************
     * 2. SELECT BASE ICON (NEVER removed, never flickers)
     *************************************************************/
    if (!running)
        if (temperature <= RBMK_TEMP_OFF)
            icon_state = "reactor_off"
        else
            icon_state = "reactor_idle"
        set_light(0)

    else
        if (temperature < RBMK_TEMP_RUNNING)
            icon_state = "reactor_on"
        else if (temperature < RBMK_TEMP_HOT)
            icon_state = "reactor_hot"
        else if (temperature < RBMK_TEMP_VERYHOT)
            icon_state = "reactor_veryhot"
        else
            icon_state = "reactor_overheat"



    /*************************************************************
     * 3. DETERMINE DAMAGE OVERLAY STAGE (0–4)
     *************************************************************/
    var/integrity_percent = (reactor_integrity / max_reactor_integrity) * 100

    if (integrity_percent < RBMK_DAMAGE_OVERLAY_4)
        new_damage_stage = 4
    else if (integrity_percent < RBMK_DAMAGE_OVERLAY_3)
        new_damage_stage = 3
    else if (integrity_percent < RBMK_DAMAGE_OVERLAY_2)
        new_damage_stage = 2
    else if (integrity_percent < RBMK_DAMAGE_OVERLAY_1)
        new_damage_stage = 1
    else
        new_damage_stage = 0



    /*************************************************************
     * 4. ONLY UPDATE OVERLAYS WHEN STAGE CHANGES
     *************************************************************/
    if (new_damage_stage != previous_damage_stage)
        current_damage_stage = new_damage_stage
        refresh_damage_overlay(new_damage_stage)

    return



/*************************************************************
 * Overlay Helpers
 *************************************************************/

/// Remove old damage overlays and apply the correct new overlay
/obj/machinery/rbmk/reactor/proc/refresh_damage_overlay(new_stage)
    clear_damage_overlays()

    if (new_stage <= 0)
        return

    var/damage_icon_state = "reactor_damaged_[new_stage]"
    var/image/damage_overlay_image = image('icons/obj/machines/rbmk.dmi', damage_icon_state)

    overlays += damage_overlay_image



/// Removes ONLY overlays we added (damage overlays)
/obj/machinery/rbmk/reactor/proc/clear_damage_overlays()

    var/list/current_overlays = overlays.Copy()
    for (var/image/overlay_image in current_overlays)
        var/overlay_state_text = overlay_image.icon_state
        if (findtext(overlay_state_text, "reactor_damaged_"))
            overlays -= overlay_image
