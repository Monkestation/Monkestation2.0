/datum/supermatter_rod_cascade
	var/obj/item/rbmk/fuel_rod/supermatter/source_rod = null
	var/obj/machinery/rbmk/reactor/reactor = null

	var/started_at = 0
	var/duration = 5 MINUTES
	var/cascade_hold_temperature = 8000

	var/final_countdown_active = FALSE
	var/final_countdown_started_at = 0
	var/final_countdown_duration = 30 SECONDS
	var/last_countdown_announce = null

	var/start_announced = FALSE
	var/two_minute_warning_announced = FALSE
	var/one_minute_security_announced = FALSE

	var/last_psychic_message = 0
	var/psychic_message_interval = 20 SECONDS

	var/atom/movable/warp_effect/warp = null
	var/last_warp_update = 0
	var/warp_update_interval = 1 SECONDS


/datum/supermatter_rod_cascade/New(obj/item/rbmk/fuel_rod/supermatter/new_source_rod, obj/machinery/rbmk/reactor/new_reactor)
	. = ..()

	source_rod = new_source_rod
	reactor = new_reactor

	if(!source_rod || QDELETED(source_rod) || !reactor || QDELETED(reactor))
		qdel(src)
		return

	started_at = world.time

	reactor.supermatter_cascade_active = TRUE
	reactor.supermatter_rod = source_rod

	message_admins("[reactor] has begun an RBMK supermatter rod cascade. [ADMIN_VERBOSEJMP(reactor)]")
	reactor.investigate_log("has begun an RBMK supermatter rod cascade.", INVESTIGATE_ENGINE)

	create_warp()
	announce_start()

	START_PROCESSING(SSobj, src)


/datum/supermatter_rod_cascade/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	cleanup_warp()

	source_rod = null
	reactor = null

	return ..()


/datum/supermatter_rod_cascade/process(seconds_per_tick)
	if(!source_rod || QDELETED(source_rod) || !reactor || QDELETED(reactor))
		qdel(src)
		return

	if(!(source_rod in reactor.special_slots))
		stop(TRUE)
		return

	if(final_countdown_active)
		process_final_countdown(seconds_per_tick)
		return

	process_cascade(seconds_per_tick)


/datum/supermatter_rod_cascade/proc/process_cascade(seconds_per_tick)
	var/elapsed = world.time - started_at
	var/time_left = max(duration - elapsed, 0)
	var/progress = clamp(elapsed / duration, 0, 1)

	if(time_left <= 2 MINUTES)
		announce_two_minute_warning()

	if(time_left <= 1 MINUTE)
		announce_one_minute_security()

	update_warp(progress)
	send_stationwide_feelings()

	reactor.running = TRUE
	reactor.scrammed = FALSE
	reactor.temperature = cascade_hold_temperature
	reactor.thermal_output = 0
	reactor.last_tick_temp_gain = 0

	reactor.update_reactor_integrity()
	reactor.update_reactor_icon()
	reactor.update_linked_consoles()

	if(progress >= 1)
		start_final_countdown()


/datum/supermatter_rod_cascade/proc/start_final_countdown()
	if(final_countdown_active)
		return

	final_countdown_active = TRUE
	final_countdown_started_at = world.time
	last_countdown_announce = null

	message_admins("[reactor] has entered terminal RBMK supermatter cascade countdown. [ADMIN_VERBOSEJMP(reactor)]")
	reactor.investigate_log("entered terminal RBMK supermatter cascade countdown.", INVESTIGATE_ENGINE)

	priority_announce(
		"CRITICAL ALERT: RBMK supermatter resonance has reached terminal instability. Final cascade failure is imminent.",
		"Central Command Emergency Authority",
		'sound/misc/airraid.ogg'
	)


/datum/supermatter_rod_cascade/proc/process_final_countdown(seconds_per_tick)
	var/elapsed = world.time - final_countdown_started_at
	var/time_left = max(final_countdown_duration - elapsed, 0)

	reactor.running = TRUE
	reactor.scrammed = FALSE
	reactor.temperature = cascade_hold_temperature
	reactor.thermal_output = 0
	reactor.last_tick_temp_gain = 0

	update_warp(1)
	send_stationwide_feelings()

	var/seconds_left = CEILING(time_left / 1 SECONDS, 1)
	if(seconds_left <= 10 && seconds_left != last_countdown_announce)
		last_countdown_announce = seconds_left
		priority_announce(
			"[seconds_left]...",
			"Central Command Emergency Authority"
		)

	reactor.update_reactor_integrity()
	reactor.update_reactor_icon()
	reactor.update_linked_consoles()

	if(time_left <= 0)
		trigger_failure()


