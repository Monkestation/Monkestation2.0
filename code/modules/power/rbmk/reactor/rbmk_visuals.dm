/obj/machinery/rbmk/reactor/update_icon()
	. = ..()
	update_reactor_icon()


/obj/machinery/rbmk/reactor/proc/stop_reactor_sounds()
	if(low_soundloop)
		low_soundloop.stop()
		QDEL_NULL(low_soundloop)

	if(high_soundloop)
		high_soundloop.stop()
		QDEL_NULL(high_soundloop)

	if(max_soundloop)
		max_soundloop.stop()
		QDEL_NULL(max_soundloop)


/obj/machinery/rbmk/reactor/proc/update_reactor_sound()
	var/wants_low_sound = FALSE
	var/wants_high_sound = FALSE
	var/wants_max_sound = FALSE

	if(icon_state == "reactor_off" || icon_state == "reactor_slagged")
		stop_reactor_sounds()
		return

	wants_low_sound = TRUE

	if(temperature >= RBMK_TEMP_HOT || icon_state == "reactor_cascade")
		wants_high_sound = TRUE

	if(temperature >= RBMK_TEMP_MAXSAFE || icon_state == "reactor_overheat" || icon_state == "reactor_meltdown" || icon_state == "reactor_cascade")
		wants_max_sound = TRUE

	if(wants_low_sound)
		if(!low_soundloop)
			low_soundloop = new /datum/looping_sound/rbmk_reactor_low(src, TRUE)
	else if(low_soundloop)
		low_soundloop.stop()
		QDEL_NULL(low_soundloop)

	if(wants_high_sound)
		if(!high_soundloop)
			high_soundloop = new /datum/looping_sound/rbmk_reactor_high(src, TRUE)
	else if(high_soundloop)
		high_soundloop.stop()
		QDEL_NULL(high_soundloop)

	if(wants_max_sound)
		if(!max_soundloop)
			max_soundloop = new /datum/looping_sound/rbmk_reactor_max(src, TRUE)
	else if(max_soundloop)
		max_soundloop.stop()
		QDEL_NULL(max_soundloop)


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
