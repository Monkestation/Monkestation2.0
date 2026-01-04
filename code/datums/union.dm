GLOBAL_DATUM_INIT(cargo_union, /datum/union, new)
GLOBAL_LIST_INIT(union_demands, list())

/datum/union
	///Name of the Union.
	var/name = "Cargo Union"
	///The budget the Union has control over, and pays their staff with.
	var/union_budget = ACCOUNT_CAR
	///Assoc List of people part of the Cargo Union, by default all Cargo personnel but the QM can add more.
	///stored as: list(CARGO_UNION_LEADER = boolean, CARGO_UNION_NAME = string, CARGO_UNION_BANK, /datum/bank_account)
	var/list/union_employees = list()

	///List of all demands this Union can make.
	var/datum/union_demand/possible_demands = list()

	///List of all demands this Union has successfully done.
	var/datum/union_demand/successful_demands = list()

/datum/union/New()
	. = ..()
	RegisterSignal(SSeconomy, COMSIG_PAYDAYS_ISSUED, PROC_REF(handle_payday))
	for(var/datum/union_demand/demands as anything in subtypesof(/datum/union_demand))
		if(demands::department_eligible != union_budget)
			continue
		possible_demands |= new demands()

/datum/union/Destroy(force)
	QDEL_LIST(possible_demands)
	QDEL_LIST(successful_demands)
	union_employees.Cut()
	return ..()

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

/**
 * Union Demands
 * Datum storing what demands a Union can ask for, their requirements, and the effects they have on the round.
 */
/datum/union_demand
	///Name of the demand
	var/name = "Demand"
	///The description of the demand given to Union personnel.
	var/union_description = "We deserve our fair share, right?"
	///The description of the demand given to the whole station when the demand is being made.
	var/station_description = "The Cargo Union is making this demand."
	///Which department is eligible to demand this. Support for non-cargo unions don't exist yet, so this is pointless lol.
	var/department_eligible = ACCOUNT_CAR

/datum/union_demand/proc/can_demand()
	return TRUE

/datum/union_demand/proc/on_demand()

/datum/union_demand/vendor_stock
	name = "Vendor Stock Automatic Reporting"
	union_description = "The Union has noticed the vending machines on the station have been getting refilled in a very \
		inefficient manner and the Union has been getting the blame for this inefficiency. \
		As part of our new wave of agreements, we're purchasing new tracking software for vending machines \
		that will automatically report their stock and send it for Cargo's easy viewing. \
		Did you know vendors pay for refilled stock?"
	station_description = "The Cargo Union has voted for a new demand, all vending machines will be equipped \
		with surveyance software that will be reported back to Cargo so they can ensure all vendors are properly stocked."
