/// Icon state used while the turbine is idle.
#define RBMK_TURBINE_ICON_OFF "Off"
/// Icon state used while the turbine is generating.
#define RBMK_TURBINE_ICON_ON "On"

// Turbine timing
/// Grace period before generation telemetry becomes inactive.
#define RBMK_TURBINE_GENERATION_GRACE_TIME (10 SECONDS)
/// Idle duration after which old turbine telemetry is cleared.
#define RBMK_TURBINE_TELEMETRY_CLEAR_TIME (30 SECONDS)
/// Duration recent rotor motion keeps the turbine sound loop alive.
/// This must remain longer than the startup cue to avoid repeated restarts.
#define RBMK_TURBINE_SOUND_HOLD_TIME (30 SECONDS)
/// Pressure difference that produces full turbine efficiency.
#define RBMK_TURBINE_DESIGN_PRESSURE_DELTA 3000

/// Generator for an RBMK coolant loop.
/obj/machinery/power/rbmk_turbine
	name = "RBMK turbine"
	desc = "A heavy turbine assembly designed to convert heated RBMK coolant flow into electrical power."
	icon = 'icons/obj/machines/rbmk_turbine.dmi'
	icon_state = RBMK_TURBINE_ICON_OFF
	base_icon_state = RBMK_TURBINE_ICON_OFF
	anchored = TRUE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	use_power = NO_POWER_USE
	can_change_cable_layer = TRUE
	bound_width = 96
	bound_height = 64
	bound_x = -32
	bound_y = 0
	pixel_x = -32
	pixel_y = 0
	layer = OBJ_LAYER + 0.2
	plane = GAME_PLANE
	/// Atmos inlet paired with this turbine assembly.
	var/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet/inlet
	/// Atmos outlet paired with this turbine assembly.
	var/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet/outlet
	/// Internal gas buffer between the inlet and outlet ports.
	var/datum/gas_mixture/turbine_internal
	/// Looping sound controller for mechanical turbine audio.
	var/datum/looping_sound/rbmk_turbine/turbine_soundloop
	/// Internal gas-buffer volume in liters.
	var/internal_volume = 1000
	/// Maximum gas flow accepted per second.
	var/max_flow_rate = 1000
	/// Minimum gas temperature required for power generation.
	var/min_working_temperature = 500
	/// Fraction of available temperature difference extracted from working gas.
	var/heat_extraction_ratio = 0.22
	/// Fraction of extracted heat converted into electrical power.
	var/generator_efficiency = 0.35
	/// Maximum temperature removed from gas in one processing step.
	var/max_temperature_drop = 900
	/// Maximum electrical output in watts.
	var/max_power_output = 5000000
	/// Maximum displayed turbine speed.
	var/max_rpm = 120000
	/// Temperature where sustained overdrive begins wearing down the generator.
	var/generator_damage_temperature = 10000
	/// Generator wear per second for each 1000 K above the damage temperature.
	var/generator_damage_per_thousand_kelvin_per_second = 0.5
	/// Maximum generator wear applied per second.
	var/max_generator_damage_per_second = 4
	/// Generator integrity restored per second at safe temperatures.
	var/generator_integrity_recovery_per_second = 2
	/// Base volume of the turbine loop.
	var/sound_volume = 24
	/// Minimum audible range used by turbine sounds.
	var/sound_min_range = 5
	/// Maximum audible range used by turbine sounds.
	var/sound_max_range = 10
	/// Distance before turbine sound falloff begins.
	var/sound_falloff_distance = 4
	/// Exponent used by turbine sound falloff.
	var/sound_falloff_exponent = 2
	/// Whether the inlet port permits gas transfer.
	var/inlet_open = TRUE
	/// Whether the outlet port permits gas transfer.
	var/outlet_open = TRUE
	/// Requested gas flow in moles per second.
	var/flow_rate = 1000
	/// Current displayed rotor speed.
	var/rpm = 0
	/// Most recently generated power in watts.
	var/last_power_output = 0
	/// Moles of working gas processed during the most recent transfer.
	var/last_flow_moles = 0
	/// Most recently measured inlet gas temperature.
	var/last_inlet_temperature = 0
	/// Most recently calculated outlet gas temperature.
	var/last_outlet_temperature = 0
	/// Most recently measured inlet pressure.
	var/last_inlet_pressure = 0
	/// Most recently measured outlet pressure.
	var/last_outlet_pressure = 0
	/// Most recently calculated positive pressure differential.
	var/last_pressure_delta = 0
	/// Heat capacity of the most recently processed gas parcel.
	var/last_heat_capacity = 0
	/// Heat removed from the most recently processed gas parcel.
	var/last_heat_extracted = 0
	/// Temperature removed from the most recently processed gas parcel.
	var/last_temperature_drop = 0
	/// World time at which power was most recently generated.
	var/last_generation_time = 0
	/// Remaining generator integrity.
	var/generator_integrity = 100
	/// Maximum generator integrity.
	var/max_generator_integrity = 100
	/// Integrity lost during the most recent processing step.
	var/last_generator_damage = 0
	/// Temperature excess above the wear threshold during the latest step.
	var/last_overtemp = 0

