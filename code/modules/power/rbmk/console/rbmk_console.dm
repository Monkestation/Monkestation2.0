/*************************************************************
 * RBMK Reactor Console — Canonical V1
 * -----------------------------------------------------------
 * Responsibilities of this file:
 * - nearest-reactor linking
 * - TGUI data export
 * - operator actions
 * - console visual state
 *
 * Design rule:
 * - UI should never be the source of truth for reactor physics.
 * - The reactor process loop decides whether the reactor is
 *   actually running.
 *************************************************************/


/*************************************************************
 * Console Definition
 *************************************************************/

/// RBMK control console
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


/*************************************************************
 * Initialization / Cleanup
 *************************************************************/

/// Startup
/obj/machinery/computer/rbmk_console/Initialize(mapload)
	. = ..()
	auto_link()
	update_icon()

/// Cleanup
/obj/machinery/computer/rbmk_console/Destroy()
	linked_reactor = null
	return ..()


/*************************************************************
 * Reactor Linking & Console Visual State
 *************************************************************/

/// Automatically link to nearest RBMK reactor
/obj/machinery/computer/rbmk_console/proc/auto_link()
	linked_reactor = null

	var/shortest_distance_found = 999
	for (var/obj/machinery/rbmk/reactor/reactor in range(7, src))
		var/current_distance = get_dist(src, reactor)
		if (current_distance < shortest_distance_found)
			shortest_distance_found = current_distance
			linked_reactor = reactor

	update_icon()

/// Update console icon appearance based on linked reactor condition
/obj/machinery/computer/rbmk_console/update_icon()
	. = ..()

	if (!linked_reactor)
		icon_state = "reactorcontrol-1"
		return

	if (linked_reactor.meltdown_in_progress || linked_reactor.reactor_integrity <= 0)
		icon_state = "reactorcontrol-3"
		return

	var/integrity_value = linked_reactor.reactor_integrity
	var/max_integrity_value = max(linked_reactor.max_reactor_integrity, 1)

	if (integrity_value >= max_integrity_value * 0.7)
		icon_state = "reactorcontrol-1"
	else if (integrity_value >= max_integrity_value * 0.4)
		icon_state = "reactorcontrol-2"
	else
		icon_state = "reactorcontrol-3"


/*************************************************************
 * UI / TGUI Framework
 *************************************************************/

/// Physical-only UI state
/obj/machinery/computer/rbmk_console/ui_state(mob/user)
	return GLOB.physical_state

/// Open TGUI
/obj/machinery/computer/rbmk_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if (.)
		return .

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RBMKConsole", name)
		ui.open()

	return ui


/*************************************************************
 * Helper Utilities
 *************************************************************/

/// Round to 0.01 precision
/proc/rbmk_round2(number_value)
	return round(number_value, 0.01)

/// Export gas composition percentages from coolant mix
/proc/rbmk_build_gas_composition_data(datum/gas_mixture/gas_mix)
	var/list/gas_data = list()

	if (!gas_mix)
		return gas_data

	var/total_moles = gas_mix.total_moles()
	if (total_moles <= 0)
		return gas_data

	for (var/gas_path in gas_mix.gases)
		var/list/gas_entry = gas_mix.gases[gas_path]
		var/gas_percent = 0

		if (gas_entry && gas_entry[MOLES] > 0)
			gas_percent = (gas_entry[MOLES] / total_moles) * 100

		gas_data[gas_path] = list(
			"percent" = rbmk_round2(gas_percent)
		)

	return gas_data

/// Export historical gas percentages for graphs
/proc/rbmk_build_gas_history_data(obj/machinery/rbmk/reactor/reactor)
	var/list/gas_history_data = list()

	if (!reactor || !reactor.coolant_gas_hist)
		return gas_history_data

	for (var/gas_path in reactor.coolant_gas_hist)
		var/list/history_values = reactor.coolant_gas_hist[gas_path]
		var/list/rounded_values = list()

		for (var/history_value in history_values)
			rounded_values += rbmk_round2(history_value)

		gas_history_data[gas_path] = rounded_values

	return gas_history_data


/*************************************************************
 * UI DATA EXPORT (Telemetry)
 *************************************************************/

