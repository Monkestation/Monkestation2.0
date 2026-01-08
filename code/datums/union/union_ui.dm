/datum/union/ui_interact(mob/user, datum/tgui/ui, obj/machinery/union_stand/source)
	ui = SStgui.try_update_ui(user, source || src, ui)
	if(!ui)
		ui = new(user, source || src, "UnionStand")
		ui.open()

/datum/union/ui_state(mob/user)
	//this is only used by the admin verb, as the board doesn't pass this.
	return ADMIN_STATE(R_ADMIN)

/datum/union/ui_data(mob/user)
	var/list/data = list()

	data["union_active"] = union_active
	data["admin_mode"] = check_rights_for(user.client, R_ADMIN)
	data["locked_for"] = COOLDOWN_FINISHED(src, union_demand_delay) ? null : DisplayTimeText(COOLDOWN_TIMELEFT(src, union_demand_delay))
	data["deadlocked"] = !isnull(saved_time)
	data["voting_name"] = demand_voting_on?.name || null
	data["voting_desc"] = demand_voting_on?.union_description || null
	if(isnull(implement_delay_timer))
		data["time_until_implementation"] = null
	else
		data["time_until_implementation"] = DisplayTimeText(timeleft(implement_delay_timer), 1)
	data["votes_yes"] = length(votes_yes)
	data["votes_no"] = length(votes_no)
	if(voting_timer)
		data["voting"] = TRUE
		data["voting_time_left"] = DisplayTimeText(timeleft(voting_timer), 1)
	else
		data["voting"] = FALSE

	//list of all demands, only used in times of non-voting.
	data["possible_demands"] = list()
	for(var/datum/union_demand/demands as anything in possible_demands)
		data["possible_demands"] += list(list(
			"name" = demands.name,
			"desc" = demands.union_description,
			"cost" = demands.cost,
			"ref" = REF(demands),
		))
	//list of completed demands
	data["completed_demands"] = list()
	for(var/datum/union_demand/demands as anything in successful_demands)
		data["completed_demands"] += list(list(
			"name" = demands.name,
			"desc" = demands.union_description,
			"cost" = demands.cost,
			"ref" = REF(demands),
		))

	return data

#define ANNOUNCE_FREEZE "Announce"
#define SILENT_FREEZE "Silent"
#define BUST_IMPLEMENTATION "Bust Implementation"

/datum/union/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .
	var/mob/user = ui.user
	var/obj/machinery/host = ui.src_object
	if(istype(host) && !host.allowed(user))
		host.balloon_alert(user, "no access!")
		return TRUE
	if(!union_active && !check_rights_for(user.client, R_ADMIN))
		host.balloon_alert(user, "union not active!")
		return TRUE
	switch(action)
		if("trigger_vote")
			var/datum/union_demand/vote_for = locate(params["selected_demand"]) in possible_demands
			if(isnull(vote_for))
				return TRUE
			if(!COOLDOWN_FINISHED(src, union_demand_delay))
				host.balloon_alert(user, "on cooldown for [DisplayTimeText(COOLDOWN_TIMELEFT(src, union_demand_delay))]!")
				return TRUE
			if(demand_voting_on)
				host.balloon_alert(user, "still implementing [demand_voting_on.name]!")
				return TRUE
			trigger_vote(vote_for)
			return TRUE
		if("vote_yes")
			if(isnull(demand_voting_on))
				return TRUE
			if(user in votes_yes)
				host.balloon_alert(user, "already voted!")
				return TRUE
			if(user in votes_no)
				votes_no -= user
			votes_yes += user
			return TRUE
		if("vote_no")
			if(isnull(demand_voting_on))
				return TRUE
			if(user in votes_no)
				host.balloon_alert(user, "already voted!")
				return TRUE
			if(user in votes_yes)
				votes_yes -= user
			votes_no += user
			return TRUE
		if("abandon_demand")
			if(isnull(demand_voting_on))
				return
			//this is so bad but I can't figure out any better way.
			if(istype(host))
				host.req_one_access = list(ACCESS_UNION_LEADER)
				if(istype(host) && !host.allowed(user))
					host.req_one_access = initial(host.req_one_access)
					host.balloon_alert(user, "union leader only!")
					return TRUE
				host.req_one_access = initial(host.req_one_access)
			end_deadlock(union_won = FALSE)
		//admin buttons
		if("remove_demand")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			var/datum/union_demand/removed_demand = locate(params["selected_demand"]) in successful_demands
			if(isnull(removed_demand))
				return TRUE
			unimplement_demand(removed_demand)
			return TRUE
		if("reset_cooldown")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			COOLDOWN_RESET(src, union_demand_delay)
			return TRUE
		if("toggle_union")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			union_active = !union_active
			return TRUE
		if("end_vote")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			stop_vote()
			return TRUE
		if("reset_union")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			QDEL_NULL(GLOB.cargo_union.possible_demands)
			for(var/datum/union_demand/demand as anything in GLOB.cargo_union.successful_demands)
				demand.unimplement_demand(GLOB.cargo_union)
			QDEL_NULL(GLOB.cargo_union.successful_demands)
			GLOB.cargo_union.setup_demands()
			return TRUE
		if("freeze_timers")
			if(!check_rights_for(user.client, R_ADMIN))
				return TRUE
			var/list/choices = list(ANNOUNCE_FREEZE, SILENT_FREEZE, BUST_IMPLEMENTATION)
			var/choice = tgui_input_list(user, "Announce to the Union that implementation timer has been frozen? (this will give the same message as if Command did it)", "Freeze Timers", choices)
			if(isnull(choice))
				return TRUE
			switch(choice)
				if(ANNOUNCE_FREEZE)
					if(saved_time)
						end_deadlock(union_won = TRUE)
					else
						if(isnull(implement_delay_timer))
							return TRUE
						start_deadlock()
				if(SILENT_FREEZE)
					if(saved_time)
						unfreeze_time()
					else
						if(isnull(implement_delay_timer))
							return TRUE
						freeze_time()
				if(BUST_IMPLEMENTATION)
					if(isnull(demand_voting_on))
						return
					end_deadlock(union_won = FALSE)
			return TRUE

#undef ANNOUNCE_FREEZE
#undef SILENT_FREEZE
#undef BUST_IMPLEMENTATION
