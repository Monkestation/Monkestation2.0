ADMIN_VERB(union_manager, R_ADMIN, FALSE, "Manage Cargo Union", "View the Cargo Union panel.", ADMIN_CATEGORY_GAME)
	GLOB.cargo_union.ui_interact(user.mob)

#define TIME_BETWEEN_DEMANDS (10 MINUTES)
#define TIME_TO_VOTE (TIME_BETWEEN_DEMANDS / 4)
///The time Command has to stop a demand.
#define COMMAND_DELAY (3 MINUTES)

//TODO:
// SPRITES: UnionStand.scss background should have low alpha instead of the weird color scheme. Mail collector unique sprite.
// Finish adding all the union demands (Access-locked Vendors)

/datum/union
	///Name of the Union.
	var/name = "Cargo Union"
	///The budget the Union has control over, and pays their staff with.
	var/union_budget = ACCOUNT_CAR
	///The radio channel to announce union-wide stuff.
	var/radio_channel_used = RADIO_CHANNEL_SUPPLY
	///Boolean on whether the Union is active.
	var/union_active = TRUE

	///Assoc List of people part of the Cargo Union, by default all Cargo personnel but the QM can add more.
	///stored as: list(CARGO_UNION_LEADER = boolean, CARGO_UNION_NAME = string, CARGO_UNION_BANK, /datum/bank_account)
	var/list/union_employees = list()
	///List of all printed badges.
	var/list/obj/item/clothing/accessory/badge/cargo/printed_badges = list()

	///List of all demands this Union can make.
	var/list/datum/union_demand/possible_demands = list()
	///List of all demands this Union has successfully done.
	var/list/datum/union_demand/successful_demands = list()

	///Delay between union demand votings.
	COOLDOWN_DECLARE(union_demand_delay)
	///How many times the current demand was in a deadlock.
	var/times_deadlocked = 0
	///Stored time left to end the vote, different from delay of demanding union stuff.
	var/voting_timer
	///In a deadlock, this is the saved time left to give afterwards.
	var/saved_time
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
	setup_demands()

/datum/union/proc/setup_demands()
	for(var/datum/union_demand/demand as anything in GLOB.union_demands)
		if(demand::department_eligible != union_budget)
			continue
		possible_demands |= GLOB.union_demands[demand]

/datum/union/Destroy(force)
	possible_demands.Cut()
	successful_demands.Cut()
	union_employees.Cut()
	if(voting_timer)
		deltimer(voting_timer)
		voting_timer = null
	if(implement_delay_timer)
		deltimer(implement_delay_timer)
		implement_delay_timer = null
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

/datum/union/proc/demand_is_implemented(datum/union_demand/demand_type)
	if(!union_active)
		var/datum/union_demand/demand = GLOB.union_demands[demand_type]
		return demand.active_without_union
	return GLOB.union_demands[demand_type] in successful_demands

///Called when a demand is succesfully voted to go into effect.
/datum/union/proc/on_demand_success()
	if(!(demand_voting_on in possible_demands))
		stack_trace("[name] just tried to enact [demand_voting_on.name], but it's not in their list of possible demands!")
		return FALSE
	COOLDOWN_START(src, union_demand_delay, TIME_BETWEEN_DEMANDS)
	make_union_announcement(announce_mode = ANNOUNCE_CREW)
	possible_demands -= demand_voting_on
	implement_delay_timer = addtimer(CALLBACK(src, PROC_REF(implement_demand)), COMMAND_DELAY, TIMER_STOPPABLE)

///Called after the delay to implement a demand, if Command did nothing to stop it, putting it into effect and taking cost.
/datum/union/proc/implement_demand()
	make_union_announcement(announce_mode = ANNOUNCE_INTO_EFFECT)
	successful_demands += demand_voting_on
	demand_voting_on.implement_demand(src)
	demand_voting_on = null
	times_deadlocked = 0

/datum/union/proc/unimplement_demand(datum/union_demand/removed_demand)
	successful_demands -= removed_demand
	possible_demands += removed_demand
	removed_demand.unimplement_demand(src)

///Called when a demand fails to get voted on to go into effect.
/datum/union/proc/on_demand_failure(source = ANNOUNCE_FAILURE)
	make_union_announcement(announce_mode = source)
	demand_voting_on = null
	saved_time = null
	times_deadlocked = 0

///Depending on announce_mode, we will announce to the Union or Crew the several stages of a Union Demand.
/datum/union/proc/make_union_announcement(announce_mode)
	var/obj/machinery/announcement_system/system_announcement = pick(GLOB.announcement_systems)
	switch(announce_mode)
		if(ANNOUNCE_START_VOTE)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "A vote for [demand_voting_on.name] has started. Please remember check the Union board to vote!", channels = list(radio_channel_used))
		if(ANNOUNCE_CREW)
			priority_announce(
				text = demand_voting_on.station_description,
				title = name,
				has_important_message = TRUE,
			)
		if(ANNOUNCE_INTO_EFFECT)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] is now in full effect.", channels = list(radio_channel_used))
		if(ANNOUNCE_DEADLOCK)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] is under deadlock. Please speak with Command on how proceedings may go.", channels = list(radio_channel_used))
		if(ANNOUNCE_DEADLOCK_END)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] has been let go by Command. Please standby as it comes into effect.", channels = list(radio_channel_used))
		if(ANNOUNCE_DEADLOCK_COMMAND_WIN)
			system_announcement.announce(AUTO_ANNOUNCE_UNION, "[demand_voting_on.name] has been abandoned due to ongoing works by Command.", channels = list(radio_channel_used))
		if(ANNOUNCE_FAILURE)
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

/datum/union/proc/start_deadlock()
	times_deadlocked++
	freeze_time()
	make_union_announcement(announce_mode = ANNOUNCE_DEADLOCK)

/datum/union/proc/end_deadlock(union_won = FALSE)
	if(union_won)
		make_union_announcement(announce_mode = ANNOUNCE_DEADLOCK_END)
		unfreeze_time()
	else
		on_demand_failure(ANNOUNCE_DEADLOCK_COMMAND_WIN)

/datum/union/proc/freeze_time()
	saved_time = timeleft(implement_delay_timer)
	deltimer(implement_delay_timer)
	implement_delay_timer = null

/datum/union/proc/unfreeze_time()
	implement_delay_timer = addtimer(CALLBACK(src, PROC_REF(implement_demand)), saved_time, TIMER_STOPPABLE)
	saved_time = null

/datum/union/proc/trigger_vote(datum/union_demand/vote_for)
	demand_voting_on = vote_for
	votes_yes.Cut()
	votes_no.Cut()
	voting_timer = addtimer(CALLBACK(src, PROC_REF(stop_vote)), TIME_TO_VOTE, TIMER_STOPPABLE)

	make_union_announcement(announce_mode = ANNOUNCE_START_VOTE)
	for(var/obj/machinery/union_stand/stand as anything in SSmachines.get_machines_by_type(/obj/machinery/union_stand))
		stand.update_appearance()

/datum/union/proc/stop_vote()
	if(length(votes_yes) > length(votes_no))
		on_demand_success()
	else
		on_demand_failure()

	votes_yes.Cut()
	votes_no.Cut()
	if(voting_timer)
		deltimer(voting_timer)
	voting_timer = null
	for(var/obj/machinery/union_stand/stand as anything in SSmachines.get_machines_by_type(/obj/machinery/union_stand))
		stand.update_appearance()
	return TRUE

#undef TIME_BETWEEN_DEMANDS
#undef TIME_TO_VOTE
#undef COMMAND_DELAY
