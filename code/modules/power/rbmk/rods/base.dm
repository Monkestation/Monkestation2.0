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
	var/fuel_consumption = 1

	var/reactivity = 10
	var/flux_multiplier = 1.0
	var/radiation_multiplier = 1.0
	var/thermal_multiplier = 1.0

	var/active = TRUE

	var/depleted_icon_state = "rod_empty"
	var/depleted_description = "An empty fuel rod ready for packing."

	/// Item radiation while outside the reactor.
	/// This only runs after the rod is depleted/spent.
	var/item_radiation_range = 2
	var/item_radiation_threshold = 0.55
	var/item_radiation_chance = 25
	var/item_radiation_intensity = 35
	var/item_radiation_pulse_interval = 3 SECONDS
	var/last_item_radiation_pulse = 0


/obj/item/rbmk/fuel_rod/Initialize(mapload)
	. = ..()

	// Fresh rods should not radiate or process as items.
	// Only already-spent rods need item processing.
	if(is_depleted())
		START_PROCESSING(SSobj, src)


/obj/item/rbmk/fuel_rod/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/rbmk/fuel_rod/process(seconds_per_tick)
	// Safety guard: if this rod somehow starts processing while fresh,
	// immediately stop processing it.
	if(!is_depleted())
		STOP_PROCESSING(SSobj, src)
		return

	emit_item_radiation()


/obj/item/rbmk/fuel_rod/proc/is_depleted()
	return !active || fuel_amount <= 0


/obj/item/rbmk/fuel_rod/proc/is_inside_reactor()
	return istype(loc, /obj/machinery/rbmk/reactor)


/obj/item/rbmk/fuel_rod/proc/emit_item_radiation()
	if(!is_depleted())
		return

	if(is_inside_reactor())
		return

	if(world.time < last_item_radiation_pulse + item_radiation_pulse_interval)
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	last_item_radiation_pulse = world.time

	radiation_pulse(
		src,
		item_radiation_range,
		item_radiation_threshold,
		item_radiation_chance,
		0,
		item_radiation_intensity,
		TRUE
	)


/obj/item/rbmk/fuel_rod/proc/deplete_rod()
	active = FALSE
	fuel_amount = 0
	icon_state = depleted_icon_state
	desc = depleted_description

	// Once spent, the rod becomes a radioactive item when outside the reactor.
	START_PROCESSING(SSobj, src)


/obj/item/rbmk/fuel_rod/proc/get_zero_output()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0
	)


/obj/item/rbmk/fuel_rod/proc/process_rod()
	if(!active)
		return get_zero_output()

	if(fuel_amount <= 0)
		deplete_rod()
		return get_zero_output()

	fuel_amount = max(0, fuel_amount - fuel_consumption)

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
