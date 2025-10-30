/*************************************************************
 * RBMK Visual Logic
 * - Handles reactor icon states and integrity overlays.
 * - Uses icon_state transitions for visual feedback instead of lighting.
 *************************************************************/

/*************************************************************
 * Main Visual Update
 *************************************************************/

/// Updates reactor sprite state based on temperature, integrity, and run status
/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	var/previous_state = icon_state
	var/previous_overlay_count = overlays.len

	// --- Destroyed / Slagged State ---
	if (reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		clear_and_add_integrity_overlay()
		set_light(0)
		return

	// --- Integrity Overlay ---
	clear_and_add_integrity_overlay()

	// --- Temperature-driven state changes ---
	if (!running)
		if (temperature <= RBMK_TEMP_OFF)
			icon_state = "reactor_off"
		else
			icon_state = "reactor_idle"
		set_light(0)
		return

	// --- Active running states ---
	if (temperature < RBMK_TEMP_RUNNING)
		icon_state = "reactor_on"
	else if (temperature < RBMK_TEMP_HOT)
		icon_state = "reactor_hot"
	else if (temperature < RBMK_TEMP_VERYHOT)
		icon_state = "reactor_veryhot"
	else if (temperature < RBMK_TEMP_OVERHEAT)
		icon_state = "reactor_overheat"


	// --- Only redraw overlays if something changed ---
	if (icon_state != previous_state || overlays.len != previous_overlay_count)
		update_reactor_overlays()


/*************************************************************
 * Integrity Overlay Management
 *************************************************************/

/// Clears overlays and adds the correct damage overlay
/obj/machinery/rbmk/reactor/proc/clear_and_add_integrity_overlay()
	cut_overlays()
	add_integrity_overlay()

/// Adds appropriate overlay based on reactor integrity percentage
/obj/machinery/rbmk/reactor/proc/add_integrity_overlay()
	if (max_reactor_integrity <= 0)
		return

	var/integrity_percent = (reactor_integrity / max_reactor_integrity) * 100

	if (integrity_percent < RBMK_DAMAGE_OVERLAY_4)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_4")
	else if (integrity_percent < RBMK_DAMAGE_OVERLAY_3)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_3")
	else if (integrity_percent < RBMK_DAMAGE_OVERLAY_2)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_2")
	else if (integrity_percent < RBMK_DAMAGE_OVERLAY_1)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_1")


/*************************************************************
 * Overlay Refresh
 *************************************************************/

/// Ensures overlays stay synced without recursion or flicker
/obj/machinery/rbmk/reactor/proc/update_reactor_overlays()
	// Prevent recursion by not calling update_reactor_icon() here again
	cut_overlays()
	add_integrity_overlay()
