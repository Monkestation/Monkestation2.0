/** Checks whether residual heat should start a post-shutdown meltdown. */
/obj/machinery/rbmk/reactor/proc/check_decay_meltdown()
	if(meltdown_in_progress || running)
		return
	if(!COOLDOWN_FINISHED(src, decay_meltdown_check_cooldown))
		return
	COOLDOWN_START(src, decay_meltdown_check_cooldown, decay_check_interval)
	if(temperature >= get_effective_temp_damage_threshold())
		trigger_meltdown("Post-SCRAM decay heat runaway")

/** Starts a normal RBMK meltdown. */
/obj/machinery/rbmk/reactor/proc/trigger_meltdown(reason)
	if(meltdown_in_progress)
		return
	begin_meltdown_sequence(reason)

/** Starts the failure path used by a supermatter rod cascade. */
/obj/machinery/rbmk/reactor/proc/trigger_supermatter_rod_meltdown(reason)
	if(meltdown_in_progress)
		return
	begin_meltdown_sequence(reason, TRUE)

/** Commits the reactor to failure and schedules the vessel breach. */
/obj/machinery/rbmk/reactor/proc/begin_meltdown_sequence(reason, supermatter_failure = FALSE)
	meltdown_in_progress = TRUE
	meltdown_exploded = FALSE
	meltdown_supermatter_failure = supermatter_failure
	scrammed = TRUE
	running = FALSE
	control_rod_depth = RBMK_CONTROL_ROD_MAX
	reset_reaction_state()
	reactor_integrity = 0
	var/alert_reason = supermatter_failure ? "SUPERMATTER CASCADE FAILURE: [reason]" : reason
	world << span_userdanger("[RBMK_MELTDOWN_PREFIX]: [alert_reason]!")
	rbmk_engineering_alert("CRITICAL ALERT: RBMK reactor containment failure at [get_area_name(src)]. Core integrity has reached zero. Evacuate the reactor chamber immediately.")
	// Keep the pre-explosion warning local only.
	// The stationwide air raid is reserved for the confirmed vessel breach and fallout countdown.
	meltdown_area_alarms()
	cut_overlays()
	current_damage_stage = 4
	update_appearance(UPDATE_ICON)
	update_linked_consoles()
	addtimer(CALLBACK(src, PROC_REF(complete_meltdown_sequence), alert_reason), RBMK_MELTDOWN_WARNING_DELAY, TIMER_UNIQUE)
	log_game("[src] MELTDOWN sequence started: [alert_reason]")

/** Breaches the vessel and schedules the secondary meltdown effects. */
/obj/machinery/rbmk/reactor/proc/complete_meltdown_sequence(reason)
	if(QDELETED(src) || meltdown_exploded)
		return
	meltdown_exploded = TRUE
	cut_overlays()
	current_damage_stage = 4
	update_appearance(UPDATE_ICON | UPDATE_DESC)
	temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP)
	flux = 0
	radiation = RBMK_MAX_RADIATION
	if(meltdown_supermatter_failure)
		temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP * 2)
		flux = RBMK_MAX_FLUX
	thermal_output = 0
	void_coefficient = 0
	activate_slagged_core_radiation()
	launch_reactor_lid()
	if(meltdown_supermatter_failure)
		priority_announce(
			"RBMK supermatter containment vessel failure confirmed. Spatial cascade effects are developing around the reactor sector.",
			"RBMK Reactor Breach",
			'sound/misc/airraid.ogg',
		)
		rbmk_engineering_alert("RBMK supermatter containment vessel failure confirmed. Spatial cascade effects are developing around the reactor sector.")
	else
		priority_announce(
			"RBMK reactor containment vessel failure confirmed. Radioactive fallout will reach exposed station areas in approximately one minute. Maintenance remains the safest shelter.",
			"RBMK Reactor Breach",
			'sound/misc/airraid.ogg',
		)
		rbmk_engineering_alert("RBMK containment vessel failure confirmed. Fallout will reach exposed station areas in T-1 minute.")
	if(!meltdown_supermatter_failure)
		addtimer(CALLBACK(src, PROC_REF(meltdown_radiation_pulse)), RBMK_MELTDOWN_EFFECT_STAGGER)
	addtimer(CALLBACK(src, PROC_REF(meltdown_atmos_release)), RBMK_MELTDOWN_EFFECT_STAGGER * 2)
	addtimer(CALLBACK(src, PROC_REF(meltdown_explosions)), RBMK_MELTDOWN_EFFECT_STAGGER * 3)
	addtimer(CALLBACK(src, PROC_REF(meltdown_floor_damage)), RBMK_MELTDOWN_EFFECT_STAGGER * 4)
	if(!meltdown_supermatter_failure)
		addtimer(CALLBACK(src, PROC_REF(begin_delayed_meltdown_fallout)), RBMK_MELTDOWN_FALLOUT_DELAY, TIMER_UNIQUE)
	update_linked_consoles()
	log_game("[src] MELTDOWN explosion triggered: [reason]")

