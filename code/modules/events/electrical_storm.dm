/datum/round_event_control/electrical_storm
	name = "Electrical Storm"
	typepath = /datum/round_event/electrical_storm
	earliest_start = 45 MINUTES
	min_players = 5
	weight = 5
	max_occurrences = 1
	category = EVENT_CATEGORY_ENGINEERING
	description = "Destroys all lights in a large area."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_SPOOKY)
	event_group = /datum/event_group/error

/datum/round_event/electrical_storm
	var/lightsoutAmount = 1
	var/lightsoutRange = 25
	announce_when = 1

/datum/round_event/electrical_storm/announce(fake)
	priority_announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/round_event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i in 1 to lightsoutAmount)
		var/turf/T = find_safe_turf()
		if(istype(T))
			epicentreList += T

	if(!epicentreList.len)
		return

	for(var/centre in epicentreList)
		for(var/obj/machinery/power/apc/apc as anything in SSmachines.get_machines_by_type(/obj/machinery/power/apc))
			if(get_dist(centre, apc) <= lightsoutRange)
				apc.overload_lighting()
