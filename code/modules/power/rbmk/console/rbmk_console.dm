/obj/machinery/computer/rbmk_console
	name = "RBMK Reactor Console"
	desc = "A console used to monitor and control an RBMK nuclear reactor."
	icon = 'icons/obj/reactor_controller.dmi'
	base_icon_state = "reactorcontrol"
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
	var/list/linked_turbines = list()

	var/turbine_scan_range = 20

	var/gas_composition_update_delay = 2 SECONDS
	var/last_gas_composition_update = 0
	var/list/cached_gas_composition = list()


/obj/machinery/computer/rbmk_console/Initialize(mapload)
	. = ..()
	auto_link()
	update_appearance(UPDATE_ICON)

	return .


/obj/machinery/computer/rbmk_console/Destroy()
	linked_reactor = null
	linked_turbines = null
	cached_gas_composition = null
	return ..()


/obj/machinery/computer/rbmk_console/proc/auto_link()
	linked_reactor = null

	var/shortest_distance_found = 999
	for(var/obj/machinery/rbmk/reactor/reactor in range(7, src))
		var/current_distance = get_dist(src, reactor)
		if(current_distance < shortest_distance_found)
			shortest_distance_found = current_distance
			linked_reactor = reactor

	rescan_turbines()
	update_appearance(UPDATE_ICON)


/obj/machinery/computer/rbmk_console/proc/rescan_turbines()
	linked_turbines = list()

	if(!linked_reactor)
		return

	for(var/obj/machinery/power/rbmk_turbine/turbine in range(turbine_scan_range, linked_reactor))
		if(QDELETED(turbine))
			continue

		linked_turbines += turbine


/obj/machinery/computer/rbmk_console/update_icon_state()
	. = ..()

	var/obj/machinery/rbmk/reactor/reactor = linked_reactor
	if(!reactor)
		icon_state = "[base_icon_state]-1"
		return

	if(reactor.meltdown_in_progress || reactor.reactor_integrity <= 0)
		icon_state = "[base_icon_state]-3"
		return

	var/integrity_value = reactor.reactor_integrity
	var/max_integrity_value = max(reactor.max_reactor_integrity, 1)

	if(integrity_value >= max_integrity_value * 0.7)
		icon_state = "[base_icon_state]-1"
	else if(integrity_value >= max_integrity_value * 0.4)
		icon_state = "[base_icon_state]-2"
	else
		icon_state = "[base_icon_state]-3"


/obj/machinery/computer/rbmk_console/update_overlays()
	SHOULD_CALL_PARENT(FALSE)

	return list()


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
			"percent" = RBMK_ROUND2(gas_percent)
		)

	return gas_data


/obj/machinery/computer/rbmk_console/proc/get_cached_gas_composition_data(datum/gas_mixture/gas_mix)
	if(world.time < last_gas_composition_update + gas_composition_update_delay)
		return cached_gas_composition

	last_gas_composition_update = world.time
	cached_gas_composition = rbmk_build_gas_composition_data(gas_mix)
	return cached_gas_composition


