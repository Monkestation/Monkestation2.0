/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()


/obj/machinery/rbmk/reactor/proc/step_volume_toward(current_value, target_value, step = 2)
	if(current_value < target_value)
		return min(current_value + step, target_value)
	if(current_value > target_value)
		return max(current_value - step, target_value)
	return current_value


/obj/machinery/rbmk/reactor/proc/update_reactor_sound()
	var/low_target_volume = 0
	var/high_target_volume = 0
	var/low_target_range = 6
	var/high_target_range = 8

	if(icon_state == "reactor_off" || icon_state == "reactor_slagged")
		if(low_soundloop)
			low_soundloop.stop()
			QDEL_NULL(low_soundloop)
		if(high_soundloop)
			high_soundloop.stop()
			QDEL_NULL(high_soundloop)
		return

	switch(icon_state)
		if("reactor_on")
			low_target_volume = 8
			high_target_volume = 0
			low_target_range = 6
			high_target_range = 8

		if("reactor_moderate")
			low_target_volume = 10
			high_target_volume = 2
			low_target_range = 7
			high_target_range = 9

		if("reactor_hot")
			low_target_volume = 12
			high_target_volume = 4
			low_target_range = 8
			high_target_range = 10

		if("reactor_veryhot")
			low_target_volume = 10
			high_target_volume = 12
			low_target_range = 9
			high_target_range = 11

		if("reactor_maxsafe")
			low_target_volume = 8
			high_target_volume = 18
			low_target_range = 9
			high_target_range = 12

		if("reactor_overheat")
			low_target_volume = 6
			high_target_volume = 22
			low_target_range = 10
			high_target_range = 13

		if("reactor_meltdown")
			low_target_volume = 0
			high_target_volume = 32
			low_target_range = 10
			high_target_range = 15

		if("reactor_cascade")
			low_target_volume = 4
			high_target_volume = 36
			low_target_range = 12
			high_target_range = 16

	if(low_target_volume > 0)
		if(!low_soundloop)
			low_soundloop = new /datum/looping_sound/rbmk_reactor_low(src, TRUE)
			low_soundloop.volume = 0

		low_soundloop.volume = step_volume_toward(low_soundloop.volume, low_target_volume, 2)
		low_soundloop.extra_range = low_target_range
		low_soundloop.falloff_distance = 2
		low_soundloop.falloff_exponent = 6
	else if(low_soundloop)
		low_soundloop.stop()
		QDEL_NULL(low_soundloop)

	if(high_target_volume > 0)
		if(!high_soundloop)
			high_soundloop = new /datum/looping_sound/rbmk_reactor_high(src, TRUE)
			high_soundloop.volume = 0

		high_soundloop.volume = step_volume_toward(high_soundloop.volume, high_target_volume, 2)
		high_soundloop.extra_range = high_target_range
		high_soundloop.falloff_distance = 2
		high_soundloop.falloff_exponent = 7
	else if(high_soundloop)
		high_soundloop.stop()
		QDEL_NULL(high_soundloop)


/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	var/previous_damage_stage = current_damage_stage
	var/new_damage_stage = 0

	if(meltdown_in_progress || reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		new_damage_stage = 4

		if(new_damage_stage != previous_damage_stage)
			current_damage_stage = new_damage_stage
			refresh_damage_overlay(new_damage_stage)

		update_reactor_sound()
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
		return

	if(!has_fuel_rods())
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


/obj/machinery/rbmk/reactor/proc/refresh_damage_overlay(new_stage)
	if(current_damage_overlay_image)
		overlays -= current_damage_overlay_image
		current_damage_overlay_image = null

	if(new_stage <= 0)
		return

	var/damage_icon_state = "reactor_damaged_[new_stage]"
	current_damage_overlay_image = image('icons/obj/machines/rbmk.dmi', damage_icon_state)
	overlays += current_damage_overlay_image
