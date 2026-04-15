/obj/machinery/computer/rbmk_console
	name = "RBMK Reactor Console"
	desc = "A console used to monitor and control an RBMK nuclear reactor."
	icon = 'icons/obj/reactor_controller.dmi'
	icon_state = "reactorcontrol-1"
	density = TRUE
	anchored = TRUE

	bound_width = 96
	bound_height = 32
	bound_x = -32
	pixel_x = -32
	pixel_y = 0

	mouse_opacity = MOUSE_OPACITY_ICON
	layer = OBJ_LAYER
	plane = GAME_PLANE

	var/obj/machinery/rbmk/reactor/linked_reactor = null


/obj/machinery/computer/rbmk_console/Initialize(mapload)
	. = ..()
	auto_link()
	update_icon()


/obj/machinery/computer/rbmk_console/Destroy()
	linked_reactor = null
	return ..()


/obj/machinery/computer/rbmk_console/proc/auto_link()
	linked_reactor = null

	var/shortest_distance_found = 999
	for(var/obj/machinery/rbmk/reactor/reactor in range(7, src))
		var/current_distance = get_dist(src, reactor)
		if(current_distance < shortest_distance_found)
			shortest_distance_found = current_distance
			linked_reactor = reactor

	update_icon()


/obj/machinery/computer/rbmk_console/update_icon()
	. = ..()

	var/obj/machinery/rbmk/reactor/reactor = linked_reactor
	if(!reactor)
		icon_state = "reactorcontrol-1"
		return

	if(reactor.meltdown_in_progress || reactor.reactor_integrity <= 0)
		icon_state = "reactorcontrol-3"
		return

	var/integrity_value = reactor.reactor_integrity
	var/max_integrity_value = max(reactor.max_reactor_integrity, 1)

	if(integrity_value >= max_integrity_value * 0.7)
		icon_state = "reactorcontrol-1"
	else if(integrity_value >= max_integrity_value * 0.4)
		icon_state = "reactorcontrol-2"
	else
		icon_state = "reactorcontrol-3"


/obj/machinery/computer/rbmk_console/ui_state(mob/user)
	return GLOB.physical_state


/obj/machinery/computer/rbmk_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return .

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RBMKConsole", name)
		ui.open()

	return ui


/obj/machinery/computer/rbmk_console/proc/rbmk_round2(number_value)
	return round(number_value, 0.01)


/obj/machinery/computer/rbmk_console/proc/rbmk_build_gas_composition_data(datum/gas_mixture/gas_mix)
	var/list/gas_data = list()

	if(!gas_mix)
		return gas_data

	var/total_moles = gas_mix.total_moles()
	if(total_moles <= 0)
		return gas_data

	for(var/gas_path in gas_mix.gases)
		var/list/gas_entry = gas_mix.gases[gas_path]
		var/gas_percent = 0

		if(gas_entry && gas_entry[MOLES] > 0)
			gas_percent = (gas_entry[MOLES] / total_moles) * 100

		gas_data[gas_path] = list(
			"percent" = rbmk_round2(gas_percent)
		)

	return gas_data


