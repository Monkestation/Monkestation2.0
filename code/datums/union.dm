GLOBAL_DATUM_INIT(cargo_union, /datum/union, new)

/datum/union
	///Name of the Union.
	var/name = "Cargo Union"
	///The budget the Union has control over, and pays their staff with.
	var/union_budget = ACCOUNT_CAR
	///Assoc List of people part of the Cargo Union, by default all Cargo personnel but the QM can add more.
	var/list/union_employees = list()

/datum/union/New()
	. = ..()
	RegisterSignal(SSeconomy, COMSIG_PAYDAYS_ISSUED, PROC_REF(handle_payday))

///Called when paydays are issued, Union personnel will get it later.
/datum/union/proc/handle_payday()
	for(var/member in GLOB.cargo_union.union_employees)
		var/datum/bank_account/bank_account = member[CARGO_UNION_BANK]
		if(isnull(bank_account))
			continue
		bank_account.payday(1, skippable = TRUE, event = "Union pay", budget_used = union_budget)

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
