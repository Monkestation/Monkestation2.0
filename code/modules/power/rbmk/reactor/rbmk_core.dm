/*************************************************************
 * RBMK Reactor Core (logic core = center of 3x3 footprint)
 * - Reactor anchored on center turf
 * - Spawns child shell tiles for 3x3 body
 * - Coolant inlet/outlet placed flush left/right of center
 *************************************************************/

/obj/machinery/rbmk/reactor
	name = "RBMK Reactor Core"
	desc = "A massive nuclear reactor core. Insert rods at your own risk."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_off"
	bound_width = 96
	bound_height = 96
	pixel_x = -32   // shift left one tile
	pixel_y = -32   // shift down one tile
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	plane = GAME_PLANE
	layer = OBJ_LAYER

	// Coolant IO
	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null

	// Children for 3x3 footprint
	var/list/children = list()

	// Fuel rod slots
	var/list/normal_slots = list()
	var/list/special_slots = list()
	var/max_normal_slots = 12
	var/max_special_slots = 4

	// Reactor state
	var/temperature = 0
	var/radiation = 0
	var/thermal_output = 0
	var/max_temp = 20000
	var/running = FALSE

	// Control rods
	var/control_rod_depth = 0

	// Flux / Instability / Integrity
	var/flux = 0
	var/instability = 0
	var/max_reactor_integrity = 100
	var/reactor_integrity = 100
	var/repairable = FALSE

	// Pressure / Gas Moderation
	var/pressure = 0
	var/moderator_level = 0
	var/list/pressure_history = list()
	var/list/moderator_history = list()

	// ---- Coolant valve/flow control ----
	var/inlet_open = TRUE
	var/outlet_open = TRUE
	var/flow_rate = 1.0
	var/flow_min = 0.0
	var/flow_max = 2.0

	/// NEW: inlet and outlet control
	var/inlet_rate = 1.0                   // liters/sec scale
	var/inlet_rate_min = 0.1
	var/inlet_rate_max = 10.0
	var/outlet_target_pressure = 101.3     // regulator target kPa
	var/outlet_pressure_max = 10000

	// ---- Coolant telemetry histories (last 50 samples) ----
	var/list/coolant_pressure_history = list()
	var/list/coolant_temperature_history = list()
	var/list/coolant_total_moles_history = list()
	var/list/coolant_gas_hist = list()   // Assoc: gas_path -> percentages

/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()

	// Move reactor object to the center tile of its 3×3 footprint
	loc = locate(x+1, y+1, z)

	// Seed temperature from turf air if available
	var/turf/T = get_turf(src)
	if (istype(T))
		var/datum/gas_mixture/env = T.return_air()
		temperature = env ? env.temperature : T0C + 20
	else
		temperature = T0C + 20

	START_PROCESSING(SSmachines, src)

	// Spawn child tiles around the center
	for (var/dx in -1 to 1)
		for (var/dy in -1 to 1)
			if(dx == 0 && dy == 0)
				continue
			var/turf/CT = locate(x+dx, y+dy, z)
			if(CT)
				var/obj/structure/rbmk/reactor_child/C = new(CT)
				C.parent = src
				children += C

	// Place coolant ports flush left/right of center
	relink_ports()

/obj/machinery/rbmk/reactor/Destroy()
	STOP_PROCESSING(SSmachines, src)
	for(var/C in children)
		qdel(C)
	if (inlet)  qdel(inlet)
	if (outlet) qdel(outlet)
	return ..()

/obj/machinery/rbmk/reactor/proc/relink_ports()
	var/turf/center = get_turf(src)
	if(!center) return

	if(inlet)  qdel(inlet)
	if(outlet) qdel(outlet)

	// Inlet: one tile west of center
	var/turf/inlet_tile = get_step(center, WEST)
	if(inlet_tile)
		inlet = new /obj/machinery/atmospherics/components/unary/rbmk/inlet(inlet_tile)
		inlet.parent_reactor = src
		inlet.dir = WEST   // face outward

	// Outlet: one tile east of center
	var/turf/outlet_tile = get_step(center, EAST)
	if(outlet_tile)
		outlet = new /obj/machinery/atmospherics/components/unary/rbmk/outlet(outlet_tile)
		outlet.parent_reactor = src
		outlet.dir = EAST   // face outward

