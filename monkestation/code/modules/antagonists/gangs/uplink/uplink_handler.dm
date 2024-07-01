/datum/uplink_handler/gang
	item_stock = list(UPLINK_SHARED_STOCK_SURPLUS = 1) //cant buy kits, might also want to make it so they cant buy surplus
	can_take_objectives = FALSE
	maximum_active_objectives = 0
	maximum_potential_objectives = 0
	///Ref to the gang that owns us
	var/datum/team/gang/owning_gang

/datum/uplink_handler/gang/complete_objective(datum/traitor_objective/to_remove)
	. = ..()
	if(!.)
		return
	//the macro has a ?. check on the datum so we can just directly input it without checking
	var/datum/antagonist/gang_member/boss_datum = owner.has_antag_datum(/datum/antagonist/gang_member)
	if(to_remove.objective_state == OBJECTIVE_STATE_COMPLETED && MEETS_GANG_RANK(boss_datum, GANG_RANK_BOSS))
		owning_gang.unallocated_tc += to_remove.telecrystal_reward
