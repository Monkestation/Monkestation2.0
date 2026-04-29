/obj/item/rbmk/fuel_rod/telecrystal
	name = "Telecrystal Fuel Rod"
	desc = "A crystalline rod that absorbs reactor stress and builds unstable bluespace charge."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "tc_empty"

	depleted_icon_state = "tc_full"
	depleted_description = "A cracked, inert telecrystal rod."

	rod_type = "telecrystal"
	rod_color = "cyan"

	// Effectively non-depleting
	fuel_amount = 1e9
	fuel_consumption = 0

	reactivity = 0
	flux_multiplier = 1.05
	radiation_multiplier = 1.0
	thermal_multiplier = 1.0

	active = TRUE

	var/charge_progress = 0
	var/charge_max = 500
	var/charged = FALSE
	var/usable = TRUE


/obj/item/rbmk/fuel_rod/telecrystal/process_rod(
	var/reactor_temperature = RBMK_AMBIENT_TEMP,
	var/reactor_flux = 0,
	var/core_feedback_factor = 1.0
)
	if(!active || !usable)
		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0
		)

	if(charged)
		return list(
			"heat" = 0,
			"flux" = 0,
			"radiation" = 0
		)

	var/charge_rate = 0

	if(reactor_temperature >= 10000)
		charge_rate = 3
	else if(reactor_temperature >= 5000)
		charge_rate = 2
	else if(reactor_temperature >= 2000)
		charge_rate = 1

	if(charge_rate > 0)
		charge_progress = min(charge_max, charge_progress + charge_rate)

	if(charge_progress >= charge_max && !charged)
		charged = TRUE
		icon_state = "tc_full"

	var/flux_output = (charge_progress / charge_max) * 0.5

	return list(
		"heat" = 0,
		"flux" = flux_output,
		"radiation" = 0
	)
