/datum/traitor_objective_category/gang_protect_machine
	name = "Protect Machine(gang)"
	objectives = list(/datum/traitor_objective/gang/protect_machine/telecrystal_beacon = 1,
					/datum/traitor_objective/gang/protect_machine/credit_siphon = 1)

/datum/traitor_objective/gang/protect_machine
	name = "Call down a %MACHINE% in one of %AREAS% and protect it."
	description = "Use the provided beacon to call a %MACHINE% into a valid area and protect it for %TIMER%. \
				When the %MACHINE% is called it will be announced to all gangs, so prepare for a fight. \
				%HANDS%"
	abstract_type = /datum/traitor_objective/gang/protect_machine
	///What areas our machine can be called into
	var/list/valid_areas = list()
	///How many valid areas should we have
	var/valid_area_count = 3
	///The type of machine we create
	var/obj/machinery/gang_machine/created_machine_type
	///The thing we currently have signals registered for, either an object beacon or a machine
	var/obj/registered
	///How long does the machine need to be protected
	var/protect_time = 5 MINUTES
	///Is it ok for the machine to change owners before our protect_time is up
	var/can_change_hands = TRUE
	///Have we sent our beacon yet
	var/beacon_sent = FALSE
	///Used for tracking when our timer will be up
	var/timer_finished_at
	///Should our machine be deleted on activation
	var/del_activated_machine = TRUE
	///The world.time our objective finishes
	var/finish_at = 0

/datum/traitor_objective/gang/protect_machine/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!owner || !get_valid_areas())
		return FALSE

	var/list/names = list()
	for(var/area/picked_area as anything in valid_areas)
		names += initial(picked_area.name)

	replace_in_name("%AREAS%", english_list(names, and_text = " or "))
	replace_in_name("%MACHINE%", "[initial(created_machine_type.name)]")
	replace_in_name("%TIMER%", DisplayTimeText(protect_time))
	replace_in_name("%HANDS%", can_change_hands ? "" : "Ensure control of the machine does not change during this time.")
	return TRUE

/datum/traitor_objective/gang/protect_machine/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!beacon_sent)
		buttons += add_ui_button("", "Pressing this will materialize a machine beacon in your hand.", "globe", "beacon")
	else if(finish_at && finish_at < world.time)
		buttons += add_ui_button("[DisplayTimeText(finish_at - world.time)]", "This tells you how much longer until the machine activates.", "clock", "none")
	return buttons

/datum/traitor_objective/gang/protect_machine/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("beacon")
			if(beacon_sent)
				return
			beacon_sent = TRUE
			var/obj/item/gang_device/object_beacon/gang_machine/beacon = create_beacon(user)
			user.put_in_hands(beacon)
			beacon.balloon_alert(user, "\the [beacon] materializes in your hand")

/datum/traitor_objective/gang/protect_machine/proc/create_beacon(mob/living/user)
	var/obj/item/gang_device/object_beacon/gang_machine/beacon = new(user.drop_location(), created_machine_type, valid_areas)
	RegisterSignal(beacon, COMSIG_GANG_OBJECT_BEACON_ACTIVATED, PROC_REF(beacon_activated))
	RegisterSignal(beacon, COMSIG_QDELETING, PROC_REF(on_tracked_qdeled))
	return beacon

///Get our valid areas list
/datum/traitor_objective/gang/protect_machine/proc/get_valid_areas()
	var/list/station_areas = GLOB.the_station_areas.Copy()
	shuffle_inplace(station_areas)
	for(var/area/area as anything in station_areas)
		if(!(initial(area.area_flags) & VALID_TERRITORY))
			continue

		valid_areas += area
		if(length(valid_areas) >= valid_area_count)
			break
	return length(valid_areas) >= valid_area_count

/datum/traitor_objective/gang/protect_machine/proc/on_tracked_qdeled(obj/destroyed, force)
	SIGNAL_HANDLER
	if(istype(destroyed, /obj/item/gang_device/object_beacon))
		UnregisterSignal(destroyed, COMSIG_GANG_OBJECT_BEACON_ACTIVATED)
	else if(istype(destroyed, /obj/machinery/gang_machine))
		UnregisterSignal(destroyed, list(COMSIG_GANG_MACHINE_ACTIVATED, COMSIG_GANG_MACHINE_CHANGED_OWNER))
	UnregisterSignal(destroyed, COMSIG_QDELETING)
	fail_objective(telecrystal_penalty)

/datum/traitor_objective/gang/protect_machine/proc/beacon_activated(obj/item/gang_device/object_beacon/gang_machine/created_from, obj/machinery/gang_machine/created, turf/location)
	SIGNAL_HANDLER
	UnregisterSignal(created_from, list(COMSIG_GANG_OBJECT_BEACON_ACTIVATED, COMSIG_QDELETING))
	RegisterSignal(created, COMSIG_GANG_MACHINE_ACTIVATED, PROC_REF(machine_activated))
	RegisterSignal(created, COMSIG_QDELETING, PROC_REF(on_tracked_qdeled))
	if(!can_change_hands)
		RegisterSignal(created, COMSIG_GANG_MACHINE_CHANGED_OWNER, PROC_REF(owner_changed))
	mass_gang_message("[created] activated in [get_area(location)].")
	addtimer(CALLBACK(created, TYPE_PROC_REF(/obj/machinery/gang_machine, attempt_activation), del_activated_machine), protect_time)
	finish_at = world.time + protect_time

/datum/traitor_objective/gang/protect_machine/proc/machine_activated(obj/machinery/gang_machine/activated)
	SIGNAL_HANDLER
	UnregisterSignal(activated, list(COMSIG_GANG_MACHINE_ACTIVATED, COMSIG_GANG_MACHINE_CHANGED_OWNER, COMSIG_QDELETING))
	if(activated.get_owner() == owner)
		succeed_objective()
	else
		fail_objective(telecrystal_penalty)

/datum/traitor_objective/gang/protect_machine/proc/owner_changed(obj/machinery/gang_machine/changed)
	SIGNAL_HANDLER
	fail_objective(telecrystal_penalty) //we only register this sig if we care so we can just fail safely
	UnregisterSignal(changed, list(COMSIG_GANG_MACHINE_ACTIVATED, COMSIG_GANG_MACHINE_CHANGED_OWNER, COMSIG_QDELETING))

/datum/traitor_objective/gang/protect_machine/telecrystal_beacon
	progression_reward = list(15, 20)
	telecrystal_reward = list(5, 8) //the TC reward is mostly from the machine
	telecrystal_penalty = 3
	passive_tc_reward = 0
	progression_minimum = 100
	progression_maximum = 500
	created_machine_type = /obj/machinery/gang_machine/telecrystal_beacon

/obj/machinery/gang_machine/telecrystal_beacon
	name = "Telecrystal Beacon"
	desc = "An ominous looking machine."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "core"
	layer = ABOVE_OBJ_LAYER //these should be hard to hide
	///How much passive TC do we give to our owner
	var/given_tc = 1

/obj/machinery/gang_machine/telecrystal_beacon/activate()
	owner.passive_tc += given_tc

/datum/traitor_objective/gang/protect_machine/credit_siphon
	progression_reward = list(5, 10) //machine gives rep
	telecrystal_reward = list(10, 12)
	telecrystal_penalty = 3
	passive_tc_reward = 0.7
	progression_minimum = 300
	progression_maximum = 3000
	created_machine_type = /obj/machinery/gang_machine/credit_converter/siphon
	can_change_hands = FALSE
	del_activated_machine = FALSE