/obj/machinery/power/rbmk_turbine/Initialize(mapload)
	. = ..()
	generator_integrity = max_generator_integrity
	turbine_internal = new /datum/gas_mixture()
	turbine_internal.volume = internal_volume
	turbine_internal.temperature = RBMK_AMBIENT_TEMP
	relink_ports()
	wake_turbine_ports()
	update_appearance(UPDATE_ICON)
	update_turbine_sound()
	return .

/obj/machinery/power/rbmk_turbine/Destroy()
	if(turbine_soundloop)
		turbine_soundloop.stop()
	QDEL_NULL(turbine_soundloop)
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	QDEL_NULL(turbine_internal)
	return ..()

/obj/machinery/power/rbmk_turbine/process(seconds_per_tick)
	wake_turbine_ports()
	if(last_generation_time && world.time <= last_generation_time + RBMK_TURBINE_GENERATION_GRACE_TIME)
		return
	rpm = 0
	if(!last_generation_time || world.time > last_generation_time + RBMK_TURBINE_TELEMETRY_CLEAR_TIME)
		reset_turbine_telemetry()
	update_appearance(UPDATE_ICON)
	update_turbine_sound()

/obj/machinery/power/rbmk_turbine/update_icon_state()
	. = ..()
	if(is_actively_generating())
		icon_state = RBMK_TURBINE_ICON_ON
		return
	icon_state = RBMK_TURBINE_ICON_OFF

/** Clears values reported by the latest generation step. */
/obj/machinery/power/rbmk_turbine/proc/reset_generation_telemetry()
	last_power_output = 0
	last_flow_moles = 0
	last_heat_capacity = 0
	last_heat_extracted = 0
	last_temperature_drop = 0
	last_generator_damage = 0
	last_overtemp = 0
	rpm = 0

/** Clears generation and port telemetry after extended inactivity. */
/obj/machinery/power/rbmk_turbine/proc/reset_turbine_telemetry()
	reset_generation_telemetry()
	last_inlet_temperature = 0
	last_outlet_temperature = 0
	last_inlet_pressure = 0
	last_outlet_pressure = 0
	last_pressure_delta = 0

/** Recalculates the positive pressure difference across the turbine. */
/obj/machinery/power/rbmk_turbine/proc/update_pressure_delta()
	last_pressure_delta = max(last_inlet_pressure - last_outlet_pressure, 0)

/** Returns whether the turbine has generated power recently. */
/obj/machinery/power/rbmk_turbine/proc/is_actively_generating()
	if(machine_stat & BROKEN)
		return FALSE
	if(!last_generation_time)
		return FALSE
	if(world.time > last_generation_time + RBMK_TURBINE_GENERATION_GRACE_TIME)
		return FALSE
	if(last_power_output <= 0)
		return FALSE
	if(last_flow_moles <= 0)
		return FALSE
	return TRUE

