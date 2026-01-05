ADMIN_VERB(union_manager, R_ADMIN, FALSE, "Cargo Union Manager", "View the Cargo Union panel.", ADMIN_CATEGORY_GAME)
	GLOB.cargo_union.ui_interact(user.mob)

#define TIME_BETWEEN_DEMANDS (10 MINUTES)
#define TIME_TO_VOTE (TIME_BETWEEN_DEMANDS / 4)
///The time Command has to stop a demand.
#define COMMAND_DELAY (3 MINUTES)

/datum/union
	///Name of the Union.
	var/name = "Cargo Union"
	///The budget the Union has control over, and pays their staff with.
	var/union_budget = ACCOUNT_CAR
	///The radio channel to announce union-wide stuff.
	var/radio_channel_used = RADIO_CHANNEL_SUPPLY

	///Assoc List of people part of the Cargo Union, by default all Cargo personnel but the QM can add more.
	///stored as: list(CARGO_UNION_LEADER = boolean, CARGO_UNION_NAME = string, CARGO_UNION_BANK, /datum/bank_account)
	var/list/union_employees = list()

	///List of all demands this Union can make.
	var/list/datum/union_demand/possible_demands = list()
	///List of all demands this Union has successfully done.
	var/list/datum/union_demand/successful_demands = list()

	///Delay between union demand votings.
	COOLDOWN_DECLARE(union_demand_delay)
	///Stored time left to end the vote, different from delay of demanding union stuff.
	var/voting_timer
	///Stored time left until the successful demand goes into effect, this is the time Command has to react.
	var/implement_delay_timer
	///Amount of people that have voted yes for the current demand, resets between uses.
	var/list/votes_yes = list()
	///Amount of people that have voted no for the current demand, resets between uses.
	var/list/votes_no = list()
	///The demand the union is currently voting on.
	var/datum/union_demand/demand_voting_on

/datum/union/New()
	. = ..()
	RegisterSignal(SSeconomy, COMSIG_PAYDAYS_ISSUED, PROC_REF(handle_payday))
	for(var/datum/union_demand/demands as anything in subtypesof(/datum/union_demand))
		if(demands::department_eligible != union_budget)
			continue
		possible_demands |= new demands()

/datum/union/Destroy(force)
	deltimer(voting_timer)
	voting_timer = null
	deltimer(implement_delay_timer)
	implement_delay_timer = null
	QDEL_LIST(possible_demands)
	QDEL_LIST(successful_demands)
	union_employees.Cut()
	demand_voting_on = null
	return ..()

///Called when paydays are issued, Union personnel will also get paid by their Union.
///We also take the cost of any enacted demand here, from both the Union and Command.
/datum/union/proc/handle_payday()
	for(var/member in GLOB.cargo_union.union_employees)
		var/datum/bank_account/bank_account = member[CARGO_UNION_BANK]
		if(isnull(bank_account))
			continue
		bank_account.payday(1, skippable = TRUE, event = "Union pay", budget_used = union_budget)

	var/datum/bank_account/union_account = SSeconomy.get_dep_account(union_budget)
	var/datum/bank_account/command_account = SSeconomy.get_dep_account(ACCOUNT_CMD)
	for(var/datum/union_demand/demand_cost as anything in successful_demands)
		union_account.adjust_money(-demand_cost.cost)
		command_account.adjust_money(-demand_cost.cost)

///Returns how many people are part of the Union.
/datum/union/proc/get_union_count()
	return length(union_employees)

///Called when a demand is succesfully voted to go into effect.
/datum/union/proc/on_demand_success()
	if(!(demand_voting_on in possible_demands))
		stack_trace("[name] just tried to enact [demand_voting_on.name], but it's not in their list of possible demands!")
		return FALSE
	COOLDOWN_START(src, union_demand_delay, TIME_BETWEEN_DEMANDS)
	make_union_announcement(demand_voting_on, announce_mode = ANNOUNCE_CREW)
	possible_demands -= demand_voting_on
	implement_delay_timer = addtimer(CALLBACK(src, PROC_REF(implement_demand)), COMMAND_DELAY, TIMER_STOPPABLE)

///Called after the delay to implement a demand, if Command did nothing to stop it, putting it into effect and taking cost.
/datum/union/proc/implement_demand()
	make_union_announcement(demand_voting_on, announce_mode = ANNOUNCE_INTO_EFFECT)
	successful_demands += demand_voting_on
	demand_voting_on.implement_demand(src)
	demand_voting_on = null

