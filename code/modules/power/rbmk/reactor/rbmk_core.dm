GLOBAL_DATUM(main_rbmk_engine, /obj/machinery/rbmk/reactor)

/// The core of an RBMK engine.
/obj/machinery/rbmk/reactor
	name = "RBMK Reactor Core"
	desc = "A massive nuclear reactor core. Insert rods at your own risk."
	icon = 'icons/obj/machines/rbmk_reactor.dmi'
	icon_state = "reactor_off"
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32
	layer = 2.6
	plane = GAME_PLANE
	/// Coolant inlet port paired with this vessel.
	var/obj/machinery/atmospherics/components/unary/rbmk/inlet/inlet = null
	/// Coolant outlet port paired with this vessel.
	var/obj/machinery/atmospherics/components/unary/rbmk/outlet/outlet = null
	/// Recent internal coolant pressure samples for the operator graph.
	var/list/coolant_pressure_history
	/// Recent internal coolant temperature samples for the operator graph.
	var/list/coolant_temperature_history
	/// Recent internal coolant inventory samples for the operator graph.
	var/list/coolant_total_moles_history
	/// Recent internal coolant composition snapshots.
	var/list/coolant_gas_hist
	/// Recent vessel temperature samples for the operator graph.
	var/list/reactor_temperature_history
	/// Whether the paired inlet is enabled.
	var/inlet_open = FALSE
	/// Whether the paired outlet is enabled.
	var/outlet_open = FALSE
	/// Requested inlet transfer in moles per second.
	var/inlet_rate = RBMK_INLET_RATE_DEFAULT
	/// Requested outlet transfer in moles per second.
	var/outlet_rate = RBMK_OUTLET_RATE_DEFAULT
	/// Moles admitted during the latest paired atmos transfer.
	var/last_inlet_moles_moved = 0
	/// Moles released during the latest paired atmos transfer.
	var/last_outlet_moles_moved = 0
	/// Latest measured inlet flow in moles per second.
	var/last_inlet_flow_rate = 0
	/// Latest measured outlet flow in moles per second.
	var/last_outlet_flow_rate = 0
	/// Latest measured inlet-pipe pressure.
	var/last_inlet_pressure = 0
	/// Latest measured outlet-pipe pressure.
	var/last_outlet_pressure = 0
	/// SSair cycle in which the paired inlet/outlet transfer was last resolved.
	var/last_coolant_air_cycle = -1
	/// Ordinary fuel rods currently installed in the reactor.
	var/list/normal_slots
	/// Moderator and exotic rods currently installed in the reactor.
	var/list/special_slots
	/// Maximum number of ordinary fuel rods.
	var/max_normal_slots = 12
	/// Maximum number of moderator and exotic rods.
	var/max_special_slots = 4
	/// Current vessel temperature in kelvin.
	var/temperature = RBMK_AMBIENT_TEMP
	/// Current reactor radiation output.
	var/radiation = 0
	/// Current aggregate rod heat output.
	var/thermal_output = 0
	/// Current neutron flux.
	var/flux = 0
	/// Current aggregate positive void coefficient.
	var/void_coefficient = 0
	/// Temperature contribution to the current void coefficient.
	var/void_coefficient_temperature = 0
	/// Pressure contribution to the current void coefficient.
	var/void_coefficient_pressure = 0
	/// Coolant-starvation contribution to the current void coefficient.
	var/void_coefficient_coolant = 0
	/// Flux multiplier supplied by the latest void-coefficient calculation.
	var/last_void_flux_multiplier = 1
	/// Current internal coolant pressure.
	var/pressure = 0
	/// Whether active fuel rods are sustaining a reaction.
	var/running = FALSE
	/// Whether the reactor has been emergency shut down.
	var/scrammed = FALSE
	/// AZ-5 is a destructive, single-use emergency insertion mechanism.
	var/az5_expended = FALSE
	/// Operator-requested control-rod insertion percentage.
	var/control_rod_depth = 0
	/// Actual control-rod insertion percentage after travel delay.
	var/actual_control_rod_depth = 0
	/// Normal control rod travel speed, in percentage points per second.
	var/control_rod_step = 3
	/// Current vessel integrity.
	var/reactor_integrity = RBMK_MAX_INTEGRITY
	/// Maximum vessel integrity.
	var/max_reactor_integrity = RBMK_MAX_INTEGRITY
	/// Integrity lost during the latest simulation step.
	var/last_integrity_damage = 0
	/// Whether the critical-integrity station warning has already been sent.
	var/integrity_warning_started = FALSE
	/// Users currently committed to an interruptible welding repair.
	var/list/active_welder_repairers
	/// Internal coolant gas mixture owned by this vessel.
	var/datum/gas_mixture/coolant_internal = null
	/// Net flux produced during the latest simulation step.
	var/last_tick_flux = 0
	/// Rod flux before control and void modifiers during the latest step.
	var/last_tick_base_flux = 0
	/// Additional flux supplied by the void coefficient during the latest step.
	var/last_tick_void_flux_bonus = 0
	/// Vessel temperature gain during the latest simulation step.
	var/last_tick_temp_gain = 0
	/// Effective coolant-exchange ratio during the latest step.
	var/last_coolant_exchange_ratio = 0
	/// Vessel temperature change caused by coolant during the latest step.
	var/last_coolant_core_temp_change = 0
	/// Coolant temperature change during the latest step.
	var/last_coolant_temperature_change = 0
	/// Number of active rods processed during the latest step.
	var/last_tick_rod_count = 0
	/// Combined thermal-limit bonus from installed moderator rods.
	var/rod_temperature_limit_bonus = 0
	/// Combined coolant-exchange bonus from installed moderator rods.
	var/rod_coolant_exchange_bonus = 0
	/// Combined flux multiplier bonus from installed moderator rods.
	var/rod_flux_multiplier_bonus = 0
	/// Current vessel damage-overlay tier.
	var/current_damage_stage = 0
	/// Looping sound controller for the reactor hum.
	var/datum/looping_sound/rbmk_reactor/reactor_soundloop = null
	/// Items currently cooking on the reactor lid, using the standard griddle signals.
	var/list/griddled_objects
	/// Sizzle loop used while the reactor is hot and has something on top.
	var/datum/looping_sound/grill/grill_loop = null
	/// Whether the reactor lid was hot enough to cook on the previous process tick.
	var/reactor_griddle_active = FALSE
	/// Maximum number of items that fit on top of the reactor.
	var/max_griddled_items = 8
	/// Whether the one-time startup audio sequence has played.
	var/startup_sequence_played = FALSE
	/// Control-rod depth used to detect insertion and withdrawal movement.
	var/previous_control_rod_depth = RBMK_CONTROL_ROD_MAX
	/// Whether control rods are currently travelling toward their target depth.
	var/rod_motion_in_progress = FALSE
	/// Whether the delayed meltdown sequence is committed and running.
	var/meltdown_in_progress = FALSE
	/// Whether destructive meltdown effects have already fired.
	var/meltdown_exploded = FALSE
	/// Whether the failure was initiated by a supermatter cascade.
	var/meltdown_supermatter_failure = FALSE
	/// Minimum interval between decay-meltdown eligibility checks.
	var/decay_check_interval = 2 SECONDS
	COOLDOWN_DECLARE(decay_meltdown_check_cooldown)
	COOLDOWN_DECLARE(flux_anomaly_spawn_cooldown)
	/// Installed supermatter rod that owns the active cascade; null while inactive.
	var/obj/item/rbmk/fuel_rod/supermatter/supermatter_rod = null