/** Returns whether recent rotor activity should keep turbine audio playing. */
/obj/machinery/power/rbmk_turbine/proc/should_play_turbine_sound()
	if(machine_stat & BROKEN)
		return FALSE
	if(!last_generation_time)
		return FALSE
	return world.time <= last_generation_time + RBMK_TURBINE_SOUND_HOLD_TIME

/** Starts, updates, or stops audio to match recent rotor activity. */
/obj/machinery/power/rbmk_turbine/proc/update_turbine_sound()
	if(!should_play_turbine_sound())
		if(turbine_soundloop)
			turbine_soundloop.stop()
			QDEL_NULL(turbine_soundloop)
		return
	if(!turbine_soundloop)
		turbine_soundloop = new /datum/looping_sound/rbmk_turbine(src, TRUE)
	var/rpm_ratio = CLAMP01(rpm / max(max_rpm, 1))
	turbine_soundloop.volume = sound_volume
	turbine_soundloop.extra_range = clamp(
		sound_min_range + round(rpm_ratio * (sound_max_range - sound_min_range)),
		sound_min_range,
		sound_max_range,
	)
	turbine_soundloop.falloff_distance = sound_falloff_distance
	turbine_soundloop.falloff_exponent = sound_falloff_exponent

/** Applies generator wear or recovery for the elapsed processing time. */
/obj/machinery/power/rbmk_turbine/proc/update_generator_integrity(gas_temperature, seconds_per_tick)
	last_generator_damage = 0
	last_overtemp = max(gas_temperature - generator_damage_temperature, 0)
	if(machine_stat & BROKEN)
		return
	if(gas_temperature <= generator_damage_temperature)
		generator_integrity = min(generator_integrity + (generator_integrity_recovery_per_second * seconds_per_tick), max_generator_integrity)
		return
	var/temperature_over_limit = gas_temperature - generator_damage_temperature
	var/damage_amount = (temperature_over_limit / 1000) * generator_damage_per_thousand_kelvin_per_second * seconds_per_tick
	damage_amount = clamp(damage_amount, 0, max_generator_damage_per_second * seconds_per_tick)
	if(damage_amount <= 0)
		return
	last_generator_damage = damage_amount
	generator_integrity = max(generator_integrity - damage_amount, 0)

/** Fails the generator when its integrity reaches zero. */
/obj/machinery/power/rbmk_turbine/proc/check_generator_failure_conditions()
	if(machine_stat & BROKEN)
		return
	if(generator_integrity > 0)
		return
	generator_integrity = 0
	turbine_fail_from_overheat()

/** Breaks and deletes a turbine destroyed by superheated working gas. */
/obj/machinery/power/rbmk_turbine/proc/turbine_fail_from_overheat()
	if(machine_stat & BROKEN)
		return
	rpm = 0
	last_power_output = 0
	last_flow_moles = 0
	set_machine_stat(machine_stat | BROKEN)
	if(turbine_soundloop)
		turbine_soundloop.stop()
		QDEL_NULL(turbine_soundloop)
	visible_message(span_danger("[src] screams as superheated coolant destroys the turbine assembly!"))
	playsound(src, 'sound/machines/engine_alert1.ogg', 60, FALSE)
	explosion(get_turf(src), devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2)
	qdel(src)

/** Recreates the turbine ports on their expected adjacent tiles. */
/obj/machinery/power/rbmk_turbine/proc/relink_ports()
	var/turf/center_turf = get_turf(src)
	if(!center_turf)
		return
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	var/turf/outlet_turf = get_step(center_turf, WEST)
	if(outlet_turf)
		var/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet/new_outlet = new(outlet_turf)
		new_outlet.parent_turbine = src
		new_outlet.dir = WEST
		outlet = new_outlet
	var/turf/inlet_turf = get_step(center_turf, EAST)
	if(inlet_turf)
		var/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet/new_inlet = new(inlet_turf)
		new_inlet.parent_turbine = src
		new_inlet.dir = EAST
		inlet = new_inlet