/** Routes a reactor alert through the nearest linked console. */
/obj/machinery/rbmk/reactor/proc/rbmk_engineering_alert(message)
	if(!message)
		return
	var/obj/machinery/computer/rbmk_console/alert_console = get_primary_console()
	alert_console?.send_engineering_alert(message)

/** Emits the initial radiation pulse from an ordinary meltdown. */
/obj/machinery/rbmk/reactor/proc/meltdown_radiation_pulse()
	radiation_pulse(
		src,
		RBMK_MELTDOWN_RAD_RANGE,
		RBMK_MELTDOWN_RAD_THRESHOLD,
		30,
		0,
		RBMK_MAX_RADIATION,
		TRUE,
	)
	playsound(src, 'sound/rbmk/meltdown.ogg', 90, TRUE)

/**
 * Keeps the slagged core dangerously radioactive after its fallout clears.
 */
/obj/machinery/rbmk/reactor/proc/activate_slagged_core_radiation()
	return AddComponent(
		/datum/component/radioactive_emitter, \
		cooldown_time = RBMK_SLAGGED_CORE_RAD_PULSE_INTERVAL, \
		range = RBMK_SLAGGED_CORE_RAD_RANGE, \
		threshold = RBMK_SLAGGED_CORE_RAD_THRESHOLD, \
		examine_text = span_boldwarning("The slagged core is emitting lethal levels of ionizing radiation."), \
	)

/** Releases part of the hot coolant inventory onto the reactor tile. */
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

/** Produces the physical explosion caused by the vessel breach. */
/obj/machinery/rbmk/reactor/proc/meltdown_explosions()
	var/turf/epicenter = get_turf(src)
	if(!epicenter)
		return
	explosion(
		epicenter,
		RBMK_MELTDOWN_DEV_RANGE,
		RBMK_MELTDOWN_HEAVY_RANGE,
		RBMK_MELTDOWN_LIGHT_RANGE,
		RBMK_MELTDOWN_FLASH_RANGE,
		TRUE,
	)
	new /obj/effect/hotspot(epicenter)
	temperature = max(temperature, RBMK_TEMP_DAMAGE_RAMP * 2)

/** Plays the reactor-room meltdown alarm. */
/obj/machinery/rbmk/reactor/proc/meltdown_area_alarms()
	playsound(src, 'sound/rbmk/alarm.ogg', 100, FALSE)

/** Damages station floors around the breached vessel. */
/obj/machinery/rbmk/reactor/proc/meltdown_floor_damage()
	var/turf/epicenter = get_turf(src)
	if(!epicenter)
		return
	for(var/turf/open/floor/damaged_floor in RANGE_TURFS(RBMK_MELTDOWN_FLOOR_DAMAGE_RANGE, epicenter))
		var/distance_from_core = max(get_dist(epicenter, damaged_floor), 1)
		var/space_chance = max(RBMK_MELTDOWN_FLOOR_SPACE_CHANCE - (distance_from_core * 8), 5)
		if(prob(space_chance))
			damaged_floor.ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		CHECK_TICK

/** Starts station fallout after the post-breach delay. */
/obj/machinery/rbmk/reactor/proc/begin_delayed_meltdown_fallout()
	if(QDELETED(src))
		return
	priority_announce(
		"RBMK fallout has spread across the station. Maintenance tunnels and radiation shelters remain shielded; exposed areas are unsafe.",
		"RBMK Fallout Warning",
		ANNOUNCER_RADIATION,
	)
	rbmk_engineering_alert("RBMK fallout is contaminating exposed station areas. Maintenance remains shielded.")
	if(!(locate(/datum/weather/rbmk_fallout) in SSweather.processing))
		SSweather.run_weather(/datum/weather/rbmk_fallout)