/** Returns whether either reactor slot bank contains a rod. */
/obj/machinery/rbmk/reactor/proc/has_fuel_rods()
	return (length(normal_slots) + length(special_slots)) > 0

/** Returns whether an installed rod can sustain fission. */
/obj/machinery/rbmk/reactor/proc/has_active_fuel_rods()
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in (normal_slots + special_slots))
		if(fuel_rod && !fuel_rod.is_depleted() && fuel_rod.contributes_to_reaction)
			return TRUE
	return FALSE

/** Clears reaction output while preserving vessel and coolant state. */
/obj/machinery/rbmk/reactor/proc/reset_reaction_state()
	running = FALSE
	flux = 0
	radiation = 0
	thermal_output = 0
	void_coefficient = 0
	void_coefficient_temperature = 0
	void_coefficient_pressure = 0
	void_coefficient_coolant = 0
	last_void_flux_multiplier = 1
	last_tick_flux = 0
	last_tick_base_flux = 0
	last_tick_void_flux_bonus = 0
	last_tick_temp_gain = 0
	last_coolant_exchange_ratio = 0
	last_coolant_core_temp_change = 0
	last_coolant_temperature_change = 0
	last_tick_rod_count = 0
	reset_reactor_modifier_state()

/** Clears the bonuses supplied by moderator rods. */
/obj/machinery/rbmk/reactor/proc/reset_reactor_modifier_state()
	rod_temperature_limit_bonus = 0
	rod_coolant_exchange_bonus = 0
	rod_flux_multiplier_bonus = 0