/obj/machinery/computer/rbmk_console/proc/get_turbine_data()
	var/list/turbine_data = list()
	var/list/valid_turbines = list()

	var/total_turbine_power = 0
	var/total_turbine_integrity = 0

	var/turbine_count = 0
	var/generating_turbine_count = 0
	var/stale_turbine_count = 0

	if(!linked_reactor)
		return list(
			"turbines" = turbine_data,
			"total_turbine_power" = 0,
			"average_turbine_integrity" = 0,
			"turbine_count" = 0,
			"generating_turbine_count" = 0,
			"stale_turbine_count" = 0
		)

	for(var/obj/machinery/power/rbmk_turbine/turbine as anything in linked_turbines)
		if(!turbine || QDELETED(turbine))
			continue

		valid_turbines += turbine
		turbine_count++

		var/integrity_percent = turbine.get_generator_integrity_percent()
		var/turbine_generating = turbine.is_actively_generating()
		var/turbine_stale = turbine.is_telemetry_stale()
		var/current_power_output = turbine_generating ? RBMK_ROUND2(turbine.last_power_output) : 0

		if(turbine_generating)
			generating_turbine_count++
			total_turbine_power += current_power_output

		if(turbine_stale)
			stale_turbine_count++

		total_turbine_integrity += integrity_percent

		turbine_data += list(list(
			"ref" = REF(turbine),
			"name" = turbine.name,
			"index" = turbine_count,
			"running" = turbine.running,
			"generating" = turbine_generating,
			"broken" = (turbine.machine_stat & BROKEN) ? TRUE : FALSE,
			"telemetry_stale" = turbine_stale,
			"telemetry_age" = turbine.get_telemetry_age_seconds(),
			"integrity" = RBMK_ROUND2(integrity_percent),
			"power_output" = current_power_output,
			"rpm" = turbine_generating ? RBMK_ROUND2(turbine.rpm) : 0,
			"flow_moles" = turbine_generating ? RBMK_ROUND2(turbine.last_flow_moles) : 0,
			"flow_moles_per_second" = turbine_generating ? RBMK_ROUND2(turbine.last_flow_moles / RBMK_ATMOS_PROCESS_SECONDS) : 0,
			"inlet_temperature" = RBMK_ROUND2(turbine.last_inlet_temperature),
			"outlet_temperature" = RBMK_ROUND2(turbine.last_outlet_temperature),
			"pressure_delta" = RBMK_ROUND2(turbine.last_pressure_delta)
		))

	linked_turbines = valid_turbines

	var/average_turbine_integrity = 0
	if(turbine_count > 0)
		average_turbine_integrity = total_turbine_integrity / turbine_count

	return list(
		"turbines" = turbine_data,
		"total_turbine_power" = RBMK_ROUND2(total_turbine_power),
		"average_turbine_integrity" = RBMK_ROUND2(average_turbine_integrity),
		"turbine_count" = turbine_count,
		"generating_turbine_count" = generating_turbine_count,
		"stale_turbine_count" = stale_turbine_count
	)


