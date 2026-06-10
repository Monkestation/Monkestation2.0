GLOBAL_LIST_EMPTY(rbmk_fallout_reactors)

/datum/weather/rbmk_fallout
	parent_type = /datum/weather/rad_storm

	name = "reactor fallout"
	desc = "Permanent radioactive fallout from a catastrophic RBMK reactor meltdown."

	telegraph_duration = 0
	telegraph_message = null

	weather_message = "<span class='userdanger'><i>The air burns with reactor fallout! Find shielded shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	// Effectively permanent for the round.
	weather_duration_lower = 9999999
	weather_duration_upper = 9999999

	end_duration = 0
	end_message = null

/datum/weather/rbmk_fallout/weather_act(mob/living/affected_mob)
	if(!rbmk_fallout_should_affect(affected_mob))
		return

	return ..()


/proc/rbmk_fallout_should_affect(mob/living/affected_mob)
	if(!affected_mob)
		return FALSE

	var/turf/mob_turf = get_turf(affected_mob)
	if(!mob_turf)
		return FALSE

	for(var/obj/machinery/rbmk/reactor/reactor as anything in GLOB.rbmk_fallout_reactors)
		if(QDELETED(reactor))
			continue

		if(!reactor.rbmk_fallout_active)
			continue

		var/turf/reactor_turf = get_turf(reactor)
		if(!reactor_turf || reactor_turf.z != mob_turf.z)
			continue

		if(get_dist(reactor_turf, mob_turf) <= reactor.rbmk_fallout_radius)
			return TRUE

	return FALSE
