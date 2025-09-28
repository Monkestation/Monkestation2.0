/obj/item/rbmk/fuel_rod/telecrystal
	name = "Telecrystal Rod"
	desc = "Charges inside the reactor and can be cracked open for unstable rewards."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "tc_empty"

	fuel_amount = 0           // doesn’t burn fuel
	heat_per_tick = 0
	rad_output = 0
	flux_output = 0

	var/charge_progress = 0
	var/charge_max = 720      // ~12 minutes at 1 tick/second
	var/charged = FALSE
	var/usable = TRUE

	rod_type = "telecrystal"
	rod_color = "crimson"

/// Telecrystal rod processing
/obj/item/rbmk/fuel_rod/telecrystal/process_rod()
	// Already charged or unusable → inert
	if (!usable || charged)
		return list(
			"flux"        = 0,
			"heat"        = 0,
			"radiation"   = 0,
			"thermal_mult" = 1,
			"flux_mult"    = 1
		)

	// Check if inside a reactor
	var/obj/machinery/rbmk/reactor/core = null
	if (istype(loc, /obj/machinery/rbmk/reactor))
		core = loc

	// Charge if reactor is hot enough
	if (core && core.thermal_output >= 2000)
		var/charge_rate = 1
		if (core.thermal_output >= 10000)
			charge_rate = 3
		else if (core.thermal_output >= 5000)
			charge_rate = 2

		charge_progress += charge_rate

		// Fully charged
		if (charge_progress >= charge_max)
			charged = TRUE
			icon_state = "tc_full"
			to_chat(core, span_warning("[src] hums violently as it finishes charging with bluespace energy!"))

	// While charging, no impact on reactor
	return list(
		"flux"        = 0,
		"heat"        = 0,
		"radiation"   = 0,
		"thermal_mult" = 1,
		"flux_mult"    = 1
	)
