#define RBMK_TURBINE_VOLUME_MAX 1000
#define RBMK_TURBINE_FLOW_RATE_MIN 0
#define RBMK_TURBINE_FLOW_RATE_MAX 1000

#define RBMK_TURBINE_MINIMUM_WORKING_TEMP 500
#define RBMK_TURBINE_HEAT_EXTRACTION_RATIO 0.22
#define RBMK_TURBINE_EFFICIENCY 0.35
#define RBMK_TURBINE_MAX_TEMP_DROP 900
#define RBMK_TURBINE_MAX_POWER_OUTPUT 5000000
#define RBMK_TURBINE_MAX_RPM 120000
#define RBMK_TURBINE_STALE_TIME 2 SECONDS

#define RBMK_TURBINE_MAX_INTEGRITY 100
#define RBMK_TURBINE_TEMP_STRESS_THRESHOLD 8000
#define RBMK_TURBINE_TEMP_DAMAGE_RAMP 9500
#define RBMK_TURBINE_TEMP_DAMAGE_BASE 0.35
#define RBMK_TURBINE_TEMP_DAMAGE_RAMP_MULT 1.15
#define RBMK_TURBINE_DAMAGE_FLOW_MULT 1.5
#define RBMK_TURBINE_DAMAGE_MAX_PER_TICK 8

#define RBMK_TURBINE_SOUND_VOLUME 22
#define RBMK_TURBINE_ICON_STATE "turbine"


/obj/machinery/power/rbmk_turbine
	name = "RBMK turbine"
	desc = "A heavy turbine assembly designed to convert heated RBMK coolant flow into electrical power."
	icon = 'icons/obj/machines/rbmk_turbine.dmi'
	icon_state = RBMK_TURBINE_ICON_STATE

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

	var/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet/inlet = null
	var/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet/outlet = null

	var/datum/gas_mixture/turbine_internal = null
	var/datum/looping_sound/rbmk_turbine/turbine_soundloop = null

	var/running = FALSE
	var/inlet_open = TRUE
	var/outlet_open = TRUE
	var/flow_rate = RBMK_TURBINE_FLOW_RATE_MAX

	var/rpm = 0
	var/last_power_output = 0
	var/last_flow_moles = 0
	var/last_inlet_temperature = 0
	var/last_outlet_temperature = 0
	var/last_inlet_pressure = 0
	var/last_outlet_pressure = 0
	var/last_heat_capacity = 0
	var/last_heat_extracted = 0
	var/last_temperature_drop = 0
	var/last_generation_time = 0

	var/generator_integrity = RBMK_TURBINE_MAX_INTEGRITY
	var/max_generator_integrity = RBMK_TURBINE_MAX_INTEGRITY
	var/last_generator_damage = 0
	var/last_overtemp = 0


/obj/machinery/power/rbmk_turbine/Initialize(mapload)
	. = ..()

	generator_integrity = RBMK_TURBINE_MAX_INTEGRITY
	max_generator_integrity = RBMK_TURBINE_MAX_INTEGRITY
	last_generator_damage = 0
	last_overtemp = 0

	turbine_internal = new /datum/gas_mixture()
	turbine_internal.volume = RBMK_TURBINE_VOLUME_MAX
	turbine_internal.temperature = RBMK_AMBIENT_TEMP

	relink_ports()
	wake_turbine_ports()

	START_PROCESSING(SSmachines, src)

	update_turbine_icon()
	update_turbine_sound()

	return INITIALIZE_HINT_NORMAL


/obj/machinery/power/rbmk_turbine/Destroy()
	STOP_PROCESSING(SSmachines, src)

	if(turbine_soundloop)
		turbine_soundloop.stop()
	QDEL_NULL(turbine_soundloop)

	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	QDEL_NULL(turbine_internal)

	return ..()


/obj/machinery/power/rbmk_turbine/process()
	wake_turbine_ports()

	if(last_generation_time && world.time <= last_generation_time + RBMK_TURBINE_STALE_TIME)
		return

	last_power_output = 0
	last_flow_moles = 0
	last_heat_capacity = 0
	last_heat_extracted = 0
	last_temperature_drop = 0
	last_generator_damage = 0
	last_overtemp = 0
	rpm = 0
	running = FALSE

	update_turbine_icon()
	update_turbine_sound()


