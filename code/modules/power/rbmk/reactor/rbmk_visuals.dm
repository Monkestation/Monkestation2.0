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
	var/old_state = icon_state
	var/old_overlay_count = overlays.len

	// ---------------------------------------------------------
	// 1. HANDLE SLAGGED CORE
	// ---------------------------------------------------------
	if (reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		cut_overlays()
		add_integrity_overlay()
		set_light(0)
		return

	// ---------------------------------------------------------
	// 2. DETERMINE BASE ICON FIRST (before overlays)
	// ---------------------------------------------------------
	if (!running)
		// SCRAMMED / OFF―BASE SPRITES
		if (temperature <= RBMK_TEMP_OFF)
			icon_state = "reactor_off"
		else
			icon_state = "reactor_idle"

		set_light(0)

	else
		// RUNNING STATES
		if (temperature < RBMK_TEMP_RUNNING)
			icon_state = "reactor_on"
		else if (temperature < RBMK_TEMP_HOT)
			icon_state = "reactor_hot"
		else if (temperature < RBMK_TEMP_VERYHOT)
			icon_state = "reactor_veryhot"
		else if (temperature < RBMK_TEMP_OVERHEAT)
			icon_state = "reactor_overheat"
		else
			icon_state = "reactor_overheat" // failsafe

	// ---------------------------------------------------------
	// 3. NOW APPLY DAMAGE OVERLAYS
	// ---------------------------------------------------------
	cut_overlays()
	add_integrity_overlay()

	// If something changed, refresh overlays
	if (icon_state != old_state || overlays.len != old_overlay_count)
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
	cut_overlays()
	add_integrity_overlay()