/** Wakes both turbine ports so gas-flow changes are processed promptly. */
/obj/machinery/power/rbmk_turbine/proc/wake_turbine_ports()
	if(inlet)
		SSair.start_processing_machine(inlet)
	if(outlet)
		SSair.start_processing_machine(outlet)

/** Extracts usable heat from a parcel of working gas and adds power to the grid. */
/obj/machinery/power/rbmk_turbine/proc/process_working_gas(datum/gas_mixture/working_mix, seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	last_generator_damage = 0
	last_overtemp = 0
	if(!working_mix || working_mix.total_moles() <= 0)
		last_outlet_temperature = working_mix?.temperature || 0
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	last_flow_moles = working_mix.total_moles()
	last_inlet_temperature = working_mix.temperature
	last_heat_capacity = working_mix.heat_capacity()
	update_generator_integrity(working_mix.temperature, seconds_per_tick)
	check_generator_failure_conditions()
	if(machine_stat & BROKEN)
		reset_generation_telemetry()
		last_outlet_temperature = working_mix.temperature
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	if(!powernet || last_heat_capacity <= 0)
		last_outlet_temperature = working_mix.temperature
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	var/useful_temperature_delta = max(working_mix.temperature - min_working_temperature, 0)
	if(useful_temperature_delta <= 0)
		last_outlet_temperature = working_mix.temperature
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	var/pressure_efficiency = CLAMP01(last_pressure_delta / RBMK_TURBINE_DESIGN_PRESSURE_DELTA)
	if(pressure_efficiency <= 0)
		last_outlet_temperature = working_mix.temperature
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	var/possible_temperature_drop = clamp(useful_temperature_delta * heat_extraction_ratio * pressure_efficiency, 0, max_temperature_drop)
	var/possible_heat_extracted = last_heat_capacity * possible_temperature_drop
	var/possible_power_output = (possible_heat_extracted * generator_efficiency) / max(seconds_per_tick, 0.1)
	last_power_output = clamp(possible_power_output, 0, max_power_output)
	if(last_power_output <= 0)
		last_outlet_temperature = working_mix.temperature
		update_appearance(UPDATE_ICON)
		update_turbine_sound()
		return
	last_heat_extracted = (last_power_output * max(seconds_per_tick, 0.1)) / max(generator_efficiency, 0.01)
	last_temperature_drop = clamp(last_heat_extracted / last_heat_capacity, 0, possible_temperature_drop)
	working_mix.temperature = max(working_mix.temperature - last_temperature_drop, RBMK_AMBIENT_TEMP)
	last_outlet_temperature = working_mix.temperature
	var/power_ratio = CLAMP01(last_power_output / max(max_power_output, 1))
	rpm = round(sqrt(power_ratio) * max_rpm)
	last_generation_time = world.time
	add_avail(last_power_output)
	update_appearance(UPDATE_ICON)
	update_turbine_sound()

/obj/machinery/power/rbmk_turbine/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool, time = 2 SECONDS) != SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_FAILURE
	if(anchored)
		connect_to_network()
		relink_ports()
		wake_turbine_ports()
	else
		QDEL_NULL(inlet)
		QDEL_NULL(outlet)
		disconnect_from_network()
	update_appearance(UPDATE_ICON)
	update_turbine_sound()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/rbmk_turbine/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	disconnect_from_network()
	if(anchored)
		connect_to_network()
		relink_ports()
		wake_turbine_ports()
	update_appearance(UPDATE_ICON)
	update_turbine_sound()

/// Hidden unary atmos component paired with an RBMK turbine port.
/obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = OBJ_LAYER - 0.1
	/// Turbine assembly that owns this port.
	var/obj/machinery/power/rbmk_turbine/parent_turbine

/obj/machinery/atmospherics/components/unary/rbmk/turbine/base/Initialize(mapload)
	. = ..()
	if(!length(airs))
		airs = list(new /datum/gas_mixture())
	initialize_directions = dir
	connect_nodes()
	update_parents()
	return .