/obj/machinery/power/rbmk_turbine/proc/update_turbine_icon()
	icon_state = RBMK_TURBINE_ICON_STATE


/obj/machinery/power/rbmk_turbine/proc/update_turbine_sound()
	if(running && rpm > 0)
		if(!turbine_soundloop)
			turbine_soundloop = new /datum/looping_sound/rbmk_turbine(src, TRUE)

		var/rpm_ratio = CLAMP01(rpm / max(RBMK_TURBINE_MAX_RPM, 1))

		turbine_soundloop.volume = RBMK_TURBINE_SOUND_VOLUME
		turbine_soundloop.extra_range = clamp(5 + round(rpm_ratio * 5), 5, 10)
		turbine_soundloop.falloff_distance = 2
		turbine_soundloop.falloff_exponent = 7

		return

	if(turbine_soundloop)
		turbine_soundloop.stop()
		QDEL_NULL(turbine_soundloop)


/obj/machinery/power/rbmk_turbine/proc/get_generator_integrity_percent()
	return round((generator_integrity / max(max_generator_integrity, 1)) * 100, 0.1)


/obj/machinery/power/rbmk_turbine/proc/update_generator_integrity(gas_temperature)
	last_generator_damage = 0
	last_overtemp = max(gas_temperature - RBMK_TURBINE_TEMP_STRESS_THRESHOLD, 0)

	if(machine_stat & BROKEN)
		return

	if(gas_temperature <= RBMK_TURBINE_TEMP_STRESS_THRESHOLD)
		return

	var/temperature_over_threshold = gas_temperature - RBMK_TURBINE_TEMP_STRESS_THRESHOLD
	var/damage_amount = (temperature_over_threshold / 1000) * RBMK_TURBINE_TEMP_DAMAGE_BASE

	if(gas_temperature > RBMK_TURBINE_TEMP_DAMAGE_RAMP)
		var/temperature_over_ramp = gas_temperature - RBMK_TURBINE_TEMP_DAMAGE_RAMP
		damage_amount += ((temperature_over_ramp / 1000) ** 1.35) * RBMK_TURBINE_TEMP_DAMAGE_RAMP_MULT

	var/flow_ratio = CLAMP01(last_flow_moles / max(flow_rate, 1))
	damage_amount *= 1 + (flow_ratio * RBMK_TURBINE_DAMAGE_FLOW_MULT)
	damage_amount = clamp(damage_amount, 0, RBMK_TURBINE_DAMAGE_MAX_PER_TICK)

	if(damage_amount <= 0)
		return

	last_generator_damage = damage_amount
	generator_integrity = max(generator_integrity - damage_amount, 0)


/obj/machinery/power/rbmk_turbine/proc/check_generator_failure_conditions()
	if(machine_stat & BROKEN)
		return

	if(generator_integrity > 0)
		return

	generator_integrity = 0
	turbine_fail_from_overheat()


/obj/machinery/power/rbmk_turbine/proc/turbine_fail_from_overheat()
	if(machine_stat & BROKEN)
		return

	running = FALSE
	rpm = 0
	last_power_output = 0

	visible_message(span_danger("[src] screams as its generator windings burn out!"))
	playsound(src, 'sound/machines/engine_alert1.ogg', 60, FALSE)

	set_machine_stat(machine_stat | BROKEN)

	if(turbine_soundloop)
		turbine_soundloop.stop()
		QDEL_NULL(turbine_soundloop)

	update_turbine_icon()
	update_turbine_sound()


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


/obj/machinery/power/rbmk_turbine/proc/wake_turbine_ports()
	if(inlet)
		SSair.add_to_active(inlet)
	if(outlet)
		SSair.add_to_active(outlet)


/obj/machinery/power/rbmk_turbine/proc/get_inlet_mix()
	if(length(inlet?.airs) < 1)
		return null
	return inlet.airs[1]


/obj/machinery/power/rbmk_turbine/proc/get_outlet_mix()
	if(length(outlet?.airs) < 1)
		return null
	return outlet.airs[1]


/obj/machinery/power/rbmk_turbine/proc/get_turbine_mix()
	return turbine_internal


