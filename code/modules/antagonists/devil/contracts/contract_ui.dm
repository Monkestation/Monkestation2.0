/datum/contract_ui
	/// The devil this UI belongs to
	var/datum/antagonist/devil/devil
	/// The last contract we touched, so we actually know what we are editing
	var/obj/item/paper/devil_contract/last_touched_contract = null

/datum/contract_ui/New(datum/antagonist/devil/new_devil)
	. = ..()
	devil = new_devil

/datum/contract_ui/Destroy(force)
	devil = null
	if(last_touched_contract)
		on_contract_deleted()
	return ..()

/datum/contract_ui/proc/assign_contract(obj/item/paper/devil_contract/contract)
	if(last_touched_contract)
		UnregisterSignal(last_touched_contract, COMSIG_QDELETING)
	last_touched_contract = contract
	RegisterSignal(contract, COMSIG_QDELETING, PROC_REF(on_contract_deleted))

/datum/contract_ui/proc/on_contract_deleted(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(last_touched_contract, COMSIG_QDELETING)
	last_touched_contract = null

/datum/contract_ui/ui_state(mob/user)
	return GLOB.conscious_state

/datum/contract_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DevilContract", last_touched_contract.name)
		ui.open()

/datum/contract_ui/ui_data(mob/user)
	var/list/data = list()
	data["points"] = 0
	data["clauses"] = list()
	if(!last_touched_contract)
		return data
	data["points"] = last_touched_contract.points
	for(var/datum/devil_clause/clause as anything in devil.clauses)
		var/in_contract = (clause in last_touched_contract.clauses)
		var/should_disable = FALSE
		if(in_contract) // Pain and suffering, just make sure negative cost can't happen, yeah?
			should_disable = ((last_touched_contract.points - clause.cost) > 0)
		else
			should_disable = ((last_touched_contract.points + clause.cost) > 0)

		data["clauses"] += list(list(
			"ref" = REF(clause),
			"name" = "[clause.name] (cost:[clause.cost])",
			"desc" = clause.desc,
			"color" = (in_contract ? "green" : "red"), // Above could be turned into static, but merging both together is a pain
			"disabled" = should_disable,
		))
	return data

/datum/contract_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!istype(user) || !user.Adjacent(last_touched_contract) || last_touched_contract.signer)
		return

	if(params["color"] == "green")
		var/datum/devil_clause/clause = locate(params["clause"]) in last_touched_contract.clauses
		if(!clause || !istype(clause) || (last_touched_contract.points - clause.cost) > 0)
			return

		last_touched_contract.remove_clause(clause)
		return TRUE
	else
		var/datum/devil_clause/clause = locate(params["clause"]) in devil.clauses
		if(!clause || !istype(clause) || (last_touched_contract.points + clause.cost) > 0) // Don't let the point amount go over 0
			return

		for(var/datum/devil_clause/conflict_path as anything in clause.conflicts)
			var/datum/devil_clause/conflict_clause = locate(conflict_path) in last_touched_contract.clauses
			if(conflict_clause)
				to_chat(user, span_warning("[clause] conflicts with [conflict_clause]!"))
				return

		last_touched_contract.add_clause(clause)
		return TRUE
