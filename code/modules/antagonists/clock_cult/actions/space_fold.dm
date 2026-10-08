///list of events eminence can trigger as well as their cost in cogs, most likely gonna have to set limits on these, might do it based on cost, unsure if I should use a .txt for this
#define EMINENCE_EVENTS list( \
	/datum/round_event_control/brand_intelligence = 5, \
	/datum/round_event_control/bureaucratic_error = 3, \
	/datum/round_event_control/gravity_generator_blackout = 4, \
	/datum/round_event_control/communications_blackout = 6, \
	/datum/round_event_control/electrical_storm = 2, \
	/datum/round_event_control/ion_storm = 6, \
	/datum/round_event_control/grey_tide = 3, \
	/datum/round_event_control/grid_check = 6, \
	/datum/round_event_control/scrubber_overflow/catastrophic = 4, \
	/datum/round_event_control/radiation_storm = 8, \
	/datum/round_event_control/scrubber_clog/critical = 3, \
	/datum/round_event_control/carp_migration = 6, \
	/datum/round_event_control/wormholes = 6, \
	/datum/round_event_control/immovable_rod = 9, \
	/datum/round_event_control/anomaly/anomaly_dimensional = 2, \
	/datum/round_event_control/anomaly/anomaly_bluespace = 4, \
	/datum/round_event_control/anomaly/anomaly_ectoplasm = 4, \
	/datum/round_event_control/anomaly/anomaly_flux = 3, \
	/datum/round_event_control/anomaly/anomaly_pyro = 5, \
)

/datum/action/innate/clockcult/space_fold
	name = "Space Fold"
	button_icon_state = "Geis"
	desc = "Fold local space so that certain \"events\" befall the station. The amount you may create depends on how many APCs the cult has cogged. \
			Doing so will also cost charges which will regenerate at a rate of one per minute."
	///list used for tracking what events have been trigged so far, also used for restricting how many times an event can trigger
	var/list/used_event_list = list()
	///instead of a cooldown this has a charge system, one charge regenerates every mintue, each event costs charges equal to its cog cost
	var/charges = 10
	///the static list of events we have access to
	var/static/list/event_list
	///cooldown declare for charge cooldown
	COOLDOWN_DECLARE(charge_cooldown)

/datum/action/innate/clockcult/space_fold/New(Target)
	. = ..()
	if(isnull(event_list))
		event_list = list()
		var/list/temp = EMINENCE_EVENTS
		for(var/datum/round_event_control/entry as anything in SSevents.control)
			if(entry.type in temp)
				event_list[entry] = temp[entry.type]

/datum/action/innate/clockcult/space_fold/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, charge_cooldown, 1 SECONDS)

/datum/action/innate/clockcult/space_fold/Destroy()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/datum/action/innate/clockcult/space_fold/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, charge_cooldown))
		charges++
		COOLDOWN_START(src, charge_cooldown, 1 MINUTES)

	if(charges >= initial(charges))
		STOP_PROCESSING(SSfastprocess, src)
		return

/datum/action/innate/clockcult/space_fold/Activate()
	var/datum/round_event_control/chosen_event = tgui_input_list(usr, "Choose an event", "[charges] [charges == 1 ? "charge" : "charges"] remaining", event_list)
	if(isnull(chosen_event) || isnull(event_list[chosen_event]))
		return FALSE

	if(used_event_list[chosen_event] && (event_list[chosen_event] >= 4 || used_event_list[chosen_event] >= 4)) //events with 4+ cost can be used once, 3 and below can be used 4 times
		to_chat(usr, span_warning("You have summoned this event too many times to do so again!"))
		return FALSE

	switch(tgui_alert(usr, "Are you sure you want to summon this event? It will cost [event_list[chosen_event]] cogs.", "Confirm summon", list("Yes", "No")))
		if("No")
			return FALSE
		if("Yes")
			var/actual_cost = event_list[chosen_event]
			if(GLOB.clock_ark && GLOB.clock_ark.current_state >= ARK_STATE_CHARGING)
				actual_cost *= 2 //events cost double after ark activation
			if(charges < actual_cost)
				to_chat(usr, span_warning("You dont have enough charges to summon this event"))
				return FALSE
			if(istype(usr, /mob/living/eminence)) //if you somehow get this as non-eminence its technically free besides charges
				var/mob/living/eminence/em_user = usr
				if(em_user.cogs < actual_cost)
					to_chat(em_user, span_warning("You dont have enough cogs to do this!"))
					return
				em_user.cogs -= actual_cost
			chosen_event.run_event(event_cause = "an emience folding spacetime")
			charges -= actual_cost
			if(charges + event_list[chosen_event] >= initial(charges)) //if charges was full then start processing
				START_PROCESSING(SSfastprocess, src)
				COOLDOWN_START(src, charge_cooldown, 1 MINUTES)
			used_event_list[chosen_event] = used_event_list[chosen_event] + 1
			return TRUE
	return FALSE

#undef EMINENCE_EVENTS