/obj/machinery/atmospherics/components/unary/rbmk/turbine/base/Destroy()
	parent_turbine = null
	return ..()

/// Gas inlet placed east of an RBMK turbine.
/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	name = "RBMK turbine inlet"
	dir = EAST

/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	if(!parent_turbine?.inlet_open)
		return
	if(length(airs) < 1)
		return
	var/datum/gas_mixture/inlet_pipe_mix = airs[1]
	if(!inlet_pipe_mix || inlet_pipe_mix.total_moles() <= 0)
		return
	if(!parent_turbine.turbine_internal)
		return
	var/inlet_pressure = inlet_pipe_mix.return_pressure()
	var/internal_pressure = parent_turbine.turbine_internal.return_pressure()
	var/pressure_flow_ratio = CLAMP01((inlet_pressure - internal_pressure) / RBMK_TURBINE_DESIGN_PRESSURE_DELTA)
	if(pressure_flow_ratio <= 0)
		return
	var/desired_moles = clamp(parent_turbine.flow_rate, 0, parent_turbine.max_flow_rate)
	desired_moles *= pressure_flow_ratio * seconds_per_tick
	if(desired_moles <= 0)
		return
	parent_turbine.last_inlet_pressure = inlet_pipe_mix.return_pressure()
	parent_turbine.last_inlet_temperature = inlet_pipe_mix.temperature
	parent_turbine.update_pressure_delta()
	var/datum/gas_mixture/moved_mix = inlet_pipe_mix.remove(desired_moles)
	if(!moved_mix || moved_mix.total_moles() <= 0)
		return
	parent_turbine.turbine_internal.merge(moved_mix)
	update_parents()

/// Gas outlet placed west of an RBMK turbine.
/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	name = "RBMK turbine outlet"
	dir = WEST

/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet/process_atmos(seconds_per_tick = RBMK_ATMOS_PROCESS_SECONDS)
	if(!parent_turbine?.outlet_open)
		return
	var/datum/gas_mixture/internal_turbine_mix = parent_turbine.turbine_internal
	if(!internal_turbine_mix || internal_turbine_mix.total_moles() <= 0)
		return
	var/internal_pressure = internal_turbine_mix.return_pressure()
	var/downstream_pressure = 0
	if(length(airs))
		downstream_pressure = airs[1].return_pressure()
	var/pressure_flow_ratio = CLAMP01((internal_pressure - downstream_pressure) / RBMK_TURBINE_DESIGN_PRESSURE_DELTA)
	if(pressure_flow_ratio <= 0)
		return
	parent_turbine.last_outlet_pressure = downstream_pressure
	parent_turbine.update_pressure_delta()
	var/desired_moles = clamp(parent_turbine.flow_rate, 0, parent_turbine.max_flow_rate)
	desired_moles *= pressure_flow_ratio * seconds_per_tick
	if(desired_moles <= 0)
		return
	var/datum/gas_mixture/released_mix = internal_turbine_mix.remove(desired_moles)
	if(!released_mix || released_mix.total_moles() <= 0)
		return
	parent_turbine.process_working_gas(released_mix, seconds_per_tick)
	if(length(airs))
		airs[1].merge(released_mix)
		parent_turbine.last_outlet_pressure = airs[1].return_pressure()
		parent_turbine.update_pressure_delta()
		update_parents()
		return
	var/turf/outlet_turf = get_turf(src)
	if(outlet_turf)
		outlet_turf.assume_air(released_mix)
		parent_turbine.last_outlet_pressure = outlet_turf.return_air()?.return_pressure()
		parent_turbine.update_pressure_delta()

#undef RBMK_TURBINE_ICON_OFF
#undef RBMK_TURBINE_ICON_ON
#undef RBMK_TURBINE_GENERATION_GRACE_TIME
#undef RBMK_TURBINE_TELEMETRY_CLEAR_TIME
#undef RBMK_TURBINE_SOUND_HOLD_TIME
#undef RBMK_TURBINE_DESIGN_PRESSURE_DELTA