/obj/machinery/computer/rbmk_console/ui_data(mob/user)
	var/list/data = list()
	var/obj/machinery/rbmk/reactor/reactor = linked_reactor

	var/list/turbine_summary = get_turbine_data()
	data["turbines"] = turbine_summary["turbines"]
	data["total_turbine_power"] = turbine_summary["total_turbine_power"]
	data["average_turbine_integrity"] = turbine_summary["average_turbine_integrity"]
	data["turbine_count"] = turbine_summary["turbine_count"]
	data["generating_turbine_count"] = turbine_summary["generating_turbine_count"]
	data["stale_turbine_count"] = turbine_summary["stale_turbine_count"]

	if(!reactor)
		data["status"] = "No reactor linked"
		return data

	data["status"] = reactor.meltdown_in_progress ? "Meltdown in progress" : "Online"
	data["running"] = reactor.running
	data["scrammed"] = reactor.scrammed
	data["az5_expended"] = reactor.az5_expended

	data["supermatter_cascade_active"] = reactor.supermatter_cascade_active
	data["supermatter_cascade_status"] = null
	data["supermatter_cascade_time_left"] = 0
	data["supermatter_cascade_time_total"] = 0
	data["supermatter_cascade_final_countdown"] = FALSE

	if(reactor.supermatter_rod?.cascade_controller)
		var/datum/supermatter_rod_cascade/cascade = reactor.supermatter_rod.cascade_controller
		data["supermatter_cascade_final_countdown"] = cascade.final_countdown_active

		if(cascade.final_countdown_active)
			data["supermatter_cascade_status"] = "TERMINAL COUNTDOWN"
			data["supermatter_cascade_time_left"] = max(cascade.final_countdown_duration - (world.time - cascade.final_countdown_started_at), 0)
			data["supermatter_cascade_time_total"] = cascade.final_countdown_duration
		else
			data["supermatter_cascade_status"] = "CONTROL LOCKOUT"
			data["supermatter_cascade_time_left"] = max(cascade.duration - (world.time - cascade.started_at), 0)
			data["supermatter_cascade_time_total"] = cascade.duration

	data["control_rods"] = RBMK_ROUND2(reactor.actual_control_rod_depth)
	data["control_rods_target"] = RBMK_ROUND2(reactor.control_rod_depth)
	data["max_control_rod"] = RBMK_CONTROL_ROD_MAX

	data["temperature"] = RBMK_ROUND2(reactor.temperature)
	data["max_temp"] = RBMK_TEMP_DISPLAY_MAX
	data["temp_running"] = RBMK_TEMP_RUNNING
	data["temp_moderate"] = RBMK_TEMP_MODERATE
	data["temp_hot"] = RBMK_TEMP_HOT
	data["temp_max_safe"] = RBMK_TEMP_MAXSAFE
	data["temp_meltdown"] = RBMK_TEMP_MELTDOWN

	data["radiation"] = RBMK_ROUND2(reactor.radiation)
	data["max_radiation"] = RBMK_MAX_RADIATION
	// Approximate equivalent dose for operator display (gamma-weighted: 1 R ~= 0.01 Sv).
	data["radiation_sieverts"] = RBMK_ROUND2(reactor.radiation * 0.01)
	data["max_radiation_sieverts"] = RBMK_ROUND2(RBMK_MAX_RADIATION * 0.01)

	data["flux"] = RBMK_ROUND2(reactor.flux)
	data["max_flux"] = max(100, RBMK_MAX_FLUX, round((reactor.flux * 1.25) + 50, 50))
	data["base_flux"] = RBMK_ROUND2(reactor.last_tick_base_flux)
	data["void_flux_bonus"] = RBMK_ROUND2(reactor.last_tick_void_flux_bonus)

	data["void_coefficient"] = RBMK_ROUND2(reactor.void_coefficient)
	data["max_void_coefficient"] = RBMK_VC_MAX
	data["void_flux_multiplier"] = RBMK_ROUND2(reactor.last_void_flux_multiplier)
	data["void_temperature_component"] = RBMK_ROUND2(reactor.void_coefficient_temperature)
	data["void_pressure_component"] = RBMK_ROUND2(reactor.void_coefficient_pressure)
	data["void_coolant_component"] = RBMK_ROUND2(reactor.void_coefficient_coolant)
	data["flux_warning"] = RBMK_FLUX_ANOMALY_THRESHOLD
	data["flux_high"] = RBMK_FLUX_ANOMALY_HIGH
	data["flux_extreme"] = RBMK_FLUX_ANOMALY_EXTREME
	data["rod_temperature_limit_bonus"] = RBMK_ROUND2(reactor.rod_temperature_limit_bonus)
	data["coolant_exchange_multiplier"] = RBMK_ROUND2(1 + reactor.rod_coolant_exchange_bonus)
	data["flux_modifier_multiplier"] = RBMK_ROUND2(1 + reactor.rod_flux_multiplier_bonus)

	data["integrity"] = RBMK_ROUND2(reactor.reactor_integrity)
	data["max_integrity"] = reactor.max_reactor_integrity
	data["last_integrity_damage"] = RBMK_ROUND2(reactor.last_integrity_damage)

	data["pressure_current"] = RBMK_ROUND2(reactor.pressure)
	data["pressure_warning"] = RBMK_PRESSURE_WARNING
	data["pressure_critical"] = RBMK_PRESSURE_CRITICAL
	data["pressure_extreme"] = RBMK_PRESSURE_EXTREME

	data["inlet_open"] = reactor.inlet_open
	data["outlet_open"] = reactor.outlet_open

	data["inlet_rate"] = reactor.inlet_rate
	data["inlet_min"] = RBMK_INLET_RATE_MIN
	data["inlet_max"] = RBMK_INLET_RATE_MAX

	data["outlet_target_pressure"] = RBMK_ROUND2(reactor.outlet_target_pressure)
	data["outlet_pressure_max"] = RBMK_OUTLET_PRESSURE_MAX

	var/datum/gas_mixture/inlet_mix = reactor.get_inlet_mix()
	var/datum/gas_mixture/outlet_mix = reactor.get_outlet_mix()
	var/datum/gas_mixture/coolant_mix = reactor.get_coolant_mix()

	data["inlet_pressure"] = inlet_mix ? RBMK_ROUND2(inlet_mix.return_pressure()) : 0
	data["outlet_pressure"] = outlet_mix ? RBMK_ROUND2(outlet_mix.return_pressure()) : 0
	data["inlet_flow"] = RBMK_ROUND2(reactor.last_inlet_flow_rate)
	data["outlet_flow"] = RBMK_ROUND2(reactor.last_outlet_flow_rate)
	data["inlet_last_pressure"] = RBMK_ROUND2(reactor.last_inlet_pressure)
	data["outlet_core_pressure"] = RBMK_ROUND2(reactor.last_outlet_pressure)
	data["coolant_moles"] = coolant_mix ? RBMK_ROUND2(coolant_mix.total_moles()) : 0
	data["coolant_temperature"] = coolant_mix ? RBMK_ROUND2(coolant_mix.temperature) : 0
	data["coolant_exchange_ratio"] = RBMK_ROUND2(reactor.last_coolant_exchange_ratio * 100)
	data["coolant_core_temp_change"] = RBMK_ROUND2(reactor.last_coolant_core_temp_change)
	data["coolant_temperature_change"] = RBMK_ROUND2(reactor.last_coolant_temperature_change)

	var/list/pressure_history = list()
	for(var/pressure_value in reactor.coolant_pressure_history)
		pressure_history += RBMK_ROUND2(pressure_value)
	data["pressure"] = pressure_history

	var/list/reactor_temperature_history = list()
	for(var/temperature_value in reactor.reactor_temperature_history)
		reactor_temperature_history += RBMK_ROUND2(temperature_value)
	data["reactor_temperature_history"] = reactor_temperature_history

	data["gas_composition"] = get_cached_gas_composition_data(reactor.coolant_internal)

	data["max_normal_slots"] = reactor.max_normal_slots
	data["max_special_slots"] = reactor.max_special_slots

	var/list/rods_list = list()

	for(var/normal_slot_index = 1 to reactor.max_normal_slots)
		var/obj/item/rbmk/fuel_rod/normal_rod = null
		if(normal_slot_index <= length(reactor.normal_slots))
			normal_rod = reactor.normal_slots[normal_slot_index]

		rods_list += list(list(
			"type" = normal_rod ? normal_rod.name : "Empty",
			"color" = normal_rod ? normal_rod.rod_color : "grey",
			"active" = normal_rod?.active,
			"fuel_amount" = normal_rod ? RBMK_ROUND2(normal_rod.fuel_amount) : 0,
			"depleted" = normal_rod && !normal_rod.active,
			"slot_kind" = "normal",
			"slot_index" = normal_slot_index
		))

	for(var/special_slot_index = 1 to reactor.max_special_slots)
		var/obj/item/rbmk/fuel_rod/special_rod = null
		if(special_slot_index <= length(reactor.special_slots))
			special_rod = reactor.special_slots[special_slot_index]

		rods_list += list(list(
			"type" = special_rod ? special_rod.name : "Empty",
			"color" = special_rod ? special_rod.rod_color : "grey",
			"active" = special_rod?.active,
			"fuel_amount" = special_rod ? RBMK_ROUND2(special_rod.fuel_amount) : 0,
			"depleted" = special_rod && !special_rod.active,
			"slot_kind" = "special",
			"slot_index" = special_slot_index
		))

	data["rods"] = rods_list
	return data


