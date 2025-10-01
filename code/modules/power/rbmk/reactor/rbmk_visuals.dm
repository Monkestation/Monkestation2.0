// rbmk_visuals.dm
// Handles RBMK reactor icon states, lights, and visual feedback

/obj/machinery/rbmk/reactor/proc/update_reactor_icon()
	// Clear overlays every tick
	cut_overlays()

	// --- Destroyed/slagged ---
	if (reactor_integrity <= 0)
		icon_state = "reactor_slagged"
		set_light(0)
		// Always add final integrity overlay
		add_integrity_overlay()
		return

	// --- Normal integrity overlays ---
	add_integrity_overlay()

	// --- Normal off / idle cooling ---
	if (!running && temperature <= RBMK_TEMP_OFF)
		icon_state = "reactor_off"
		set_light(0)
		return

	if (!running && temperature > RBMK_TEMP_OFF)
		icon_state = "reactor_on" // glows faintly while cooling
		set_light(1, 1, "#4444ff")
		return

	// --- Running: heat stages ---
	if (temperature < RBMK_TEMP_RUNNING)
		icon_state = "reactor_on"
		set_light(RBMK_LIGHT_RUNNING_RADIUS, RBMK_LIGHT_RUNNING_POWER, RBMK_LIGHT_RUNNING_COLOR)
	else if (temperature < RBMK_TEMP_HOT)
		icon_state = "reactor_hot"
		set_light(RBMK_LIGHT_HOT_RADIUS, RBMK_LIGHT_HOT_POWER, RBMK_LIGHT_HOT_COLOR)
	else if (temperature < RBMK_TEMP_VERYHOT)
		icon_state = "reactor_veryhot"
		set_light(RBMK_LIGHT_VERYHOT_RADIUS, RBMK_LIGHT_VERYHOT_POWER, RBMK_LIGHT_VERYHOT_COLOR)
	else if (temperature < RBMK_TEMP_OVERHEAT)
		icon_state = "reactor_overheat"
		set_light(RBMK_LIGHT_OVERHEAT_RADIUS, RBMK_LIGHT_OVERHEAT_POWER, RBMK_LIGHT_OVERHEAT_COLOR)
	else
		icon_state = "reactor_meltdown"
		set_light(RBMK_LIGHT_MELTDOWN_RADIUS, RBMK_LIGHT_MELTDOWN_POWER, RBMK_LIGHT_MELTDOWN_COLOR)

	// --- Instability overlay / warning ---
	if (instability > RBMK_INSTABILITY_WARNING && instability <= RBMK_INSTABILITY_CRITICAL)
		animate(src, color = list(1,0.9,0.9, 0,0,0), time = 5, loop = -1)
	else if (instability > RBMK_INSTABILITY_CRITICAL)
		animate(src, color = list(1,0.6,0.6, 0,0,0), time = 2, loop = -1)
	else
		animate(src, color = null, time = 5) // reset if stable


/obj/machinery/rbmk/reactor/proc/add_integrity_overlay()
	var/integrity_pct = (reactor_integrity / max_reactor_integrity) * 100
	if (integrity_pct < RBMK_DAMAGE_OVERLAY_4)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_4")
	else if (integrity_pct < RBMK_DAMAGE_OVERLAY_3)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_3")
	else if (integrity_pct < RBMK_DAMAGE_OVERLAY_2)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_2")
	else if (integrity_pct < RBMK_DAMAGE_OVERLAY_1)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_1")

