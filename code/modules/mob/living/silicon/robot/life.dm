/mob/living/silicon/robot/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	. = ..()
	handle_robot_hud_updates()
	handle_robot_cell(seconds_per_tick, times_fired)

/// Handles all additional cyborg-specific hud updates.
/mob/living/silicon/robot/proc/handle_robot_hud_updates()
	if(!client)
		return
	update_cell_hud_icon()

/// Deals with the alert associated with the cyborg's cell and its percentage of remaining power.
/mob/living/silicon/robot/proc/update_cell_hud_icon()
	if(!cell)
		throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/nocell)
		return
	switch(ROUND_UP(cell.percent()))
		if(75 to INFINITY)
			clear_alert(ALERT_CHARGE)
		if(50 to 75)
			throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 1)
		if(25 to 50)
			throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 2)
		if(1 to 25)
			throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/lowcell, 3)
		else
			throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/emptycell)

/mob/living/silicon/robot/update_health_hud()
	if(!client || !hud_used?.healths)
		return
	if(stat != DEAD)
		if(health >= maxHealth)
			hud_used.healths.icon_state = "health0"
			return
		if(health > maxHealth * 0.6)
			hud_used.healths.icon_state = "health2"
			return
		if(health > maxHealth * 0.2)
			hud_used.healths.icon_state = "health3"
			return
		if(health > -maxHealth * 0.2)
			hud_used.healths.icon_state = "health4"
			return
		if(health > -maxHealth * 0.6)
			hud_used.healths.icon_state = "health5"
			return
		hud_used.healths.icon_state = "health6"
		return
	hud_used.healths.icon_state = "health7"

/// Performs power upkeep for the cyborg.
/mob/living/silicon/robot/proc/handle_robot_cell(seconds_per_tick, times_fired)
	if(stat == DEAD)
		return
	// It is unexpected (but possible) that cyborgs that change their low power status here.
	// This is caused by someone directly setting the cyborg's cell or their cell's charge value. Since we can't stacktrace how it happened, we leave it be.
	if(!cell?.charge)
		if(!low_power_mode)
			set_low_power_mode(TRUE)
		return
	if(low_power_mode)
		set_low_power_mode(FALSE)
		return
	if(stat == CONSCIOUS)
		if(cell.charge <= 0.01 * STANDARD_CELL_CHARGE && drop_all_held_items()) // An obvious warning for busy cyborgs to go charge.
			to_chat(src, span_warning("Automatic power conservation engaged! Deactivating active modules...")) // It doesn't really conserve power, but you get the gist.
		var/energy_consumption = max(lamp_power_consumption * lamp_enabled * lamp_intensity * seconds_per_tick, BORG_MINIMUM_POWER_CONSUMPTION * seconds_per_tick) // Lamp will use a max of 5 * [BORG_LAMP_POWER_CONSUMPTION], depending on brightness of lamp. If lamp is off, borg systems consume [BORG_MINIMUM_POWER_CONSUMPTION], or the rest of the cell if it's lower than that.
		cell.use(energy_consumption, TRUE)
