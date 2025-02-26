///Assoc list of all gangs keyed to their tag
GLOBAL_LIST_EMPTY(all_gangs_by_tag)

/datum/team/gang
	name = "Syndicate Gang"
	///What gang data do we use(what syndicate orginization are we aligned with)
	var/datum/gang_data/our_gang_type = /datum/gang_data
	///Temp for while I decide if I want to use gang_data or not
	var/gang_tag = "Error"
	///Assoc list of uplink handlers for our gang members, keyed to the mind that owns the handler
	var/list/datum/uplink_handler/handlers = list()
	///How much threat does the gang have
	var/threat = 0
	///How much TC does the gang boss have left to allocate
	var/unallocated_tc = 0
	///Static list of all gang tags
	var/static/list/all_gang_tags = list(
		"Omni",
		"Newton",
		"Clandestine",
		"Prima",
		"Zero-G",
		"Osiron",
		"Psyke",
		"Diablo",
		"Blasto",
		"North",
		"Donk",
		"Sleeping Carp",
		"Gene",
		"Cyber",
		"Tunnel",
		"Sirius",
		"Waffle",
		"Max",
		"Gib",
	)
	///Assoc list of member antag datums keyed to their rank
	var/list/member_datums_by_rank = list()
	///List of area types owned by this gang, used to make some checks cheaper
	var/list/claimed_areas = list()
	///List of gang claimed area types that generally cannot change ownership
	var/static/list/permanently_claimed_areas = list()
	///List of all implants that are theoretically owned by us
	var/list/implants = list()
	///Replacement for uplink handlers local version of this var
	var/list/potential_duplicate_objectives = list()
	///The list of objectives our members have completed, used for the round end screen
	var/list/completed_objectives = list()

/datum/team/gang/New(starting_members)
	. = ..()
//	set_gang_info()
	var/list/possible_tags = all_gang_tags - GLOB.all_gangs_by_tag
	if(!length(possible_tags))
		stack_trace("Gang created without possible_tags.")
	else
		gang_tag = pick(possible_tags)

	if(GLOB.all_gangs_by_tag[gang_tag])
		stack_trace("Gang([src]) created with duplicate tag([gang_tag]) to already exsisting gang([GLOB.all_gangs_by_tag[gang_tag]]).")
		message_admins("Gang([src]) created with duplicate tag([gang_tag]) to already exsisting gang([GLOB.all_gangs_by_tag[gang_tag]]), overriding old gang.")
	GLOB.all_gangs_by_tag[gang_tag] = src
	name = "[gang_tag] gang"
	member_name = "[gang_tag] gang member"
	setup_objectives()
//	START_PROCESSING(SStraitor, src)

/datum/team/gang/Destroy(force, ...)
//	STOP_PROCESSING(SStraitor, src)
	GLOB.all_gangs_by_tag -= gang_tag
	return ..()

///datum/team/gang/process(seconds_per_tick)

///Update the amount of threat local to each of our uplinks and then call their UI update
/datum/team/gang/proc/update_handler_threat()
	for(var/datum/uplink_handler/handler as anything in handlers)
		handler = handlers[handler]
		handler.progression_points = threat
		if(handler.maximum_potential_objectives > handler.potential_objectives + handler.active_objectives)
			handler.generate_objectives()
		handler.on_update()

///Update the duplicate objectives for all our handlers
/datum/team/gang/proc/update_duplicate_objectives()
	for(var/datum/uplink_handler/handler as anything in handlers)
		handlers[handler].potential_duplicate_objectives = potential_duplicate_objectives

///Setup our team objectives
/datum/team/gang/proc/setup_objectives()
	add_objective(new /datum/objective/highest_gang_threat())

///Called to make us start tracking an implant
/datum/team/gang/proc/track_implant(obj/item/implant/uplink/gang/tracked_implant)
	implants += tracked_implant
	RegisterSignal(tracked_implant, COMSIG_QDELETING, PROC_REF(on_tracked_qdel))
	RegisterSignal(tracked_implant, COMSIG_IMPLANT_IMPLANTED, PROC_REF(on_tracked_implanted))

