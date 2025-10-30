/*************************************************************
 * RBMK Meltdown Logic (Enhanced)
 * - Handles meltdown events, decay-based instability, and logging
 *************************************************************/

/// Extends RBMK reactor with decay-related meltdown simulation.
/obj/machinery/rbmk/reactor
	var/meltdown_announced = FALSE
	var/meltdown_in_progress = FALSE
	var/decay_meltdown_threshold = RBMK_MAX_TEMP * 0.85 // triggers meltdown if exceeded post-SCRAM
	var/decay_instability_rate = 0.25                   // rate at which decay heat adds instability
	var/decay_check_interval = 2 SECONDS                // how often we tick decay meltdown check
	var/last_decay_check = 0

/*************************************************************
 * Decay Heat-Driven Meltdown Risk
 *************************************************************/

/// Runs during decay mode to check if heat buildup causes secondary meltdown.
/obj/machinery/rbmk/reactor/proc/check_decay_meltdown()
	if(running || meltdown_in_progress)
		return

	if(world.time < last_decay_check + decay_check_interval)
		return
	last_decay_check = world.time

	// --- Accumulate instability based on remaining decay heat ---
	if(decay_heat > 0)
		instability += decay_heat * decay_instability_rate

	// --- Trigger meltdown if core temp or instability passes threshold ---
	if(temperature >= decay_meltdown_threshold || instability >= RBMK_INSTABILITY_CRITICAL)
		trigger_meltdown("Post-SCRAM decay heat runaway")

/*************************************************************
 * Trigger Meltdown
 *************************************************************/

/// Called when the reactor exceeds safe thresholds and collapses
/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
	if(meltdown_in_progress)
		return

	meltdown_in_progress = TRUE

	if(!meltdown_announced)
		meltdown_announced = TRUE
		// --- Global announcement ---
		world << span_danger("[RBMK_MELTDOWN_PREFIX]: [reason]!")
		priority_announce("[RBMK_MELTDOWN_BROADCAST] [reason]", "RBMK Reactor Alert")

	// --- Visual & state change ---
	icon_state = "reactor_slagged"
	cut_overlays()
	add_integrity_overlay()
	scrammed = TRUE
	running = FALSE

	/*************************************************************
	 * Meltdown Effects
	 *************************************************************/
	#ifdef RBMK_MELTDOWN_RADIATION
	meltdown_radiation_pulse()
	#endif

	#ifdef RBMK_MELTDOWN_ATMOS_DUMP
	meltdown_atmos_release()
	#endif

	#ifdef RBMK_MELTDOWN_EXPLOSIONS
	meltdown_explosions()
	#endif

	#ifdef RBMK_MELTDOWN_ALARMS
	meltdown_area_alarms()
	#endif

	// --- Final sync & logging ---
	update_linked_consoles()
	log_game("[src] has entered meltdown due to: [reason]")

	// --- Cleanup simulation ---
	decay_heat = 0
	instability = RBMK_INSTABILITY_CRITICAL
	STOP_PROCESSING(SSmachines, src)

/*************************************************************
 * Radiation Pulse
 *************************************************************/

/// Emits a large burst of radiation around the reactor
/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
	radiation_pulse(loc, RBMK_MELTDOWN_RAD_RANGE, RBMK_MELTDOWN_RAD_THRESHOLD)
	playsound(src, 'sound/effects/supermatter.ogg', 90, TRUE)

/*************************************************************
 * Atmos Release
 *************************************************************/

/// Releases stored coolant gases into the atmosphere
/obj/machinery/rbmk/reactor/proc/meltdown_atmos_release()
	if(!coolant_internal)
		return

	var/datum/gas_mixture/released_gas = coolant_internal.remove_ratio(0.5)
	if(released_gas && released_gas.total_moles() > 0)
		var/turf/reactor_turf = get_turf(src)
		if(reactor_turf)
			reactor_turf.assume_air(released_gas)

/*************************************************************
 * Explosions
 *************************************************************/

/// Triggers chain explosions based on meltdown severity
/obj/machinery/rbmk/reactor/proc/meltdown_explosions()
	// Core explosion + cascading pressure spikes
	explosion(src, RBMK_MELTDOWN_DEV_RANGE, RBMK_MELTDOWN_HEAVY_RANGE, RBMK_MELTDOWN_LIGHT_RANGE, RBMK_MELTDOWN_FLASH_RANGE, TRUE)
	// Secondary thermal flare
	new /obj/effect/hotspot(loc)
	temperature = RBMK_MAX_TEMP * 2

/*************************************************************
 * Alarms & Audio Feedback
 *************************************************************/

/// Plays alert sirens after meltdown
/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
	playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE)
