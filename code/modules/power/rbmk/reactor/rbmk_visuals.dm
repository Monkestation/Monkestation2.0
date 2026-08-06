/** Refreshes reactor appearance, sound, and emitted light together. */
/obj/machinery/rbmk/reactor/update_appearance(updates = ALL)
	. = ..()
	update_reactor_sound()
	update_reactor_backlight()

/** Describes the breached vessel after a completed meltdown. */
/obj/machinery/rbmk/reactor/update_desc(updates = ALL)
	if(meltdown_exploded)
		desc = "The ruptured, slagged remains of an RBMK reactor core. Its containment lid has been torn away."
	else
		desc = initial(desc)
	return ..()

/** Selects the reactor icon state from its fuel, heat, and failure state. */
/obj/machinery/rbmk/reactor/update_icon_state()
	. = ..()
	current_damage_stage = get_reactor_damage_stage()
	if(meltdown_exploded || (!meltdown_in_progress && reactor_integrity <= 0))
		icon_state = "reactor_slagged"
		return
	if(meltdown_in_progress)
		icon_state = "reactor_meltdown"
		return
	if(supermatter_rod)
		icon_state = "reactor_cascade"
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

/** Adds the integrity-damage overlay through the appearance pipeline. */
/obj/machinery/rbmk/reactor/update_overlays()
	. = ..()
	if(current_damage_stage <= 0)
		return
	. += mutable_appearance(icon, "reactor_damaged_[current_damage_stage]")

/** Returns the damage-overlay stage for the current vessel integrity. */
/obj/machinery/rbmk/reactor/proc/get_reactor_damage_stage()
	if(meltdown_exploded || meltdown_in_progress || reactor_integrity <= 0)
		return 4
	var/integrity_percent = (reactor_integrity / max(max_reactor_integrity, 1)) * 100
	if(integrity_percent < RBMK_DAMAGE_OVERLAY_4)
		return 4
	if(integrity_percent < RBMK_DAMAGE_OVERLAY_3)
		return 3
	if(integrity_percent < RBMK_DAMAGE_OVERLAY_2)
		return 2
	if(integrity_percent < RBMK_DAMAGE_OVERLAY_1)
		return 1
	return 0

/** Keeps reactor ambience synchronized with its operating state. */
/obj/machinery/rbmk/reactor/proc/update_reactor_sound()
	if(supermatter_rod)
		stop_reactor_sound()
		return
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

/** Updates emitted light to communicate the current reactor hazard. */
/obj/machinery/rbmk/reactor/proc/update_reactor_backlight()
	if(meltdown_exploded || icon_state == "reactor_slagged")
		set_light(l_outer_range = 8, l_power = 2.8, l_color = LIGHT_COLOR_FIRE)
		return
	if(meltdown_in_progress || icon_state == "reactor_meltdown")
		set_light(l_outer_range = 7, l_power = 2.4, l_color = COLOR_RED_LIGHT)
		return
	if(supermatter_rod || icon_state == "reactor_cascade")
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
