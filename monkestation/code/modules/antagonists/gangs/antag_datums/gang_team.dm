///Assoc list of all gangs keyed to their tag
GLOBAL_ALIST_EMPTY(all_gangs_by_tag)

/datum/team/gang
	name = "Syndicate Gang"
	///What gang data do we use(what syndicate orginization are we aligned with)
	var/datum/gang_data/our_gang_type = /datum/gang_data
	///Temp for while I decide if I want to use gang_data or not
	var/gang_tag = "Error"
	///Assoc list of uplink handlers for our gang members, keyed to the mind that owns the handler
	var/list/datum/uplink_handler/handlers = list()
	///How much rep does the gang have
	var/rep = 0
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
	///Used for limited stock uplink items
	var/list/shared_team_stock = list(UPLINK_SHARED_STOCK_SURPLUS = 3)
	///Assoc list of member antag datums keyed to their rank
	var/alist/member_datums_by_rank = alist()
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
	name = "[gang_tag] Gang"
	member_name = "[gang_tag] Gang Member"
	setup_objectives()
//	START_PROCESSING(SStraitor, src)

/datum/team/gang/Destroy(force, ...)
//	STOP_PROCESSING(SStraitor, src)
	GLOB.all_gangs_by_tag -= gang_tag
	return ..()

/datum/team/gang/roundend_report()
	var/list/report = list()
	var/used_telecrystals = 0
	var/purchases = ""

	report += "<span class='header'>\The [name]:</span>"
	report += "The [member_name]s were:"
	report += printplayerlist(members)

	if(length(objectives))
		report += "<span class='header'>Team had following objectives:</span>"
		var/win = TRUE
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				win = FALSE
			report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			objective_count++
		report += win ? span_greentext("The [name] was successful!") : span_redtext("The [name] have failed!")

	if(length(completed_objectives))
		var/completed_objectives_text = "Completed Uplink Objectives: "
		for(var/datum/traitor_objective/objective in completed_objectives)
			if(objective.objective_state == OBJECTIVE_STATE_COMPLETED)
				completed_objectives_text += "<br><B>[objective.name]</B> - ([objective.telecrystal_reward] TC, [objective.progression_reward] Reputation)"
		report += completed_objectives_text + "<br>"

	for(var/mind, handler in handlers)
		var/datum/uplink_handler/handler_datum = handler
		var/datum/uplink_purchase_log/log = handler_datum.purchase_log
		if(log)
			used_telecrystals += log.total_spent
			purchases += log.generate_render(show_key = FALSE)
	report += "<br>"
	report += "(Members used [used_telecrystals] TC) [purchases]"
	report += span_big("<br>The gang had a total of [rep] Reputation.")
	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

///Get the uplink handler belonging to the passed mind, and create it if they dont have one
/datum/team/gang/proc/get_specific_handler(datum/mind/owner)
	var/datum/uplink_handler/gang/handler = handlers[owner]
	if(!handler)
		handler = new
		handlers[owner] = handler
		handler.owner = owner
		handler.owning_gang = src
		handler.purchase_log = new
	return handler

///Update the amount of rep local to each of our uplinks and then call their UI update
/datum/team/gang/proc/update_handler_rep()
	for(var/owner, handle in handlers)
		var/datum/uplink_handler/handler = handle
		handler.progression_points = rep
		if(handler.maximum_potential_objectives > length(handler.potential_objectives) + length(handler.active_objectives))
			handler.generate_objectives()
		handler.on_update()

///Update the duplicate objectives for all our handlers
/datum/team/gang/proc/update_duplicate_objectives()
	for(var/owner, handler in handlers)
		astype(handler, /datum/uplink_handler).potential_duplicate_objectives = potential_duplicate_objectives

///Setup our team objectives
/datum/team/gang/proc/setup_objectives()
	add_objective(new /datum/objective/highest_gang_rep())

///Called to make us start tracking an implant
/datum/team/gang/proc/track_implant(obj/item/implant/uplink/gang/tracked_implant)
	if(tracked_implant.tracked_by)
		stack_trace("[src] calling track_implant() on an implant that already has a tracker([tracked_implant.tracked_by])")
	tracked_implant.tracked_by = src
	implants += tracked_implant
	RegisterSignal(tracked_implant, COMSIG_QDELETING, PROC_REF(on_tracked_qdel))
	RegisterSignal(tracked_implant, COMSIG_IMPLANT_IMPLANTED, PROC_REF(on_tracked_implanted))

///Called when we no longer want to track an implant(destroyed or implanted)
/datum/team/gang/proc/stop_tracking_implant(obj/item/implant/uplink/gang/untracked_implant)
	implants -= untracked_implant
	UnregisterSignal(untracked_implant, list(COMSIG_QDELETING, COMSIG_IMPLANT_IMPLANTED))
	if(untracked_implant.tracked_by != src)
		stack_trace("[src] calling stop_tracking_implant() on an implant that is being tracked by a different gang([untracked_implant.tracked_by])")
	else
		untracked_implant.tracked_by = null

/datum/team/gang/proc/track_objective(datum/traitor_objective/tracked_objective)
	RegisterSignal(tracked_objective, COMSIG_TRAITOR_OBJECTIVE_FAILED, PROC_REF(handle_tracked_objective))
	RegisterSignal(tracked_objective, COMSIG_TRAITOR_OBJECTIVE_COMPLETED, PROC_REF(handle_completed_objective))

/datum/team/gang/proc/handle_completed_objective(datum/traitor_objective/tracked_objective)
	SIGNAL_HANDLER
	unallocated_tc += tracked_objective.telecrystal_reward
	rep += tracked_objective.progression_reward
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