/obj/machinery/computer/rbmk_console/ui_data(mob/user)
	var/list/data = list()
	var/obj/machinery/rbmk/reactor/reactor = linked_reactor

	if(!reactor)
		data["status"] = "No reactor linked"
		return data

	data["status"] = reactor.meltdown_in_progress ? "Meltdown in progress" : "Online"
	data["running"] = reactor.running
	data["scrammed"] = reactor.scrammed

	// Show the actual rod position so the UI reflects delayed rod movement.
	data["control_rods"] = rbmk_round2(reactor.actual_control_rod_depth)
	data["max_control_rod"] = RBMK_CONTROL_ROD_MAX

	data["temperature"] = rbmk_round2(reactor.temperature)
	data["max_temp"] = RBMK_MAX_TEMP

	data["radiation"] = rbmk_round2(reactor.radiation)
	data["max_radiation"] = RBMK_MAX_RADIATION

	data["flux"] = rbmk_round2(reactor.flux)
	data["max_flux"] = RBMK_MAX_FLUX

	data["void_coefficient"] = rbmk_round2(reactor.void_coefficient)

	data["integrity"] = rbmk_round2(reactor.reactor_integrity)
	data["max_integrity"] = reactor.max_reactor_integrity

	data["pressure_current"] = rbmk_round2(reactor.pressure)
	data["pressure_warning"] = RBMK_PRESSURE_WARNING
	data["pressure_critical"] = RBMK_PRESSURE_CRITICAL
	data["pressure_extreme"] = RBMK_PRESSURE_EXTREME

	data["inlet_open"] = reactor.inlet_open
	data["outlet_open"] = reactor.outlet_open

	data["inlet_rate"] = reactor.inlet_rate
	data["inlet_min"] = RBMK_INLET_RATE_MIN
	data["inlet_max"] = RBMK_INLET_RATE_MAX

	data["outlet_target_pressure"] = rbmk_round2(reactor.outlet_target_pressure)
	data["outlet_pressure_max"] = RBMK_OUTLET_PRESSURE_MAX

	var/datum/gas_mixture/inlet_mix = reactor.get_inlet_mix()
	var/datum/gas_mixture/outlet_mix = reactor.get_outlet_mix()

	data["inlet_pressure"] = inlet_mix ? rbmk_round2(inlet_mix.return_pressure()) : 0
	data["outlet_pressure"] = outlet_mix ? rbmk_round2(outlet_mix.return_pressure()) : 0

	var/list/pressure_history = list()
	for(var/pressure_value in reactor.coolant_pressure_history)
		pressure_history += rbmk_round2(pressure_value)
	data["pressure"] = pressure_history

	var/list/reactor_temperature_history = list()
	for(var/temperature_value in reactor.reactor_temperature_history)
		reactor_temperature_history += rbmk_round2(temperature_value)
	data["reactor_temperature_history"] = reactor_temperature_history

	data["gas_composition"] = rbmk_build_gas_composition_data(reactor.coolant_internal)

	data["max_normal_slots"] = reactor.max_normal_slots
	data["max_special_slots"] = reactor.max_special_slots

	var/list/rods_list = list()

	for(var/normal_slot_index = 1, normal_slot_index <= reactor.max_normal_slots, normal_slot_index++)
		var/obj/item/rbmk/fuel_rod/normal_rod = null
		if(normal_slot_index <= length(reactor.normal_slots))
			normal_rod = reactor.normal_slots[normal_slot_index]

		rods_list += list(list(
			"type" = normal_rod ? normal_rod.name : "Empty",
			"color" = normal_rod ? normal_rod.rod_color : "grey",
			"depleted" = normal_rod && !normal_rod.active,
			"slot_kind" = "normal",
			"slot_index" = normal_slot_index
		))

	for(var/special_slot_index = 1, special_slot_index <= reactor.max_special_slots, special_slot_index++)
		var/obj/item/rbmk/fuel_rod/special_rod = null
		if(special_slot_index <= length(reactor.special_slots))
			special_rod = reactor.special_slots[special_slot_index]

		rods_list += list(list(
			"type" = special_rod ? special_rod.name : "Empty",
			"color" = special_rod ? special_rod.rod_color : "grey",
			"depleted" = special_rod && !special_rod.active,
			"slot_kind" = "special",
			"slot_index" = special_slot_index
		))

	data["rods"] = rods_list
	return data


/obj/machinery/computer/rbmk_console/ui_act(action, params)
	. = ..()
	if(.)
		return .

	var/obj/machinery/rbmk/reactor/reactor = linked_reactor

	if(!reactor)
		if(action == "rescan")
			auto_link()
			return TRUE
		return FALSE

	switch(action)
		if("rescan")
			auto_link()
			return TRUE

		if("rod_up")
			reactor.control_rod_depth = max(reactor.control_rod_depth - 5, 0)
			reactor.update_linked_consoles()
			return TRUE

		if("rod_down")
			reactor.control_rod_depth = min(reactor.control_rod_depth + 5, RBMK_CONTROL_ROD_MAX)
			reactor.update_linked_consoles()
			return TRUE

		if("set_rods")
			var/requested_depth = text2num(params["depth"])
			reactor.control_rod_depth = clamp(requested_depth, 0, RBMK_CONTROL_ROD_MAX)
			reactor.update_linked_consoles()
			return TRUE

		if("scram")
			reactor.force_scram()
			return TRUE

		if("toggle_inlet")
			reactor.inlet_open = !reactor.inlet_open
			reactor.wake_coolant_ports()
			reactor.update_linked_consoles()
			return TRUE

		if("set_inlet_rate")
			var/requested_rate = text2num(params["rate"])
			reactor.inlet_rate = clamp(requested_rate, RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
			reactor.wake_coolant_ports()
			reactor.update_linked_consoles()
			return TRUE

		if("toggle_outlet")
			reactor.outlet_open = !reactor.outlet_open
			reactor.wake_coolant_ports()
			reactor.update_linked_consoles()
			return TRUE

		if("set_outlet_pressure")
			var/requested_pressure = text2num(params["pressure"])
			reactor.outlet_target_pressure = clamp(requested_pressure, 0, RBMK_OUTLET_PRESSURE_MAX)
			reactor.wake_coolant_ports()
			reactor.update_linked_consoles()
			return TRUE

		if("remove_rod")
			var/slot_kind = params["kind"]
			var/slot_index = text2num(params["index"])

			if(!istext(slot_kind))
				return FALSE

			return reactor.remove_rod_by_slot(slot_kind, slot_index, usr)

	return FALSE
