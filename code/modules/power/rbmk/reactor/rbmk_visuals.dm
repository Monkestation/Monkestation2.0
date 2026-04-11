/*************************************************************
 * RBMK Visual Logic — Canonical V3
 * -----------------------------------------------------------
 * Design rules:
 * - "reactor_off" ONLY when there are NO fuel rods inserted
 * - Otherwise, visuals are driven purely by temperature
 * - SCRAM does NOT directly change visuals
 * - "reactor_meltdown" is a PRE-FAILURE extreme heat state
 * - Post-meltdown slagged state overrides everything
 * - Damage overlays update only when stage changes
 * - This file is the SOLE owner of update_icon()
 * - Sound state follows final sprite state
 *************************************************************/


/*************************************************************
 * Standard icon hook
 *************************************************************/

/// Standard engine icon hook
/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()
	return .


/*************************************************************
 * Sound Update
 *************************************************************/

/// Updates the reactor looping sound based on final sprite state
/obj/machinery/rbmk/reactor/proc/update_reactor_sound()
	if(icon_state == "reactor_off")
		if(soundloop)
			QDEL_NULL(soundloop)
		last_sound_state = icon_state
		return

	if(icon_state == "reactor_slagged")
		if(soundloop)
			QDEL_NULL(soundloop)
		last_sound_state = icon_state
		return

	var/target_volume = 0
	var/target_range = 20

	switch(icon_state)
		if("reactor_on")
			target_volume = 8
			target_range = 12
		if("reactor_hot")
			target_volume = 14
			target_range = 15
		if("reactor_veryhot")
			target_volume = 22
			target_range = 18
		if("reactor_overheat")
			target_volume = 32
			target_range = 22
		if("reactor_meltdown")
			target_volume = 45
			target_range = 26
		else
			target_volume = 10
			target_range = 12

	if(!soundloop || last_sound_state != icon_state)
		if(soundloop)
			QDEL_NULL(soundloop)

		soundloop = new(list(src), FALSE)
		soundloop.mid_sounds = list('monkestation/sound/effects/rbmk/reactor_hum.ogg')
		soundloop.mid_length = 50
		soundloop.volume = target_volume
		soundloop.extra_range = target_range
		soundloop.falloff_distance = 5
		soundloop.falloff_exponent = 8
		soundloop.vary = TRUE
	else
		soundloop.volume = target_volume
		soundloop.extra_range = target_range

	last_sound_state = icon_state


/*************************************************************
 * Main Visual Update
 *************************************************************/

/// Updates the main reactor sprite and damage overlay state
/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	var/previous_damage_stage = current_damage_stage
	var/new_damage_stage = 0

	/************************************************
	 * 1. Slagged state override
	 * True destroyed/post-failure state
	 ************************************************/
	if(meltdown_in_progress || reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		new_damage_stage = 4

		if(new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		update_reactor_sound()
		return

	/************************************************
	 * 2. Base icon selection
	 * OFF only when no rods are physically inserted
	 *
	 * reactor_meltdown is a live extreme-temperature state,
	 * not the actual destroyed state.
	 ************************************************/
	if(!has_fuel_rods())
		icon_state = "reactor_off"
	else if(temperature < RBMK_TEMP_RUNNING)
		icon_state = "reactor_on"
	else if(temperature < RBMK_TEMP_HOT)
		icon_state = "reactor_hot"
	else if(temperature < RBMK_TEMP_VERYHOT)
		icon_state = "reactor_veryhot"
	else if(temperature < RBMK_TEMP_MELTDOWN)
		icon_state = "reactor_overheat"
	else
		icon_state = "reactor_meltdown"

	/************************************************
	 * 3. Damage overlay stage
	 ************************************************/
	var/safe_max_integrity = max(max_reactor_integrity, 1)
	var/integrity_percent = (reactor_integrity / safe_max_integrity) * 100

	if(integrity_percent < RBMK_DAMAGE_OVERLAY_4)
		new_damage_stage = 4
	else if(integrity_percent < RBMK_DAMAGE_OVERLAY_3)
		new_damage_stage = 3
	else if(integrity_percent < RBMK_DAMAGE_OVERLAY_2)
		new_damage_stage = 2
	else if(integrity_percent < RBMK_DAMAGE_OVERLAY_1)
		new_damage_stage = 1
	else
		new_damage_stage = 0

	/************************************************
	 * 4. Overlay refresh only on stage change
	 ************************************************/
	if(new_damage_stage != previous_damage_stage)
		current_damage_stage = new_damage_stage
		refresh_damage_overlay(new_damage_stage)

	update_reactor_sound()


/*************************************************************
 * Overlay Helpers
 *************************************************************/

/// Remove current damage overlay and apply the requested one
/obj/machinery/rbmk/reactor/proc/refresh_damage_overlay(new_stage)
	if(current_damage_overlay_image)
		overlays -= current_damage_overlay_image
		current_damage_overlay_image = null

	if(new_stage <= 0)
		return

	var/damage_icon_state = "reactor_damaged_[new_stage]"
	current_damage_overlay_image = image('icons/obj/machines/rbmk.dmi', damage_icon_state)
	overlays += current_damage_overlay_image