/// Export reactor telemetry to TGUI
/obj/machinery/computer/rbmk_console/ui_data(mob/user)
	var/list/data = list()

	if (!linked_reactor)
		data["status"] = "No reactor linked"
		return data

	/************************************************
	 * Core State
	 ************************************************/
	data["status"] = linked_reactor.meltdown_in_progress ? "Meltdown in progress" : "Online"
	data["running"] = linked_reactor.running
	data["scrammed"] = linked_reactor.scrammed

	data["control_rods"] = rbmk_round2(linked_reactor.control_rod_depth)
	data["max_control_rod"] = RBMK_CONTROL_ROD_MAX

	data["temperature"] = rbmk_round2(linked_reactor.temperature)
	data["max_temp"] = RBMK_MAX_TEMP

	data["radiation"] = rbmk_round2(linked_reactor.radiation)
	data["max_radiation"] = RBMK_MAX_RADIATION

	data["flux"] = rbmk_round2(linked_reactor.flux)
	data["max_flux"] = RBMK_MAX_FLUX

	data["void_coefficient"] = rbmk_round2(linked_reactor.void_coefficient)

	data["integrity"] = rbmk_round2(linked_reactor.reactor_integrity)
	data["max_integrity"] = linked_reactor.max_reactor_integrity

	data["pressure_current"] = rbmk_round2(linked_reactor.pressure)
	data["pressure_warning"] = RBMK_PRESSURE_WARNING
	data["pressure_critical"] = RBMK_PRESSURE_CRITICAL
	data["pressure_extreme"] = RBMK_PRESSURE_EXTREME

	/************************************************
	 * Coolant Controls
	 ************************************************/
	data["inlet_open"] = linked_reactor.inlet_open
	data["outlet_open"] = linked_reactor.outlet_open

	data["inlet_rate"] = linked_reactor.inlet_rate
	data["inlet_min"] = RBMK_INLET_RATE_MIN
	data["inlet_max"] = RBMK_INLET_RATE_MAX

	data["outlet_target_pressure"] = rbmk_round2(linked_reactor.outlet_target_pressure)
	data["outlet_pressure_max"] = RBMK_OUTLET_PRESSURE_MAX

	var/datum/gas_mixture/inlet_mix = linked_reactor.get_inlet_mix()
	var/datum/gas_mixture/outlet_mix = linked_reactor.get_outlet_mix()

	data["inlet_pressure"] = inlet_mix ? rbmk_round2(inlet_mix.return_pressure()) : 0
	data["outlet_pressure"] = outlet_mix ? rbmk_round2(outlet_mix.return_pressure()) : 0

	/************************************************
	 * History / Graph Data
	 ************************************************/
	var/list/pressure_history = list()
	for (var/pressure_value in linked_reactor.coolant_pressure_history)
		pressure_history += rbmk_round2(pressure_value)
	data["pressure"] = pressure_history

	var/list/reactor_temperature_history = list()
	for (var/temperature_value in linked_reactor.reactor_temperature_history)
		reactor_temperature_history += rbmk_round2(temperature_value)
	data["reactor_temperature_history"] = reactor_temperature_history

	data["gas_composition"] = rbmk_build_gas_composition_data(linked_reactor.coolant_internal)
	data["gas_history"] = rbmk_build_gas_history_data(linked_reactor)

	/************************************************
	 * Rod Inventory
	 ************************************************/
	data["max_normal_slots"] = linked_reactor.max_normal_slots
	data["max_special_slots"] = linked_reactor.max_special_slots

	var/list/rods_list = list()

	for (var/normal_slot_index = 1, normal_slot_index <= linked_reactor.max_normal_slots, normal_slot_index++)
		var/obj/item/rbmk/fuel_rod/normal_rod = null
		if (normal_slot_index <= length(linked_reactor.normal_slots))
			normal_rod = linked_reactor.normal_slots[normal_slot_index]

		rods_list += list(list(
			"type" = normal_rod ? normal_rod.name : "Empty",
			"color" = normal_rod ? normal_rod.rod_color : "grey",
			"depleted" = normal_rod && !normal_rod.active,
			"slot_kind" = "normal",
			"slot_index" = normal_slot_index
		))

	for (var/special_slot_index = 1, special_slot_index <= linked_reactor.max_special_slots, special_slot_index++)
		var/obj/item/rbmk/fuel_rod/special_rod = null
		if (special_slot_index <= length(linked_reactor.special_slots))
			special_rod = linked_reactor.special_slots[special_slot_index]

		rods_list += list(list(
			"type" = special_rod ? special_rod.name : "Empty",
			"color" = special_rod ? special_rod.rod_color : "grey",
			"depleted" = special_rod && !special_rod.active,
			"slot_kind" = "special",
			"slot_index" = special_slot_index
		))

	data["rods"] = rods_list
	return data


/*************************************************************
 * UI ACTIONS
 *************************************************************/

/// Handle TGUI actions
/obj/machinery/computer/rbmk_console/ui_act(action, params)
	. = ..()
	if (.)
		return .

	if (!linked_reactor)
		if (action == "rescan")
			auto_link()
			return TRUE
		return FALSE

	/************************************************
	 * Utility
	 ************************************************/
	if (action == "rescan")
		auto_link()
		return TRUE

	/************************************************
	 * Control Rods / SCRAM
	 ************************************************/
	if (action == "rod_up")
		linked_reactor.control_rod_depth = max(linked_reactor.control_rod_depth - 5, 0)
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "rod_down")
		linked_reactor.control_rod_depth = min(
			linked_reactor.control_rod_depth + 5,
			RBMK_CONTROL_ROD_MAX
		)
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "set_rods")
		var/requested_depth = clamp(
			text2num(params["depth"]),
			0,
			RBMK_CONTROL_ROD_MAX
		)
		linked_reactor.control_rod_depth = requested_depth
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "scram")
		linked_reactor.force_scram()
		return TRUE

	/************************************************
	 * Coolant Controls
	 ************************************************/
	if (action == "toggle_inlet")
		linked_reactor.inlet_open = !linked_reactor.inlet_open
		linked_reactor.wake_coolant_ports()
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "set_inlet_rate")
		linked_reactor.inlet_rate = clamp(
			text2num(params["rate"]),
			RBMK_INLET_RATE_MIN,
			RBMK_INLET_RATE_MAX
		)
		linked_reactor.wake_coolant_ports()
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "toggle_outlet")
		linked_reactor.outlet_open = !linked_reactor.outlet_open
		linked_reactor.wake_coolant_ports()
		linked_reactor.update_linked_consoles()
		return TRUE

	if (action == "set_outlet_pressure")
		linked_reactor.outlet_target_pressure = clamp(
			text2num(params["pressure"]),
			0,
			RBMK_OUTLET_PRESSURE_MAX
		)
		linked_reactor.wake_coolant_ports()
		linked_reactor.update_linked_consoles()
		return TRUE

	/************************************************
	 * Rod Handling
	 ************************************************/
	if (action == "remove_rod")
		var/slot_kind = params["kind"]
		var/slot_index = text2num(params["index"])

		if (!istext(slot_kind))
			return FALSE

		return linked_reactor.remove_rod_by_slot(slot_kind, slot_index, usr)

	return FALSE
