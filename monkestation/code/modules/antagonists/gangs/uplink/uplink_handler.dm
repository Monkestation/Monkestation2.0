/datum/uplink_handler/gang
	item_stock = list(UPLINK_SHARED_STOCK_SURPLUS = 1) //cant buy kits, might also want to make it so they cant buy surplus
	can_take_objectives = FALSE
	maximum_active_objectives = 0
	maximum_potential_objectives = 0
	///Ref to the gang that owns us
	var/datum/team/gang/owning_gang

/datum/uplink_handler/gang/complete_objective(datum/traitor_objective/to_remove)
	. = ..()
	if(to_remove.objective_state != OBJECTIVE_STATE_COMPLETED)
		return
	owning_gang.completed_objectives += to_remove

/datum/uplink_handler/gang/take_objective(mob/user, datum/traitor_objective/to_take)
	. = ..()
	if(!. || !owning_gang)
		return

	owning_gang.track_objective(to_take)