/** Recalculates capped moderator bonuses from the installed rods. */
/obj/machinery/rbmk/reactor/proc/update_reactor_modifier_state(list/all_fuel_rods)
	reset_reactor_modifier_state()
	for(var/obj/item/rbmk/fuel_rod/fuel_rod in all_fuel_rods)
		if(!fuel_rod || fuel_rod.is_depleted())
			continue
		var/list/modifier_output = fuel_rod.get_modifier_output()
		if(!islist(modifier_output))
			continue
		rod_temperature_limit_bonus += modifier_output["temperature_limit_bonus"] || 0
		rod_coolant_exchange_bonus += modifier_output["coolant_exchange_bonus"] || 0
		rod_flux_multiplier_bonus += modifier_output["flux_multiplier_bonus"] || 0
	rod_temperature_limit_bonus = clamp(rod_temperature_limit_bonus, 0, RBMK_MODIFIER_PLASMA_TEMP_LIMIT_BONUS_MAX)
	rod_coolant_exchange_bonus = clamp(rod_coolant_exchange_bonus, 0, RBMK_MODIFIER_BLUESPACE_COOLANT_BONUS_MAX)
	rod_flux_multiplier_bonus = clamp(rod_flux_multiplier_bonus, 0, RBMK_MODIFIER_DIAMOND_FLUX_MULT_BONUS_MAX)

/** Returns the thermal-stress threshold after moderator bonuses. */
/obj/machinery/rbmk/reactor/proc/get_effective_temp_stress_threshold()
	return RBMK_TEMP_STRESS_THRESHOLD + rod_temperature_limit_bonus

/** Returns the thermal-damage threshold after moderator bonuses. */
/obj/machinery/rbmk/reactor/proc/get_effective_temp_damage_threshold()
	return RBMK_TEMP_DAMAGE_RAMP + rod_temperature_limit_bonus

/** Creates and starts the reactor's ambient sound loop. */
/obj/machinery/rbmk/reactor/proc/start_reactor_sound()
	if(reactor_soundloop)
		return reactor_soundloop
	reactor_soundloop = new /datum/looping_sound/rbmk_reactor(src, TRUE)
	return reactor_soundloop

/** Stops and deletes the reactor's ambient sound loop. */
/obj/machinery/rbmk/reactor/proc/stop_reactor_sound()
	if(reactor_soundloop)
		reactor_soundloop.stop()
	QDEL_NULL(reactor_soundloop)

/** Changes the reactor sound loop to the requested intensity. */
/obj/machinery/rbmk/reactor/proc/set_reactor_sound_state(new_state)
	if(!reactor_soundloop)
		start_reactor_sound()
	if(!reactor_soundloop)
		return
	reactor_soundloop.set_sound_state(new_state)

/obj/machinery/rbmk/reactor/ex_act(severity, target)
	return FALSE