///Called when a demand fails to get voted on to go into effect.
/datum/union/proc/on_demand_failure()
	make_union_announcement(demand_voting_on, announce_mode = ANNOUNCE_FAILURE)

///Depending on announce_mode, we will announce to the Union or Crew the several stages of a Union Demand.
/datum/union/proc/make_union_announcement(announce_mode)
	switch(announce_mode)
		if(ANNOUNCE_START_VOTE)
			var/obj/machinery/announcement_system/system_announcement = pick(GLOB.announcement_systems)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "A vote for [demand_voting_on.name] has started. Please remember check the Union board to vote!", channels = list(radio_channel_used))
		if(ANNOUNCE_CREW)
			priority_announce(
				text = demand_voting_on.station_description,
				title = name,
				has_important_message = TRUE,
			)
		if(ANNOUNCE_INTO_EFFECT)
			var/obj/machinery/announcement_system/system_announcement = pick(GLOB.announcement_systems)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] is now in full effect.", channels = list(radio_channel_used))
		if(ANNOUNCE_DEADLOCK)
			var/obj/machinery/announcement_system/system_announcement = pick(GLOB.announcement_systems)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] is under deadlock. Please speak with Command on how proceedings may go.", channels = list(radio_channel_used))
		if(ANNOUNCE_FAILURE)
			var/obj/machinery/announcement_system/system_announcement = pick(GLOB.announcement_systems)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] has failed to get enough votes.", channels = list(radio_channel_used))
	return TRUE

/datum/union/proc/add_member(member_name, union_leader, datum/bank_account/bank_account_details)
	union_employees += list(list(
		CARGO_UNION_LEADER = union_leader,
		CARGO_UNION_NAME = member_name,
		CARGO_UNION_BANK = bank_account_details,
	))

/datum/union/proc/remove_member(removed_member_name)
	for(var/member in union_employees)
		if(member[CARGO_UNION_NAME] != removed_member_name)
			continue
		union_employees -= member
		return TRUE
	return FALSE

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

	var/on_cooldown = COOLDOWN_FINISHED(src, union_demand_delay)
	//vote stuff, only appears when something is voted for.
	if(demand_voting_on && on_cooldown)
		data["voting_name"] = demand_voting_on.name
		data["voting_desc"] = demand_voting_on.union_description
		data["votes_yes"] = length(votes_yes)
		data["votes_no"] = length(votes_no)
		data["time_left"] = DisplayTimeText(timeleft(voting_timer), 1)
	else
		data["voting_name"] = null
		data["locked_for"] = on_cooldown ? null : DisplayTimeText(COOLDOWN_TIMELEFT(src, union_demand_delay))

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
			"cost" = demands.cost,
			"ref" = REF(demands),
		))

	return data

/datum/union/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .
	var/mob/user = ui.user
	var/obj/machinery/host = ui.src_object
	if(istype(host) && !host.allowed(user)) //admin panel always works.
		host.balloon_alert(user, "no access!")
		return TRUE
	switch(action)
		if("trigger_vote")
			var/datum/union_demand/vote_for = locate(params["selected_demand"]) in possible_demands
			if(isnull(vote_for))
				return TRUE
			if(!COOLDOWN_FINISHED(src, union_demand_delay))
				host.balloon_alert(user, "on cooldown for [DisplayTimeText(COOLDOWN_TIMELEFT(src, union_demand_delay))]!")
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

/datum/union/proc/trigger_vote(datum/union_demand/vote_for)
	demand_voting_on = vote_for
	votes_yes.Cut()
	votes_no.Cut()

	make_union_announcement(vote_for, announce_mode = ANNOUNCE_START_VOTE)
	voting_timer = addtimer(CALLBACK(src, PROC_REF(stop_vote)), TIME_TO_VOTE, TIMER_STOPPABLE)

/datum/union/proc/stop_vote()
	if(length(votes_yes) > length(votes_no))
		on_demand_success()
	else
		on_demand_failure()

	votes_yes.Cut()
	votes_no.Cut()
	return TRUE

#undef TIME_BETWEEN_DEMANDS
#undef TIME_TO_VOTE
#undef COMMAND_DELAY