/obj/machinery/rbmk/reactor/process(delta_time)
	if (!running)
		return

	var/rod_effect = (100 - control_rod_depth) / 100.0
	temperature = clamp(temperature + (rod_effect * 10) - (control_rod_depth * 0.05), 0, max_temp)

	radiation = clamp(temperature * 0.01 + flux * 2, 0, 500)
	instability = clamp(instability + rod_effect * 0.5 + (flux * 0.1), 0, 100)
	flux = clamp(flux + rod_effect * 2 - (moderator_level * 0.05), 0, 100)

	if (temperature > 3000 || instability > 80)
		reactor_integrity = max(reactor_integrity - 1, 0)

	pressure = clamp(pressure + (temperature / 1000) - (control_rod_depth * 0.05), 0, 100)
	moderator_level = clamp(moderator_level - rod_effect * 0.2 + (control_rod_depth * 0.05), 0, 100)

	pressure_history += pressure
	if (length(pressure_history) > 50) pressure_history.Cut(1, 2)

	moderator_history += moderator_level
	if (length(moderator_history) > 50) moderator_history.Cut(1, 2)

	handle_coolant(delta_time)
	sample_coolant()

	update_linked_consoles()

/*************************************************************
 * Valve/Flow control (UI helpers)
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/toggle_inlet()
	inlet_open = !inlet_open
	update_linked_consoles()
	return inlet_open

/obj/machinery/rbmk/reactor/proc/toggle_outlet()
	outlet_open = !outlet_open
	update_linked_consoles()
	return outlet_open

/obj/machinery/rbmk/reactor/proc/set_inlet_rate(val)
	inlet_rate = clamp(val, inlet_rate_min, inlet_rate_max)
	update_linked_consoles()
	return inlet_rate

/obj/machinery/rbmk/reactor/proc/set_outlet_pressure(val)
	outlet_target_pressure = clamp(val, 0, outlet_pressure_max)
	update_linked_consoles()
	return outlet_target_pressure

/obj/machinery/rbmk/reactor/proc/set_flow_rate(val)
	// compatibility shim
	return set_inlet_rate(val)

/obj/machinery/rbmk/reactor/proc/get_flow_state()
	return list(
		"inlet_open" = inlet_open,
		"outlet_open" = outlet_open,
		"flow_rate" = inlet_rate,
		"flow_min" = inlet_rate_min,
		"flow_max" = inlet_rate_max,
		"outlet_target_pressure" = outlet_target_pressure
	)

/*************************************************************
 * Pressure getters for console UI
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/get_inlet_pressure()
	var/datum/gas_mixture/in_mix = get_inlet_mix()
	if(in_mix)
		return in_mix.return_pressure()
	return 0

/obj/machinery/rbmk/reactor/proc/get_outlet_pressure()
	var/datum/gas_mixture/out_mix = get_outlet_mix()
	if(out_mix)
		return out_mix.return_pressure()
	return 0

/*************************************************************
 * Atmos integration
 *************************************************************/

/// Inlet mix
/obj/machinery/rbmk/reactor/proc/get_inlet_mix()
	if(inlet && inlet.airs && inlet.airs.len && inlet.airs[1])
		return inlet.airs[1]
	return null

/// Outlet mix
/obj/machinery/rbmk/reactor/proc/get_outlet_mix()
	if(outlet && outlet.airs && outlet.airs.len && outlet.airs[1])
		return outlet.airs[1]
	return null

/// Prefer inlet, else outlet
/obj/machinery/rbmk/reactor/proc/get_coolant_mix()
	var/datum/gas_mixture/mix = get_inlet_mix()
	if(!mix) mix = get_outlet_mix()
	return mix

/obj/machinery/rbmk/reactor/proc/sample_coolant()
	var/datum/gas_mixture/mix = get_coolant_mix()
	if(!mix) return

	var/press = mix.return_pressure()
	var/temp  = mix.temperature
	var/total = mix.total_moles()

	coolant_pressure_history += press
	if(length(coolant_pressure_history) > 50) coolant_pressure_history.Cut(1, 2)

	coolant_temperature_history += temp
	if(length(coolant_temperature_history) > 50) coolant_temperature_history.Cut(1, 2)

	coolant_total_moles_history += total
	if(length(coolant_total_moles_history) > 50) coolant_total_moles_history.Cut(1, 2)

	if(total <= 0)
		for (var/gp in coolant_gas_hist)
			var/list/L = coolant_gas_hist[gp]
			L += 0
			if(length(L) > 50) L.Cut(1, 2)
		return

	for (var/gas_path in mix.gases)
		var/moles = mix.gases[gas_path][MOLES]
		var/percent = clamp((moles / total) * 100, 0, 100)
		if(!(gas_path in coolant_gas_hist))
			coolant_gas_hist[gas_path] = list()
		var/list/series = coolant_gas_hist[gas_path]
		series += percent
		if(length(series) > 50) series.Cut(1, 2)

	for (var/existing_gas_path in coolant_gas_hist)
		if(!(existing_gas_path in mix.gases))
			var/list/series2 = coolant_gas_hist[existing_gas_path]
			series2 += 0
			if(length(series2) > 50) series2.Cut(1, 2)