/obj/machinery/power/rbmk_turbine/proc/process_working_gas(datum/gas_mixture/working_mix)
	last_power_output = 0
	last_flow_moles = 0
	last_heat_capacity = 0
	last_heat_extracted = 0
	last_temperature_drop = 0
	last_generator_damage = 0
	last_overtemp = 0
	rpm = 0
	running = FALSE

	if(!working_mix || working_mix.total_moles() <= 0)
		last_outlet_temperature = working_mix?.temperature || 0
		update_turbine_icon()
		update_turbine_sound()
		return

	last_flow_moles = working_mix.total_moles()
	last_inlet_temperature = working_mix.temperature
	last_heat_capacity = working_mix.heat_capacity()

	update_generator_integrity(working_mix.temperature)
	check_generator_failure_conditions()

	if(machine_stat & BROKEN)
		last_outlet_temperature = working_mix.temperature
		update_turbine_icon()
		update_turbine_sound()
		return

	if(!powernet || last_heat_capacity <= 0)
		last_outlet_temperature = working_mix.temperature
		update_turbine_icon()
		update_turbine_sound()
		return

	var/useful_temperature_delta = max(working_mix.temperature - RBMK_TURBINE_MINIMUM_WORKING_TEMP, 0)
	if(useful_temperature_delta <= 0)
		last_outlet_temperature = working_mix.temperature
		update_turbine_icon()
		update_turbine_sound()
		return

	var/possible_temperature_drop = clamp(useful_temperature_delta * RBMK_TURBINE_HEAT_EXTRACTION_RATIO, 0, RBMK_TURBINE_MAX_TEMP_DROP)
	var/possible_heat_extracted = last_heat_capacity * possible_temperature_drop
	var/possible_power_output = possible_heat_extracted * RBMK_TURBINE_EFFICIENCY

	last_power_output = clamp(possible_power_output, 0, RBMK_TURBINE_MAX_POWER_OUTPUT)

	if(last_power_output <= 0)
		last_outlet_temperature = working_mix.temperature
		update_turbine_icon()
		update_turbine_sound()
		return

	last_heat_extracted = last_power_output / max(RBMK_TURBINE_EFFICIENCY, 0.01)
	last_temperature_drop = clamp(last_heat_extracted / last_heat_capacity, 0, possible_temperature_drop)

	working_mix.temperature = max(working_mix.temperature - last_temperature_drop, RBMK_AMBIENT_TEMP)
	last_outlet_temperature = working_mix.temperature

	var/power_ratio = CLAMP01(last_power_output / max(RBMK_TURBINE_MAX_POWER_OUTPUT, 1))
	rpm = round(sqrt(power_ratio) * RBMK_TURBINE_MAX_RPM)

	running = TRUE
	last_generation_time = world.time

	add_avail(last_power_output)

	update_turbine_icon()
	update_turbine_sound()


/obj/machinery/power/rbmk_turbine/wrench_act(mob/living/user, obj/item/tool)
	set_anchored(!anchored)
	tool.play_tool_sound(src)

	if(anchored)
		connect_to_network()
		relink_ports()
		wake_turbine_ports()
		balloon_alert(user, "secured")
	else
		QDEL_NULL(inlet)
		QDEL_NULL(outlet)
		disconnect_from_network()
		balloon_alert(user, "unsecured")

	update_turbine_icon()
	update_turbine_sound()

	return TRUE


/obj/machinery/power/rbmk_turbine/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()

	QDEL_NULL(inlet)
	QDEL_NULL(outlet)
	disconnect_from_network()

	if(anchored)
		connect_to_network()
		relink_ports()
		wake_turbine_ports()

	update_turbine_icon()
	update_turbine_sound()


/obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	parent_type = /obj/machinery/atmospherics/components/unary
	anchored = TRUE
	density = FALSE
	piping_layer = 3

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = OBJ_LAYER - 0.1

	var/obj/machinery/power/rbmk_turbine/parent_turbine = null
	var/list/atmos_adjacent_turfs = list()


/obj/machinery/atmospherics/components/unary/rbmk/turbine/base/Initialize(mapload)
	. = ..()

	if(!length(airs))
		airs = list(new /datum/gas_mixture())

	initialize_directions = dir
	connect_nodes()
	update_parents()

	return INITIALIZE_HINT_NORMAL


/obj/machinery/atmospherics/components/unary/rbmk/turbine/base/Destroy()
	parent_turbine = null
	atmos_adjacent_turfs = null

	return ..()


