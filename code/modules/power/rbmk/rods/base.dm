/obj/item/rbmk/fuel_rod
	name = "Fuel Rod"
	desc = "A generic fuel rod designed for RBMK reactors."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	layer = OBJ_LAYER + 0.02
	plane = GAME_PLANE

	var/rod_type = "empty"
	var/rod_color = "grey"

	var/fuel_amount = 100
	/// Fuel consumed per second while the rod is active in a reactor.
	var/fuel_consumption = 0.5

	var/reactivity = 10
	var/flux_multiplier = 1.0
	var/radiation_multiplier = 1.0
	var/thermal_multiplier = 1.0

	var/active = TRUE
	/// Whether this rod can sustain reactor operation by producing direct output.
	var/contributes_to_reaction = TRUE
	var/activated_in_reactor = FALSE
	var/irradiated = FALSE

	var/depleted_icon_state = "rod_empty"
	var/depleted_description = "An empty fuel rod ready for packing."

	var/item_radiation_range = 2
	var/item_radiation_threshold = 0.55
	var/item_radiation_chance = 25
	var/item_radiation_intensity = 35
	var/item_radiation_intensity_activated = 15
	var/item_radiation_pulse_interval = 3 SECONDS
	var/last_item_radiation_pulse = 0


/obj/item/rbmk/fuel_rod/Initialize(mapload)
	. = ..()

	if(should_process_item_radiation())
		START_PROCESSING(SSobj, src)


/obj/item/rbmk/fuel_rod/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/rbmk/fuel_rod/process(seconds_per_tick)
	if(!should_process_item_radiation())
		STOP_PROCESSING(SSobj, src)
		return

	emit_item_radiation()


/obj/item/rbmk/fuel_rod/proc/is_depleted()
	return !active || fuel_amount <= 0


/obj/item/rbmk/fuel_rod/proc/is_inside_reactor()
	return istype(loc, /obj/machinery/rbmk/reactor)


/obj/item/rbmk/fuel_rod/proc/is_radioactive_item()
	return irradiated || is_depleted()


/obj/item/rbmk/fuel_rod/proc/should_process_item_radiation()
	if(!is_radioactive_item())
		return FALSE

	return TRUE


/obj/item/rbmk/fuel_rod/proc/activate_in_reactor()
	if(activated_in_reactor && irradiated)
		return

	activated_in_reactor = TRUE
	irradiated = TRUE


	START_PROCESSING(SSobj, src)


/obj/item/rbmk/fuel_rod/proc/emit_item_radiation()
	if(!is_radioactive_item())
		return

	if(is_inside_reactor())
		return

	if(world.time < last_item_radiation_pulse + item_radiation_pulse_interval)
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	last_item_radiation_pulse = world.time

	var/current_intensity = is_depleted() ? item_radiation_intensity : item_radiation_intensity_activated

	radiation_pulse(
		src,
		item_radiation_range,
		item_radiation_threshold,
		item_radiation_chance,
		0,
		current_intensity,
		TRUE
	)


/obj/item/rbmk/fuel_rod/proc/deplete_rod()
	active = FALSE
	fuel_amount = 0
	activated_in_reactor = TRUE
	irradiated = TRUE
	icon_state = depleted_icon_state
	desc = depleted_description

	START_PROCESSING(SSobj, src)


/obj/item/rbmk/fuel_rod/proc/get_zero_output()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0,
	)


/obj/item/rbmk/fuel_rod/proc/get_modifier_output()
	return list(
		"temperature_limit_bonus" = 0,
		"coolant_exchange_bonus" = 0,
		"flux_multiplier_bonus" = 0,
	)


/obj/item/rbmk/fuel_rod/proc/get_residual_radiation_output()
	if(!active || fuel_amount <= 0)
		return 0

	return reactivity * radiation_multiplier


/obj/item/rbmk/fuel_rod/proc/process_rod(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(!active)
		return get_zero_output()

	if(fuel_amount <= 0)
		deplete_rod()
		return get_zero_output()

	activate_in_reactor()

	fuel_amount = max(0, fuel_amount - (fuel_consumption * seconds_per_tick))

	// Let the last unit of fuel still produce output this tick,
	// then mark the rod spent afterward.
	var/should_deplete_after_output = (fuel_amount <= 0)

	var/rod_flux_output = reactivity * flux_multiplier
	var/rod_radiation_output = reactivity * radiation_multiplier
	var/rod_heat_output = reactivity * thermal_multiplier

	if(should_deplete_after_output)
		deplete_rod()

	return list(
		"flux" = rod_flux_output,
		"radiation" = rod_radiation_output,
		"heat" = rod_heat_output
	)