/obj/machinery/rbmk/reactor/proc/get_coolant_snapshot()
	var/datum/gas_mixture/mix = get_coolant_mix()
	if(!mix)
		return list("pressure" = 0, "temperature" = 0, "total_moles" = 0, "composition" = list())

	var/total = mix.total_moles()
	var/list/comp = list()
	if(total > 0)
		for (var/gas_path in mix.gases)
			var/moles = mix.gases[gas_path][MOLES]
			comp["[gas_path]"] = clamp((moles / total) * 100, 0, 100)

	return list(
		"pressure" = mix.return_pressure(),
		"temperature" = mix.temperature,
		"total_moles" = total,
		"composition" = comp
	)

/obj/machinery/rbmk/reactor/proc/get_coolant_history_for_ui()
	var/list/gases = list()
	for (var/gas_path in coolant_gas_hist)
		var/list/series = coolant_gas_hist[gas_path]
		gases += list(list("id" = "[gas_path]", "values" = series.Copy()))

	return list(
		"pressure" = coolant_pressure_history.Copy(),
		"temperature" = coolant_temperature_history.Copy(),
		"total_moles" = coolant_total_moles_history.Copy(),
		"gases" = gases
	)

/obj/machinery/rbmk/reactor/proc/handle_coolant(seconds_per_tick)
	if(!inlet_open || !outlet_open) return
	if(!inlet || !outlet) return

	var/datum/gas_mixture/in_mix  = get_inlet_mix()
	var/datum/gas_mixture/out_mix = get_outlet_mix()
	if(!in_mix || !out_mix) return

	if(in_mix.total_moles() > 0)
		var/delta_T = temperature - in_mix.temperature
		if(abs(delta_T) > 0.5)
			var/transfer = min(abs(delta_T) * 0.05, 200) * max(seconds_per_tick, 1) * inlet_rate
			if(delta_T > 0)
				temperature = max(0, temperature - transfer)
				in_mix.temperature += transfer
			else
				temperature += transfer
				in_mix.temperature = max(0, in_mix.temperature - transfer)

		var/base_ratio = 0.10
		var/datum/gas_mixture/moved = in_mix.remove_ratio(base_ratio * inlet_rate)
		if(moved && moved.total_moles() > 0)
			out_mix.merge(moved)

		// regulator: vent if outlet pressure > target
		if(out_mix.return_pressure() > outlet_target_pressure)
			var/release_ratio = clamp((out_mix.return_pressure() - outlet_target_pressure) / 100, 0, 1)
			var/datum/gas_mixture/released = out_mix.remove_ratio(release_ratio)
			if(released) qdel(released)

/*************************************************************
 * UI fanout
 *************************************************************/

/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for (var/obj/machinery/computer/rbmk_console/C in world)
		if (C.linked_reactor == src)
			C.update_icon()
			SStgui.update_uis(C)

/*************************************************************
 * Reactor Child Tiles
 *************************************************************/

/// Children are invisible placeholders (no duplicate icon)
/obj/structure/rbmk/reactor_child
	name = "RBMK Reactor Core"
	desc = "Part of a massive nuclear reactor core."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = ""  // blank so only the main sprite draws
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	var/obj/machinery/rbmk/reactor/parent

/obj/structure/rbmk/reactor_child/attackby(obj/item/I, mob/user, params)
	if(parent)
		return parent.attackby(I, user, params)
	return ..()

/obj/structure/rbmk/reactor_child/attack_hand(mob/user)
	if(parent)
		return parent.attack_hand(user)
	return ..()

/*************************************************************
 * Atmos I/O Components
 *************************************************************/

/// Common base
/obj/machinery/atmospherics/components/unary/rbmk/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	icon = null
	icon_state = null
	hide = FALSE
	showpipe = TRUE
	shift_underlay_only = TRUE
	layer = GAS_PUMP_LAYER
	plane = GAME_PLANE
	piping_layer = 3
	var/obj/machinery/rbmk/reactor/parent_reactor = null

/obj/machinery/atmospherics/components/unary/rbmk/base/Initialize(mapload)
	. = ..()
	airs = list(new /datum/gas_mixture())
	initialize_directions = dir
	connect_nodes()
	update_parents()

/obj/machinery/atmospherics/components/unary/rbmk/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Inlet"
	dir = WEST

/obj/machinery/atmospherics/components/unary/rbmk/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/base
	name = "RBMK Coolant Outlet"
	dir = EAST
