/*************************************************************
 * RBMK Reactor Console (Monke TG-Style Final Revision)
 * - Handles reactor monitoring and limited control
 * - Visuals handled strictly via icon_state
 * - No lighting, no child panels, no rod insertion
 * - Live warnings output to chat
 *************************************************************/

/*************************************************************
 * Console Core Definition
 *************************************************************/

/// Primary control console
/obj/machinery/computer/rbmk_console
	name = "RBMK Reactor Console"
	desc = "A console used to monitor and control an RBMK nuclear reactor."
	icon = 'icons/obj/reactor_controller.dmi'
	icon_state = "reactorcontrol-1"
	density = TRUE
	anchored = TRUE

	/*
	 * --- Bounds-based 3×1 layout ---
	 * BYOND anchors bounds at the BOTTOM-LEFT corner of the turf.
	 * This console spans 3 tiles horizontally (96px total),
	 * so pixel_x = -48 perfectly centers the sprite and hitbox
	 * across the middle turf, making all 3 tiles fully clickable.
	 */
	bound_width = 96       // 3 tiles wide (3 × 32)
	bound_height = 32      // 1 tile tall
	pixel_x = -48          // centers bounds visually and physically
	pixel_y = 0

	mouse_opacity = MOUSE_OPACITY_ICON
	layer = OBJ_LAYER
	plane = GAME_PLANE

	var/obj/machinery/rbmk/reactor/linked_reactor = null


/*************************************************************
 * Initialization / Cleanup
 *************************************************************/

/// Initialize console
/obj/machinery/computer/rbmk_console/Initialize(mapload)
	. = ..()
	auto_link()
	update_icon()

/// Cleanup
/obj/machinery/computer/rbmk_console/Destroy()
	linked_reactor = null
	return ..()


/*************************************************************
 * Linking & Visuals
 *************************************************************/

/// Automatically link to nearest reactor in range
/obj/machinery/computer/rbmk_console/proc/auto_link()
	linked_reactor = null
	var/shortest_distance = 999
	for (var/obj/machinery/rbmk/reactor/reactor in range(7, src))
		var/distance = get_dist(src, reactor)
		if (distance < shortest_distance)
			linked_reactor = reactor
			shortest_distance = distance
	update_icon()

/// Update visuals based on reactor integrity only
/obj/machinery/computer/rbmk_console/update_icon()
	. = ..()
	if (!linked_reactor)
		icon_state = "reactorcontrol-1"
		return

	var/integrity = linked_reactor.reactor_integrity
	var/max_integrity = linked_reactor.max_reactor_integrity

	if (integrity >= (max_integrity * 0.7))
		icon_state = "reactorcontrol-1"
	else if (integrity >= (max_integrity * 0.4))
		icon_state = "reactorcontrol-2"
	else
		icon_state = "reactorcontrol-3"



/*************************************************************
 * TGUI / UI Layer
 *************************************************************/

/// Use global physical state (TG standard)
/obj/machinery/computer/rbmk_console/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/computer/rbmk_console/ui_status(mob/user)
	return ..()

/obj/machinery/computer/rbmk_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if (.) return .
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RBMKConsole", name)
		ui.open()
	return ui


/*************************************************************
 * UI Data Export
 *************************************************************/