/obj/machinery/computer/rbmk_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	var/obj/machinery/rbmk/reactor/reactor = linked_reactor

	if(!reactor)
		if(action == "rescan")
			auto_link()
			return TRUE
		return FALSE

	if(reactor.supermatter_cascade_active)
		if(action == "rescan")
			auto_link()
			return TRUE
		return TRUE

	switch(action)
		if("rescan")
			auto_link()
			return TRUE

		if("rod_up")
			var/old_depth = reactor.control_rod_depth
			reactor.control_rod_depth = max(reactor.control_rod_depth - 5, 0)

			if(reactor.control_rod_depth != old_depth)
				playsound(reactor, 'sound/rbmk/switch.ogg', 50, TRUE)

			reactor.update_linked_consoles()
			return TRUE

		if("rod_down")
			var/old_depth = reactor.control_rod_depth
			reactor.control_rod_depth = min(reactor.control_rod_depth + 5, RBMK_CONTROL_ROD_MAX)

			if(reactor.control_rod_depth != old_depth)
				playsound(reactor, 'sound/rbmk/switch.ogg', 50, TRUE)

			reactor.update_linked_consoles()
			return TRUE

		if("set_rods")
			var/requested_depth = text2num(params["depth"])
			var/old_depth = reactor.control_rod_depth
			reactor.control_rod_depth = clamp(requested_depth, 0, RBMK_CONTROL_ROD_MAX)

			if(reactor.control_rod_depth != old_depth)
				playsound(reactor, 'sound/rbmk/switch.ogg', 50, TRUE)

			reactor.update_linked_consoles()
			return TRUE

		if("scram")
			return reactor.force_scram(ui.user)

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

			return reactor.remove_rod_by_slot(slot_kind, slot_index, ui.user)

	return FALSE
