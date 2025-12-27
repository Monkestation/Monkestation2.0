/*************************************************************
 * RBMK Visual Logic — Temperature-driven, Fuel-gated
 * -----------------------------------------------------------
 * Design rules (per Dillon):
 * - "reactor_off" ONLY when there are NO fuel rods inserted
 * - Otherwise, visuals are driven purely by temperature
 * - SCRAM does NOT directly change visuals (it drops reactivity -> temp falls)
 * - No flicker, no overlay duplication
 * - No iterating overlays list (avoids runtimes)
 * - Properly hooks into update_icon()
 *************************************************************/

/obj/machinery/rbmk/reactor
	/// Tracks the current damage overlay stage (0–4)
	var/current_damage_stage = 0

	/// Reference to the damage overlay image currently applied (or null)
	var/image/current_damage_overlay_image = null

/*************************************************************
 * Standard icon hook
 * Many subsystems call update_icon() automatically.
 *************************************************************/

/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()
	return .


/*************************************************************
 * Update main reactor icon appearance
 *************************************************************/

/// Updates sprite + damage overlays (base icon never removed)
/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	var/previous_damage_stage = current_damage_stage
	var/new_damage_stage = 0

	/*************************************************************
	 * 1) SLAGGED STATE OVERRIDE (post-boom wreck)
	 *************************************************************/
	if (reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		new_damage_stage = 4

		if (new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		return

	/*************************************************************
	 * 2) BASE ICON SELECTION
	 * - OFF only if no fuel rods inserted
	 * - Otherwise temperature-driven
	 *************************************************************/
	if (!has_fuel_rods())
		icon_state = "reactor_off"
	else
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

	/*************************************************************
	 * 3) DAMAGE OVERLAY STAGE (0–4)
	 *************************************************************/
	var/safe_max_integrity = max(max_reactor_integrity, 1)
	var/integrity_percent = (reactor_integrity / safe_max_integrity) * 100

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
	 * 4) ONLY UPDATE OVERLAY WHEN STAGE CHANGES
	 *************************************************************/
	if (new_damage_stage != previous_damage_stage)
		current_damage_stage = new_damage_stage
		refresh_damage_overlay(new_damage_stage)

	return


/*************************************************************
 * Overlay Helpers
 *************************************************************/

/// Remove current damage overlay and apply the correct new overlay stage
/obj/machinery/rbmk/reactor/proc/refresh_damage_overlay(new_stage)
	// Remove prior overlay (if any)
	if (current_damage_overlay_image)
		overlays -= current_damage_overlay_image
		current_damage_overlay_image = null

	// Stage 0 means no damage overlay
	if (new_stage <= 0)
		return

	var/damage_icon_state = "reactor_damaged_[new_stage]"
	current_damage_overlay_image = image('icons/obj/machines/rbmk.dmi', damage_icon_state)
	overlays += current_damage_overlay_image