/obj/machinery/rbmk/reactor/deconstruct(disassembled = TRUE)
	return

/obj/machinery/rbmk/reactor/Initialize(mapload)
	. = ..()
	reset_reaction_state()
	COOLDOWN_START(src, decay_meltdown_check_cooldown, decay_check_interval)
	COOLDOWN_START(src, flux_anomaly_spawn_cooldown, RBMK_FLUX_ANOMALY_COOLDOWN_LOW)
	var/turf/reactor_turf = get_turf(src)
	var/datum/gas_mixture/environment_mix = reactor_turf?.return_air()
	if(environment_mix)
		temperature = environment_mix.temperature
	if(temperature < RBMK_AMBIENT_TEMP)
		temperature = RBMK_AMBIENT_TEMP
	normal_slots = list()
	special_slots = list()
	griddled_objects = list()
	coolant_pressure_history = list()
	coolant_temperature_history = list()
	coolant_total_moles_history = list()
	coolant_gas_hist = list()
	reactor_temperature_history = list()
	grill_loop = new(src, FALSE)
	rbmk_init_coolant()
	relink_ports()
	update_appearance(UPDATE_ICON)
	return .

/obj/machinery/rbmk/reactor/Destroy()
	if(supermatter_rod?.cascade_controller)
		supermatter_rod.stop_cascade(FALSE)
	supermatter_rod = null
	active_welder_repairers = null
	QDEL_NULL(grill_loop)
	stop_reactor_sound()
	rbmk_cleanup_atmos()
	return ..()

/// Map subtype registered as the station's primary RBMK engine.
/obj/machinery/rbmk/reactor/main_engine

/** Registers this reactor as the station's main RBMK engine. */
/obj/machinery/rbmk/reactor/main_engine/Initialize(mapload)
	. = ..()
	GLOB.main_rbmk_engine = src
	return .

/** Clears the main-engine registration when this reactor is deleted. */
/obj/machinery/rbmk/reactor/main_engine/Destroy()
	if(GLOB.main_rbmk_engine == src)
		GLOB.main_rbmk_engine = null
	return ..()

/** Fires AZ-5 and drives the control rods all the way in. */
/obj/machinery/rbmk/reactor/proc/force_scram(mob/user)
	if(meltdown_in_progress)
		return FALSE
	if(az5_expended)
		if(user)
			balloon_alert(user, UNLINT("AZ-5 is broken!"))
			to_chat(user, span_warning("The AZ-5 mechanism has already fired and cannot be used again."))
		return FALSE
	az5_expended = TRUE
	scrammed = TRUE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()
	stop_reactor_sound()
	startup_sequence_played = FALSE
	rod_motion_in_progress = FALSE
	visible_message(span_danger("[src] emits a harsh shutdown alarm as its AZ-5 mechanism fires and tears itself apart!"))
	playsound(src, 'sound/rbmk/alarm.ogg', 75, FALSE)
	playsound(src, 'sound/effects/sparks4.ogg', 60, TRUE)
	var/operator_name = user ? key_name(user) : "automatic system"
	log_game("[operator_name] expended [src]'s AZ-5 emergency shutdown mechanism at [get_area_name(src)].")
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	return TRUE

/obj/machinery/rbmk/reactor/welder_act(mob/living/user, obj/item/tool)
	if(!user || !tool)
		return ITEM_INTERACT_FAILURE
	if(!active_welder_repairers)
		active_welder_repairers = list()
	if(user in active_welder_repairers)
		balloon_alert(user, "already repairing")
		return ITEM_INTERACT_FAILURE
	if(!tool.tool_start_check(user, amount = RBMK_WELDER_REPAIR_FUEL_COST))
		return ITEM_INTERACT_FAILURE
	if(!can_welder_repair(user, TRUE))
		return ITEM_INTERACT_FAILURE
	active_welder_repairers += user
	user.visible_message(
		span_notice("[user] starts repairing [src]'s damaged casing."),
		span_notice("You begin repairing [src]'s damaged casing..."),
		span_hear("You hear welding."),
	)
	INVOKE_ASYNC(src, PROC_REF(welder_repair_loop), user, tool)
	return ITEM_INTERACT_SUCCESS