/** Launches the containment lid toward a safe station hallway. */
/obj/machinery/rbmk/reactor/proc/launch_reactor_lid()
	var/turf/reactor_turf = get_turf(src)
	var/turf/target_turf = get_rbmk_lid_landing_turf()
	if(!reactor_turf || !target_turf)
		return
	var/obj/structure/closet/supplypod/rbmk_reactor_lid/lid = new()
	visible_message(span_userdanger("[src]'s Containment lid is violently torn free from reactor core!"))
	new /obj/effect/pod_landingzone(target_turf, lid)

/** Finds a valid station tile for the launched containment lid. */
/obj/machinery/rbmk/reactor/proc/get_rbmk_lid_landing_turf()
	var/list/hallway_areas = list()
	for(var/area_type in GLOB.the_station_areas)
		if(ispath(area_type, /area/station/hallway))
			hallway_areas += area_type
	if(length(hallway_areas))
		var/turf/hallway_turf = get_safe_random_station_turf(hallway_areas)
		if(hallway_turf)
			return hallway_turf
	return get_safe_random_station_turf()

/// Reinforced reactor lid launched as a destructive supply-pod payload during meltdown.
/obj/structure/closet/supplypod/rbmk_reactor_lid
	name = "RBMK Reactor Lid"
	desc = "An impossibly heavy reactor containment lid. It should not be here."
	icon = 'icons/obj/machines/rbmk_lid.dmi'
	icon_state = "oh shit"
	anchored = TRUE
	density = TRUE
	opened = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	layer = ABOVE_OBJ_LAYER
	bound_width = 48
	bound_height = 71
	bound_x = -7
	bound_y = -24
	pixel_x = -32
	pixel_y = -32
	style = STYLE_CAR
	specialised = TRUE
	rubble_type = RUBBLE_THIN
	effectGib = TRUE
	effectCircle = TRUE
	damage = 500
	explosionSize = list(0, 1, 2, 3)
	delays = list(POD_TRANSIT = 1.5 SECONDS, POD_FALLING = 0.5 SECONDS, POD_OPENING = 0, POD_LEAVING = 0)
	fallingSoundLength = 1 SECONDS
	landingSound = 'sound/rbmk/explode.ogg'
	soundVolume = 100
	decal = null
	door = null
	fin_mask = null

/obj/structure/closet/supplypod/rbmk_reactor_lid/Initialize(mapload, customStyle = FALSE)
	. = ..()
	reset_lid_appearance()

/** Suppresses supply-pod overlays that do not fit the lid sprite. */
/obj/structure/closet/supplypod/rbmk_reactor_lid/update_overlays()
	. = ..()
	return list()

/obj/structure/closet/supplypod/rbmk_reactor_lid/preOpen()
	. = ..()
	reset_lid_appearance(TRUE)
	visible_message(span_userdanger("[src] crashes down and embeds itself into the floor!"))

/obj/structure/closet/supplypod/rbmk_reactor_lid/setOpened()
	opened = TRUE
	set_density(TRUE)
	reset_lid_appearance(TRUE)

/obj/structure/closet/supplypod/rbmk_reactor_lid/setClosed()
	opened = TRUE
	set_density(TRUE)
	reset_lid_appearance(TRUE)

/** Restores the lid's custom appearance after a supply-pod state change. */
/obj/structure/closet/supplypod/rbmk_reactor_lid/proc/reset_lid_appearance(landed = FALSE)
	icon = 'icons/obj/machines/rbmk_lid.dmi'
	icon_state = "oh shit"
	rubble_type = RUBBLE_THIN
	decal = null
	door = null
	fin_mask = null
	alpha = 255
	bound_width = initial(bound_width)
	bound_height = initial(bound_height)
	bound_x = initial(bound_x)
	bound_y = initial(bound_y)
	mouse_opacity = initial(mouse_opacity)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	pixel_z = initial(pixel_z)
	transform = matrix()
	set_density(TRUE)
	update_appearance()
