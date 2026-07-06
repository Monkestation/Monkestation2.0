/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()


/obj/machinery/rbmk/reactor/proc/stop_reactor_sounds()
	stop_reactor_sound()


/obj/machinery/rbmk/reactor/proc/update_reactor_sound()
	if(icon_state == "reactor_off" || icon_state == "reactor_slagged")
		stop_reactor_sound()
		return

	if(temperature >= RBMK_TEMP_MAXSAFE || icon_state == "reactor_overheat" || icon_state == "reactor_meltdown" || icon_state == "reactor_cascade")
		set_reactor_sound_state(RBMK_SOUND_MAX)
		return

	if(temperature >= RBMK_TEMP_HOT)
		set_reactor_sound_state(RBMK_SOUND_HIGH)
		return

	set_reactor_sound_state(RBMK_SOUND_LOW)


/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	var/previous_damage_stage = current_damage_stage
	var/new_damage_stage = 0

	if(meltdown_exploded || (!meltdown_in_progress && reactor_integrity <= 0))
		icon_state = "reactor_slagged"
		new_damage_stage = 4

		if(new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		update_reactor_sound()
		update_reactor_backlight()
		return

	if(meltdown_in_progress)
		icon_state = "reactor_meltdown"
		new_damage_stage = 4

		if(new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		update_reactor_sound()
		update_reactor_backlight()
		return

	if(supermatter_cascade_active)
		icon_state = "reactor_cascade"

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

		if(new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		update_reactor_sound()
		update_reactor_backlight()
		return

	if(!has_fuel_rods() || (!has_active_fuel_rods() && temperature < RBMK_TEMP_RUNNING))
		icon_state = "reactor_off"
	else if(temperature < RBMK_TEMP_RUNNING)
		icon_state = "reactor_on"
	else if(temperature < RBMK_TEMP_MODERATE)
		icon_state = "reactor_moderate"
	else if(temperature < RBMK_TEMP_HOT)
		icon_state = "reactor_hot"
	else if(temperature < RBMK_TEMP_VERYHOT)
		icon_state = "reactor_veryhot"
	else if(temperature < RBMK_TEMP_MAXSAFE)
		icon_state = "reactor_maxsafe"
	else if(temperature < RBMK_TEMP_MELTDOWN)
		icon_state = "reactor_overheat"
	else
		icon_state = "reactor_meltdown"

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

	if(new_damage_stage != previous_damage_stage)
		current_damage_stage = new_damage_stage
		refresh_damage_overlay(new_damage_stage)

	update_reactor_sound()
	update_reactor_backlight()


/obj/machinery/rbmk/reactor/proc/update_reactor_backlight()
	if(meltdown_exploded || icon_state == "reactor_slagged")
		set_light(l_outer_range = 8, l_power = 2.8, l_color = LIGHT_COLOR_FIRE)
		return

	if(meltdown_in_progress || icon_state == "reactor_meltdown")
		set_light(l_outer_range = 7, l_power = 2.4, l_color = COLOR_RED_LIGHT)
		return

	if(supermatter_cascade_active || icon_state == "reactor_cascade")
		set_light(l_outer_range = 7, l_power = 2.2, l_color = COLOR_VIVID_YELLOW)
		return

	if(temperature >= RBMK_TEMP_MAXSAFE)
		set_light(l_outer_range = 6, l_power = 1.8, l_color = LIGHT_COLOR_FIRE)
		return

	if(temperature >= RBMK_TEMP_HOT)
		set_light(l_outer_range = 4, l_power = 1.2, l_color = LIGHT_COLOR_ORANGE)
		return

	if(icon_state != "reactor_off")
		set_light(l_outer_range = 3, l_power = 0.7, l_color = LIGHT_COLOR_GREEN)
		return

	set_light(0)


/obj/machinery/rbmk/reactor/proc/refresh_damage_overlay(new_stage)
	if(current_damage_overlay_image)
		overlays -= current_damage_overlay_image
		current_damage_overlay_image = null

	if(new_stage <= 0)
		return

	var/damage_icon_state = "reactor_damaged_[new_stage]"
	current_damage_overlay_image = image('icons/obj/machines/rbmk_reactor.dmi', damage_icon_state)
	overlays += current_damage_overlay_image