/obj/machinery/atmospherics/components/unary/rbmk/turbine/base/proc/remove_moles_capped(datum/gas_mixture/source_mix, desired_moles)
	if(!source_mix)
		return null

	var/total_source_moles = source_mix.total_moles()
	if(total_source_moles <= 0)
		return null

	desired_moles = clamp(desired_moles, 0, total_source_moles)
	if(desired_moles <= 0)
		return null

	var/remove_ratio = CLAMP01(desired_moles / total_source_moles)
	if(remove_ratio <= 0)
		return null

	return source_mix.remove_ratio(remove_ratio)


/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	name = "RBMK turbine inlet"
	dir = EAST


/obj/machinery/atmospherics/components/unary/rbmk/turbine/inlet/process_atmos()
	if(!parent_turbine?.inlet_open)
		return

	if(length(airs) < 1)
		return

	var/datum/gas_mixture/inlet_pipe_mix = airs[1]
	if(!inlet_pipe_mix || inlet_pipe_mix.total_moles() <= 0)
		return

	if(!parent_turbine.turbine_internal)
		return

	var/desired_moles = clamp(parent_turbine.flow_rate, RBMK_TURBINE_FLOW_RATE_MIN, RBMK_TURBINE_FLOW_RATE_MAX)
	if(desired_moles <= 0)
		return

	parent_turbine.last_inlet_pressure = inlet_pipe_mix.return_pressure()
	parent_turbine.last_inlet_temperature = inlet_pipe_mix.temperature

	var/datum/gas_mixture/moved_mix = remove_moles_capped(inlet_pipe_mix, desired_moles)
	if(!moved_mix || moved_mix.total_moles() <= 0)
		return

	parent_turbine.turbine_internal.merge(moved_mix)

	update_parents()


/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet
	parent_type = /obj/machinery/atmospherics/components/unary/rbmk/turbine/base
	name = "RBMK turbine outlet"
	dir = WEST


/obj/machinery/atmospherics/components/unary/rbmk/turbine/outlet/process_atmos()
	if(!parent_turbine?.outlet_open)
		return

	var/datum/gas_mixture/internal_turbine_mix = parent_turbine.turbine_internal
	if(!internal_turbine_mix || internal_turbine_mix.total_moles() <= 0)
		return

	var/desired_moles = clamp(parent_turbine.flow_rate, RBMK_TURBINE_FLOW_RATE_MIN, RBMK_TURBINE_FLOW_RATE_MAX)
	if(desired_moles <= 0)
		return

	var/datum/gas_mixture/released_mix = remove_moles_capped(internal_turbine_mix, desired_moles)
	if(!released_mix || released_mix.total_moles() <= 0)
		return

	parent_turbine.process_working_gas(released_mix)

	if(length(airs))
		airs[1].merge(released_mix)
		parent_turbine.last_outlet_pressure = airs[1].return_pressure()
		update_parents()
		return

	var/turf/outlet_turf = get_turf(src)
	if(outlet_turf)
		outlet_turf.assume_air(released_mix)
		parent_turbine.last_outlet_pressure = outlet_turf.return_air()?.return_pressure()


#undef RBMK_TURBINE_VOLUME_MAX
#undef RBMK_TURBINE_FLOW_RATE_MIN
#undef RBMK_TURBINE_FLOW_RATE_MAX
#undef RBMK_TURBINE_MINIMUM_WORKING_TEMP
#undef RBMK_TURBINE_HEAT_EXTRACTION_RATIO
#undef RBMK_TURBINE_EFFICIENCY
#undef RBMK_TURBINE_MAX_TEMP_DROP
#undef RBMK_TURBINE_MAX_POWER_OUTPUT
#undef RBMK_TURBINE_MAX_RPM
#undef RBMK_TURBINE_STALE_TIME
#undef RBMK_TURBINE_MAX_INTEGRITY
#undef RBMK_TURBINE_TEMP_STRESS_THRESHOLD
#undef RBMK_TURBINE_TEMP_DAMAGE_RAMP
#undef RBMK_TURBINE_TEMP_DAMAGE_BASE
#undef RBMK_TURBINE_TEMP_DAMAGE_RAMP_MULT
#undef RBMK_TURBINE_DAMAGE_FLOW_MULT
#undef RBMK_TURBINE_DAMAGE_MAX_PER_TICK
#undef RBMK_TURBINE_SOUND_VOLUME
#undef RBMK_TURBINE_ICON_STATE
