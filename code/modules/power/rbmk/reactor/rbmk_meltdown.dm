/obj/machinery/rbmk/reactor/proc/check_decay_meltdown()
	if(meltdown_in_progress || running)
		return

	// Avoid checking this every tick.
	if(world.time < last_decay_check + decay_check_interval)
		return

	last_decay_check = world.time

	if(temperature >= decay_meltdown_threshold)
		trigger_meltdown("Post-SCRAM decay heat runaway")


/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
	if(meltdown_in_progress)
		return

	meltdown_in_progress = TRUE
	meltdown_announced = TRUE

	scrammed = TRUE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()
	reactor_integrity = 0

	world << span_danger("[RBMK_MELTDOWN_PREFIX]: [reason]!")
	priority_announce("[RBMK_MELTDOWN_BROADCAST] [reason]", "RBMK Reactor Alert")

	cut_overlays()
	current_damage_overlay_image = null
	current_damage_stage = 4
	update_reactor_icon()

	#if RBMK_MELTDOWN_RADIATION
	meltdown_radiation_pulse()
	#endif

	#if RBMK_MELTDOWN_ATMOS_DUMP
	meltdown_atmos_release()
	#endif

	#if RBMK_MELTDOWN_EXPLOSIONS
	meltdown_explosions()
	#endif

	#if RBMK_MELTDOWN_ALARMS
	meltdown_area_alarms()
	#endif

	temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP)
	flux = 0
	radiation = 0
	thermal_output = 0
	void_coefficient = 0

	update_linked_consoles()
	log_game("[src] MELTDOWN triggered: [reason]")


/obj/machinery/rbmk/reactor/proc/trigger_supermatter_rod_meltdown(reason)
	if(meltdown_in_progress)
		return

	meltdown_in_progress = TRUE
	meltdown_announced = TRUE

	scrammed = TRUE
	running = FALSE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reactor_integrity = 0

	world << span_userdanger("[RBMK_MELTDOWN_PREFIX]: SUPERMATTER CASCADE FAILURE: [reason]!")
	priority_announce(
		"RBMK supermatter rod cascade failure detected. Reactor containment has entered a resonance-collapse meltdown state.",
		"RBMK Supermatter Cascade Alert",
		'sound/misc/airraid.ogg'
	)

	cut_overlays()
	current_damage_overlay_image = null
	current_damage_stage = 4
	update_reactor_icon()

	// This is intentionally not a normal thermal SCRAM reset.
	// The SM rod failure leaves the reactor in an extreme resonance-collapse state.
	temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP * 2)
	flux = RBMK_MAX_FLUX
	radiation = RBMK_MAX_RADIATION
	thermal_output = 0
	void_coefficient = 0

	#if RBMK_MELTDOWN_RADIATION
	meltdown_radiation_pulse()
	#endif

	#if RBMK_MELTDOWN_ATMOS_DUMP
	meltdown_atmos_release()
	#endif

	#if RBMK_MELTDOWN_EXPLOSIONS
	meltdown_explosions()
	#endif

	#if RBMK_MELTDOWN_ALARMS
	meltdown_area_alarms()
	#endif

	update_linked_consoles()
	log_game("[src] SUPERMATTER ROD MELTDOWN triggered: [reason]")


/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
	radiation_pulse(
		src,
		RBMK_MELTDOWN_RAD_RANGE,
		RBMK_MELTDOWN_RAD_THRESHOLD,
		30,
		0,
		RBMK_MAX_RADIATION,
		TRUE
	)
	playsound(src, 'sound/effects/supermatter.ogg', 90, TRUE)


/obj/machinery/rbmk/reactor/proc/meltdown_atmos_release()
	if(!coolant_internal)
		return

	var/datum/gas_mixture/released_mix = coolant_internal.remove_ratio(0.5)
	if(!released_mix || released_mix.total_moles() <= 0)
		return

	var/turf/reactor_turf = get_turf(src)
	if(reactor_turf)
		released_mix.temperature = max(released_mix.temperature, temperature)
		reactor_turf.assume_air(released_mix)


/obj/machinery/rbmk/reactor/proc/meltdown_explosions()
	explosion(
		src,
		RBMK_MELTDOWN_DEV_RANGE,
		RBMK_MELTDOWN_HEAVY_RANGE,
		RBMK_MELTDOWN_LIGHT_RANGE,
		RBMK_MELTDOWN_FLASH_RANGE,
		TRUE
	)

	new /obj/effect/hotspot(loc)
	temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP * 2)


/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
	playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE)