/// Main console → UI payload
/obj/machinery/computer/rbmk_console/ui_data(mob/user)
	var/list/data = list()
	if (!linked_reactor)
		data["status"] = "No reactor linked"
		return data

	data["control_rods"]   = linked_reactor.control_rod_depth
	data["temperature"]    = linked_reactor.temperature
	data["instability"]    = linked_reactor.instability
	data["radiation"]      = linked_reactor.radiation
	data["flux"]           = linked_reactor.flux
	data["integrity"]      = linked_reactor.reactor_integrity
	data["max_integrity"]  = linked_reactor.max_reactor_integrity

	data["pressure"]       = linked_reactor.coolant_pressure_history
	data["moderator"]      = linked_reactor.moderator_history

	// --- Rod data (read-only)
	var/list/rods_list = list()
	for (var/i = 1, i <= linked_reactor.max_normal_slots, i++)
		var/obj/item/rbmk/fuel_rod/R = (i <= length(linked_reactor.normal_slots)) ? linked_reactor.normal_slots[i] : null
		rods_list += list(list(
			"type" = R ? R.name : "Empty",
			"color" = R ? R.rod_color : "grey",
			"depleted" = (R && !R.active),
			"slot_kind" = "normal",
			"slot_index" = i
		))
	for (var/j = 1, j <= linked_reactor.max_special_slots, j++)
		var/obj/item/rbmk/fuel_rod/RS = (j <= length(linked_reactor.special_slots)) ? linked_reactor.special_slots[j] : null
		rods_list += list(list(
			"type" = RS ? RS.name : "Empty",
			"color" = RS ? RS.rod_color : "grey",
			"depleted" = (RS && !RS.active),
			"slot_kind" = "special",
			"slot_index" = j
		))
	data["rods"] = rods_list

	// --- Coolant state
	data["inlet_open"]  = linked_reactor.inlet_open
	data["outlet_open"] = linked_reactor.outlet_open
	data["inlet_rate"]  = linked_reactor.inlet_rate
	data["inlet_min"]   = RBMK_INLET_RATE_MIN
	data["inlet_max"]   = RBMK_INLET_RATE_MAX
	data["outlet_target_pressure"] = linked_reactor.outlet_target_pressure
	data["outlet_pressure_max"]    = RBMK_OUTLET_PRESSURE_MAX
	data["pressure"]               = linked_reactor.pressure

	/*************************************************************
	 * Gas Composition Snapshot (TGUI-Compatible Format)
	 *************************************************************/
	var/list/gas_comp = list()
	if (linked_reactor.coolant_internal)
		var/datum/gas_mixture/mix = linked_reactor.coolant_internal
		var/total = mix.total_moles()
		if (total > 0)
			for (var/gas_path in mix.gases)
				var/moles = mix.gases[gas_path][MOLES]
				var/percent = (moles / total) * 100
				var/datum/gas/temp_gas = new gas_path()
				// Match TGUI expected Record<string, GasInfo> structure
				gas_comp[temp_gas.id] = list(
					"percent" = round(percent, 0.1),
				)
	data["gas_composition"] = gas_comp

	return data


/*************************************************************
 * UI Actions
 *************************************************************/

/// Handle UI input actions
/obj/machinery/computer/rbmk_console/ui_act(action, params)
	. = ..()
	if (.) return .
	if (!linked_reactor)
		if (action == "rescan")
			auto_link()
			return TRUE
		return

	switch(action)
		if ("scram")
			linked_reactor.control_rod_depth = RBMK_CONTROL_ROD_MAX
			linked_reactor.running = FALSE
			visible_message(span_danger("[name]: Emergency SCRAM! All control rods fully inserted!"))
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("rod_up")
			linked_reactor.control_rod_depth = max(linked_reactor.control_rod_depth - 5, 0)
			if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
				linked_reactor.running = TRUE
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("rod_down")
			linked_reactor.control_rod_depth = min(linked_reactor.control_rod_depth + 5, RBMK_CONTROL_ROD_MAX)
			if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
				linked_reactor.running = TRUE
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("set_rods")
			var/depth = clamp(text2num(params["depth"]), 0, RBMK_CONTROL_ROD_MAX)
			linked_reactor.control_rod_depth = depth
			if (linked_reactor.control_rod_depth < RBMK_CONTROL_ROD_MAX)
				linked_reactor.running = TRUE
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("remove_rod")
			var/kind = params?["kind"]
			var/index = clamp(text2num(params?["index"]), 1, 1000)
			var/obj/item/rbmk/fuel_rod/R = null
			if (kind == "normal" && index <= length(linked_reactor.normal_slots))
				R = linked_reactor.normal_slots[index]
				if (R)
					linked_reactor.normal_slots.Cut(index, index + 1)
					R.loc = get_turf(linked_reactor)
					visible_message(span_notice("[name]: Ejected [R.name] from normal slot #[index]!"))
			else if (kind == "special" && index <= length(linked_reactor.special_slots))
				R = linked_reactor.special_slots[index]
				if (R)
					linked_reactor.special_slots.Cut(index, index + 1)
					R.loc = get_turf(linked_reactor)
					visible_message(span_notice("[name]: Ejected [R.name] from special slot #[index]!"))
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("set_inlet_rate")
			var/rate = clamp(text2num(params["rate"]), RBMK_INLET_RATE_MIN, RBMK_INLET_RATE_MAX)
			linked_reactor.set_inlet_rate(rate)
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("set_outlet_pressure")
			var/press = clamp(text2num(params["pressure"]), 0, RBMK_OUTLET_PRESSURE_MAX)
			linked_reactor.set_outlet_pressure(press)
			linked_reactor.update_linked_consoles()
			return TRUE

		if ("toggle_inlet")
			linked_reactor.toggle_inlet()
			return TRUE

		if ("toggle_outlet")
			linked_reactor.toggle_outlet()
			return TRUE

		if ("rescan")
			auto_link()
			return TRUE

	return FALSE
