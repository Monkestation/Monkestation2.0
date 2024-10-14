#define SNUFF_LUMCOUNT_LIMIT 0.5

/// Snuffs out any dim lights that enter the field.
/datum/proximity_monitor/advanced/nightmare_snuff
	edge_is_a_field = TRUE

	var/obj/item/light_eater/light_eater

	var/actual_range

	COOLDOWN_DECLARE(message_cooldown)

/datum/proximity_monitor/advanced/nightmare_snuff/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	actual_range = range
	START_PROCESSING(SSprocessing, src)

/datum/proximity_monitor/advanced/nightmare_snuff/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)
	light_eater = null

/datum/proximity_monitor/advanced/nightmare_snuff/set_range(range, force_rebuild)
	. = ..()
	if(.)
		recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/nightmare_snuff/set_host(atom/new_host, atom/new_receiver)
	light_eater = new_host
	. = ..()

/datum/proximity_monitor/advanced/nightmare_snuff/on_moved(atom/movable/movable, atom/old_loc)
	. = ..()
	update_range()

/datum/proximity_monitor/advanced/nightmare_snuff/process(seconds_per_tick)
	update_range()

/datum/proximity_monitor/advanced/nightmare_snuff/proc/update_range()
	var/turf/host_turf = get_turf(host)
	set_range(host_turf.get_lumcount() > SNUFF_LUMCOUNT_LIMIT ? -1 : actual_range)

/datum/proximity_monitor/advanced/nightmare_snuff/setup_field_turf(turf/target)
	. = ..()
	for(var/thing as anything in target.contents)
		start_snuff(thing)
	start_snuff(target)

/datum/proximity_monitor/advanced/nightmare_snuff/cleanup_field_turf(turf/target)
	. = ..()
	for(var/thing as anything in target.contents)
		stop_snuff(thing)
	stop_snuff(target)

/datum/proximity_monitor/advanced/nightmare_snuff/field_turf_crossed(atom/movable/target, turf/old_location, turf/new_location)
	. = ..()
	start_snuff(target)

/datum/proximity_monitor/advanced/nightmare_snuff/field_turf_uncrossed(atom/movable/target, turf/old_location, turf/new_location)
	. = ..()
	stop_snuff(target)

/datum/proximity_monitor/advanced/nightmare_snuff/proc/start_snuff(atom/movable/target)
	stop_snuff(target) // Recursion fucking sucks. -RikuTheKiller debugging this for 3 hours straight
	check_snuff(target)
	RegisterSignals(target, list(COMSIG_ATOM_SET_LIGHT, COMSIG_ATOM_SET_LIGHT_ON, COMSIG_ATOM_SET_LIGHT_POWER, COMSIG_ATOM_SET_LIGHT_COLOR), PROC_REF(check_snuff))

/datum/proximity_monitor/advanced/nightmare_snuff/proc/stop_snuff(atom/movable/target)
	UnregisterSignal(target, list(COMSIG_ATOM_SET_LIGHT, COMSIG_ATOM_SET_LIGHT_ON, COMSIG_ATOM_SET_LIGHT_POWER, COMSIG_ATOM_SET_LIGHT_COLOR))

/datum/proximity_monitor/advanced/nightmare_snuff/proc/on_light_updated(atom/movable/target)
	start_snuff(target)
	SIGNAL_HANDLER

/datum/proximity_monitor/advanced/nightmare_snuff/proc/check_snuff(atom/movable/target)
	SIGNAL_HANDLER

	if(!target.light || !target.light_on)
		return

	if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light_fixture = target
		if(!light_fixture.low_power_mode) // Otherwise the emergency lights caused by tripping a fire alarm get snuffed and we don't want that.
			return

	var/hsl = rgb2num(target.light_color, COLORSPACE_HSL)
	if(target.light_power * (hsl[3] / 100) > 0.8) // The power of the light multiplied by its lightness is a good indicator of its overall brightness.
		return

	for(var/turf/segment as anything in get_line(light_eater, target)) // Naive (AND EXPENSIVE SO PUT THIS LAST) line-of-sight check to avoid outing the nightmare via snuffing lights through walls.
		if(QDELETED(segment))
			continue
		if(isclosedturf(segment) && !istransparentturf(segment))
			return FALSE

	SEND_SIGNAL(light_eater, COMSIG_LIGHT_EATER_EAT, target, light_eater, TRUE) // Silent so we can use our own message.

	var/mob/living/user = light_eater.loc

	if(!istype(user) || !COOLDOWN_FINISHED(src, message_cooldown))
		return

	COOLDOWN_START(src, message_cooldown, 0.5 SECONDS)

	user.visible_message(
		message = span_danger("Something dark in [light_eater] lashes out at nearby lights!"),
		self_message = span_notice("Your [light_eater.name] lashes out at nearby lights!"),
		blind_message = span_danger("You feel a gnawing pulse eat at your sight.")
	)

#undef SNUFF_LUMCOUNT_LIMIT
