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
	if (!running && temperature <= 293)
		icon_state = "reactor_off"
		set_light(0)
		return

	if (!running && temperature > 293)
		icon_state = "reactor_on" // glows faintly while cooling
		set_light(1, 1, "#4444ff")
		return

	// --- Running: heat stages ---
	if (temperature < 500)
		icon_state = "reactor_on"
		set_light(1, 1, "#33f")
	else if (temperature < 1500)
		icon_state = "reactor_hot"
		set_light(2, 2, "#06f")
	else if (temperature < 2500)
		icon_state = "reactor_veryhot"
		set_light(2, 2.5, "#f60")
	else if (temperature < max_temp)
		icon_state = "reactor_overheat"
		set_light(3, 3, "#f00")
	else
		icon_state = "reactor_meltdown"
		set_light(4, 4, "#ff0")

	// --- Instability overlay / warning ---
	if (instability > 100 && instability <= 200)
		animate(src, color = list(1,0.9,0.9, 0,0,0), time = 5, loop = -1)
	else if (instability > 200)
		animate(src, color = list(1,0.6,0.6, 0,0,0), time = 2, loop = -1)


/obj/machinery/rbmk/reactor/proc/add_integrity_overlay()
	var/integrity_pct = (reactor_integrity / max_reactor_integrity) * 100
	if (integrity_pct < 25)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_4")
	else if (integrity_pct < 50)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_3")
	else if (integrity_pct < 75)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_2")
	else if (integrity_pct < 90)
		overlays += image('icons/obj/machines/rbmk.dmi', "reactor_damaged_1")