/datum/supermatter_rod_cascade/proc/announce_start()
	if(start_announced)
		return

	start_announced = TRUE

	priority_announce(
		"Attention: abnormal harmonic flux has been detected inside an RBMK reactor aboard [station_name()]. Engineering personnel are advised to investigate immediately.",
		"Nanotrasen Reactor Monitoring Network",
		'sound/misc/airraid.ogg'
	)


/datum/supermatter_rod_cascade/proc/announce_two_minute_warning()
	if(two_minute_warning_announced)
		return

	two_minute_warning_announced = TRUE

	priority_announce(
		"Central Command warning: the RBMK reactor is undergoing a localized supermatter resonance cascade. Manual intervention is required. Failure to remove the anomalous fuel rod may result in catastrophic reactor failure.",
		"Central Command Engineering Oversight",
		'sound/misc/notice1.ogg'
	)


/datum/supermatter_rod_cascade/proc/announce_one_minute_security()
	if(one_minute_security_announced)
		return

	one_minute_security_announced = TRUE

	priority_announce(
		"Central Command emergency directive: supermatter resonance cascade is approaching terminal instability. All crew are ordered to assist engineering or evacuate the reactor sector. Security is authorized to enforce emergency access and evacuation procedures.",
		"Central Command Emergency Authority",
		'sound/misc/airraid.ogg'
	)

	if(SSsecurity_level.get_current_level_as_number() != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)


/datum/supermatter_rod_cascade/proc/create_warp()
	if(!reactor)
		return

	warp = new(reactor)
	reactor.vis_contents += warp
	warp.alpha = 80
	warp.transform = matrix().Scale(0.5, 0.5)


/datum/supermatter_rod_cascade/proc/update_warp(progress)
	if(!warp)
		return

	if(last_warp_update + warp_update_interval > world.time)
		return

	last_warp_update = world.time

	var/scale = 0.5 + progress * 2.5
	var/alpha = clamp(round(80 + progress * 175), 80, 255)

	animate(
		warp,
		time = warp_update_interval,
		transform = matrix().Scale(scale, scale),
		alpha = alpha
	)


/datum/supermatter_rod_cascade/proc/cleanup_warp()
	if(!warp)
		return

	if(reactor)
		reactor.vis_contents -= warp

	QDEL_NULL(warp)


/datum/supermatter_rod_cascade/proc/send_stationwide_feelings()
	if(last_psychic_message + psychic_message_interval > world.time)
		return

	last_psychic_message = world.time

	var/list/messages = list(
		"Space seems to be shifting around you...",
		"You hear a high-pitched ringing sound.",
		"You feel tingling going down your back.",
		"Something feels very off.",
		"A drowning sense of dread washes over you.",
		"For a moment, the station feels impossibly far away.",
		"You feel like something enormous just noticed you.",
		"The air feels thin, despite your lungs filling normally.",
	)

	for(var/mob/victim as anything in GLOB.player_list)
		if(!victim.client)
			continue
		if(isdead(victim))
			continue

		to_chat(victim, span_danger(pick(messages)))


/datum/supermatter_rod_cascade/proc/stop(successfully_removed = TRUE)
	if(reactor)
		reactor.supermatter_cascade_active = FALSE
		reactor.supermatter_rod = null

		if(successfully_removed)
			reactor.scrammed = TRUE
			reactor.running = FALSE
			reactor.control_rod_depth = RBMK_CONTROL_ROD_MAX

			reactor.visible_message(span_warning("[reactor] automatically SCRAMs as the supermatter rod is removed!"))
			playsound(reactor, 'sound/machines/engine_alert1.ogg', 75, FALSE)

			priority_announce(
				"Central Command notice: RBMK supermatter resonance has been interrupted. Reactor remains thermally unstable. Engineering response is still required.",
				"Central Command Engineering Oversight"
			)

		reactor.update_reactor_icon()
		reactor.update_linked_consoles()

	qdel(src)


/datum/supermatter_rod_cascade/proc/trigger_failure()
	if(!reactor || QDELETED(reactor))
		qdel(src)
		return

	var/turf/cascade_origin = get_turf(reactor)
	if(!cascade_origin)
		qdel(src)
		return

	message_admins("[reactor] completed an RBMK supermatter rod cascade. [ADMIN_VERBOSEJMP(reactor)]")
	reactor.investigate_log("completed an RBMK supermatter rod cascade.", INVESTIGATE_ENGINE)

	reactor.visible_message(span_userdanger("[reactor] erupts in a blinding supermatter resonance cascade!"))

	reactor.trigger_supermatter_rod_meltdown("Supermatter rod cascade resonance failure")

	var/datum/sm_delam/cascade/cascade = new
	INVOKE_ASYNC(cascade, TYPE_PROC_REF(/datum/sm_delam/cascade, rbmk_cascade), cascade_origin)

	qdel(src)