/** Checks whether the reactor can be safely repaired with a welder. */
/obj/machinery/rbmk/reactor/proc/can_welder_repair(mob/living/user, show_alerts = FALSE)
	if(meltdown_in_progress || supermatter_rod)
		if(show_alerts)
			balloon_alert(user, "too unstable!")
		return FALSE
	if(reactor_integrity <= 0)
		if(show_alerts)
			balloon_alert(user, "beyond repair!")
		return FALSE
	if(temperature > RBMK_REPAIRABLE_TEMP_LIMIT)
		if(show_alerts)
			balloon_alert(user, "too hot!")
			to_chat(user, span_warning("[src] is too hot to safely repair. It must be below [RBMK_REPAIRABLE_TEMP_LIMIT] K."))
		return FALSE
	if(reactor_integrity >= max_reactor_integrity)
		if(show_alerts)
			balloon_alert(user, "fully repaired")
		return FALSE
	return TRUE

/** Removes a user from the active welding-repair set. */
/obj/machinery/rbmk/reactor/proc/finish_welder_repair(mob/living/user)
	if(!active_welder_repairers || !user)
		return
	active_welder_repairers -= user

/** Repeats interruptible welding actions while the reactor remains repairable. */
/obj/machinery/rbmk/reactor/proc/welder_repair_loop(mob/living/user, obj/item/tool)
	if(QDELETED(src))
		return
	if(QDELETED(user) || QDELETED(tool))
		finish_welder_repair(user)
		return
	if(!active_welder_repairers || !(user in active_welder_repairers))
		return
	if(!can_welder_repair(user, TRUE))
		finish_welder_repair(user)
		return
	if(!tool.use_tool(src, user, RBMK_WELDER_REPAIR_TIME, volume = 40, amount = RBMK_WELDER_REPAIR_FUEL_COST))
		finish_welder_repair(user)
		return
	if(!can_welder_repair(user, TRUE))
		finish_welder_repair(user)
		return
	var/old_integrity = reactor_integrity
	reactor_integrity = min(reactor_integrity + RBMK_WELDER_REPAIR_AMOUNT, max_reactor_integrity)
	var/repaired_amount = reactor_integrity - old_integrity
	if(repaired_amount <= 0)
		finish_welder_repair(user)
		balloon_alert(user, "fully repaired")
		return
	balloon_alert(user, "repaired")
	to_chat(user, span_notice("You repair [src]'s casing integrity by [round(repaired_amount, 0.1)]%."))
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	if(reactor_integrity >= max_reactor_integrity)
		integrity_warning_started = FALSE
		finish_welder_repair(user)
		user.visible_message(
			span_notice("[user] finishes repairing [src]'s casing."),
			span_notice("You finish repairing [src]'s casing."),
		)
		return
	INVOKE_ASYNC(src, PROC_REF(welder_repair_loop), user, tool)

/** Refreshes consoles linked to this reactor. */
/obj/machinery/rbmk/reactor/proc/update_linked_consoles()
	for(var/obj/machinery/computer/rbmk_console/console in range(RBMK_CONSOLE_SCAN_RANGE, src))
		if(console.linked_reactor == src)
			console.update_appearance()
			SStgui.update_uis(console)

/** Finds the closest console linked to this reactor. */
/obj/machinery/rbmk/reactor/proc/get_primary_console()
	var/obj/machinery/computer/rbmk_console/primary_console
	var/shortest_distance = INFINITY
	for(var/obj/machinery/computer/rbmk_console/console in range(RBMK_CONSOLE_SCAN_RANGE, src))
		if(console.linked_reactor != src || QDELETED(console))
			continue
		var/current_distance = get_dist(src, console)
		if(current_distance >= shortest_distance)
			continue
		primary_console = console
		shortest_distance = current_distance
	return primary_console