///Called when we no longer want to track an implant(destroyed or implanted)
/datum/team/gang/proc/stop_tracking_implant(obj/item/implant/uplink/gang/untracked_implant)
	implants -= untracked_implant
	UnregisterSignal(untracked_implant, list(COMSIG_QDELETING, COMSIG_IMPLANT_IMPLANTED))

/datum/team/gang/proc/track_objective(datum/traitor_objective/tracked_objective)
	RegisterSignal(tracked_objective, COMSIG_TRAITOR_OBJECTIVE_FAILED, PROC_REF(handle_tracked_objective))
	RegisterSignal(tracked_objective, COMSIG_TRAITOR_OBJECTIVE_COMPLETED, PROC_REF(handle_completed_objective))

/datum/team/gang/proc/handle_completed_objective(datum/traitor_objective/tracked_objective)
	SIGNAL_HANDLER
	unallocated_tc += tracked_objective.telecrystal_reward
	threat += tracked_objective.progression_reward
	handle_tracked_objective(tracked_objective)

/datum/team/gang/proc/handle_tracked_objective(datum/traitor_objective/tracked_objective)
	SIGNAL_HANDLER
	UnregisterSignal(tracked_objective, list(COMSIG_TRAITOR_OBJECTIVE_FAILED, COMSIG_TRAITOR_OBJECTIVE_COMPLETED))

/datum/team/gang/proc/on_tracked_qdel(datum/source, force)
	SIGNAL_HANDLER
	stop_tracking_implant(source)

/datum/team/gang/proc/on_tracked_implanted(datum/source, mob/living/target, mob/user, silent, force)
	SIGNAL_HANDLER
	if(IS_IN_GANG(user, src)) //if user is one of our members then we would just be tracking the implant again right away
		return
	stop_tracking_implant(source)

///Take control of an area
/datum/team/gang/proc/take_area(area/taken_area, forced)
	if(!taken_area)
		CRASH("[src] calling take_area() without a passed taken_area.")

	var/datum/team/gang/area_owner = GLOB.gang_controlled_areas[taken_area]
	if(area_owner == src || (area_owner && !area_owner.lose_area(taken_area, forced, area_owner)))
		return FALSE

	SEND_SIGNAL(src, COMSIG_GANG_TOOK_AREA, taken_area)
	GLOB.gang_controlled_areas[taken_area] = src
	claimed_areas += taken_area.type
	return TRUE

///Cause a gang to lose control of an area, passed_owner is for if we have already found the owner of the passed area
/datum/team/gang/proc/lose_area(area/lost_area, forced, passed_owner)
	if(!lost_area)
		CRASH("[src] calling lose_area() without a passed lost_area.")

	var/datum/team/gang/area_owner = passed_owner || GLOB.gang_controlled_areas[lost_area]
	if(area_owner != src || (!forced && (lost_area.type in permanently_claimed_areas)))
		return FALSE

	SEND_SIGNAL(src, COMSIG_GANG_LOST_AREA, lost_area)
	GLOB.gang_controlled_areas -= lost_area
	claimed_areas -= lost_area.type
	return TRUE

///set up all our stuff for our gang_data, if there is already another gang then we wont pick from their blacklisted types for our data. forced_type will just set our data to whats passed
/*/datum/team/gang/proc/set_gang_info(datum/gang_data/forced_type)
	if(forced_type)
		our_gang_type = forced_type
	else
		var/list/blacklisted_types = list()
//		for(var/datum/team/gang/other_gang in GLOB.antagonist_teams)
//			blacklisted_types += other_gang.our_gang_type.blacklisted_enemy_gangs

//		if(length(blacklisted_types) == length(subtypesof(/datum/gang_data)))
//			blacklisted_types = list() //if we somehow get every type blacklisted then just make blacklist_types empty so we pick randomly

		our_gang_type = pick(typesof(/datum/gang_data) - blacklisted_types) //convert this to subtypes

	for(var/datum/mind/gang_member in members)
		var/datum/antagonist/gang_member/member_datum = IS_GANGMEMBER(gang_member)
		member_datum.set_title(our_gang_type)*/
