//these values might need to be tweaked
#define CORE_AREA_MAX_DIST 10
#define CLOSE_AREA_MAX_DIST 30
#define MIDDLE_AREA_MAX_DIST 50
/datum/royale_storm_controller
	///how often do we advance after we start consuming the station
	var/ring_advance_delay = 5 SECONDS
	///how long of a delay after the royale starts do we have until we start consuming the station
	var/start_consuming_delay = -1 //we manually check this value to see if an admin has set it or not
	///assoc list of rings of turfs to consume
	var/list/rings_to_consume = list()
	///timer id to the next ring consumption
	var/timerid
	///assoc list of turfs and their storm effects
	var/list/storms = list()
	///ref to our royale controller
	var/datum/battle_royale_controller/royale_controller
	///list of areas its safe to be in, we have to do this ourselves as station areas is based on Z level
	var/list/safe_areas = list()
	///what ring are we currently consuming
	var/current_ring = 0


/datum/royale_storm_controller/Destroy(force, ...)
	royale_controller = null
	return ..()

///set us up and start us
/datum/royale_storm_controller/proc/setup()
	build_rings()
	calculate_advance_time()
	message_admins("Storm started.")
	send_to_playing_players(span_userdanger("The storm has been created! It will consume the station from the outside in, so plan around it!"))
	var/datum/particle_weather/royale_storm/outside_storm = new
	outside_storm.weather_duration_lower = royale_controller?.max_duration * 2
	outside_storm.weather_duration_upper = royale_controller?.max_duration * 2
	SSparticle_weather.run_weather(outside_storm, TRUE)
	if(start_consuming_delay)
		addtimer(CALLBACK(src, PROC_REF(consume_ring)), start_consuming_delay)
	else
		consume_ring()

///Build our storm rings
/datum/royale_storm_controller/proc/build_rings()
	safe_areas = list()
	for(var/z_level as anything in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/turf/center_turf = locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z_level)
		for(var/turf/consumed_turf as anything in GLOB.station_turfs)
			if(consumed_turf.z != z_level)
				continue
			var/dist = get_dist(center_turf, consumed_turf)
			if(dist < 0)
				continue
			if(dist > current_ring)
				current_ring = dist
			if(!rings_to_consume["[dist]"])
				rings_to_consume["[dist]"] = list()
			rings_to_consume["[dist]"] += consumed_turf
			var/area/turf_area = get_area(consumed_turf)
			if(turf_area && !initial(turf_area.outdoors))
				safe_areas |= turf_area.type

///calculate how long inbetween each consume to get the desired game length
/datum/royale_storm_controller/proc/calculate_advance_time()
	if(!royale_controller?.max_duration)
		message_admins("No set royale_controller[royale_controller ? ".max_duration" : ""] for a royale storm controller.")
		return

	ring_advance_delay = max(truncate((royale_controller.max_duration - start_consuming_delay) / length(rings_to_consume)), 1 SECONDS)

///consume an area with a storm
/datum/royale_storm_controller/proc/consume_ring()
	while(current_ring && !rings_to_consume["[current_ring]"])
		current_ring--

	if(!current_ring)
		return

	for(var/turf/to_consume as anything in rings_to_consume["[current_ring]"])
		var/obj/effect/royale_storm_effect/storm_effect = new(to_consume)
		storms[to_consume] = storm_effect
		royale_controller.spawnable_turfs -= to_consume //might be faster to just do this on the list of turfs instead

	rings_to_consume -= "[current_ring]"
	timerid = addtimer(CALLBACK(src, PROC_REF(consume_ring)), ring_advance_delay, TIMER_STOPPABLE)

///stops the storm.
/datum/royale_storm_controller/proc/stop_storm()
	send_to_playing_players(span_userdanger("The storm has been halted by centcom!"))
	if(timerid)
		deltimer(timerid)
		timerid = null

///ends the storm.
/datum/royale_storm_controller/proc/end_storm()
	for(var/turf/storm_turf in storms)
		var/obj/effect/royale_storm_effect/storm = storms[storm_turf]
		storms -= storm_turf
		qdel(storm)

	SSparticle_weather.stop_weather()

/datum/weather/royale_storm
	name = "royale storm"
	desc = "A sick creation of the most ADHD ridden centcom scientists, used to force stationgoers to fight with the threat of being shredded by an artificial storm for entertainment."

	telegraph_duration = 1 SECONDS
	weather_overlay = "royale"
	perpetual = TRUE

	telegraph_message = null
	weather_message = null
	end_message = null

	target_trait = ZTRAIT_STATION

	immunity_type = "NOTHING KID"

/datum/weather/royale_storm/weather_act(mob/living/living_affected)
	living_affected.adjustFireLoss(5)
	to_chat(living_affected, span_userdanger("You're badly burned by the storm!"))

//for outside
/datum/particle_weather/royale_storm
	name = "Battle Royale Storm"
	display_name = "Battle Royale Storm"
	desc = "A sick creation of the most ADHD ridden centcom scientists, used to force stationgoers to fight with the threat of being shredded by an artificial storm for entertainment."
	particle_effect_type = /particles/weather/rain/storm/royale

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rain)
	weather_messages = list(span_userdanger("You're badly burned by the storm!"))

	damage_type = BURN
	damage_per_tick = 1
	min_severity = 4
	max_severity = 150
	max_severity_change = 50
	severity_steps = 50
	probability = 1

	weather_additional_events = list("thunder" = list(6, /datum/weather_event/thunder), "wind" = list(8, /datum/weather_event/wind))
	weather_warnings = list("siren" = null, "message" = FALSE)
	fire_smothering_strength = 6
	weather_traits = WEATHERTRAIT_NO_IMMUNITIES

/particles/weather/rain/storm/royale
	gradient = list(0,"#4d00ff",1,"#8550ff",2,"#3900bd","loop")
	color_change = generator("num",-5,5)

//actual logic is handled on the antag datum, this does mean that mobs without the datum wont die, however if any players lack the datum it will break things anyway
/obj/effect/royale_storm_effect
	name = "Battle Royale Storm"
	desc = "A storm tuned to only affect those directly participating in the battle royale."
	icon = 'monkestation/icons/effects/effects.dmi'
	icon_state = "royale_storm"
	plane = HIGH_GAME_PLANE

#undef CORE_AREA_MAX_DIST
#undef CLOSE_AREA_MAX_DIST
#undef MIDDLE_AREA_MAX_DIST
