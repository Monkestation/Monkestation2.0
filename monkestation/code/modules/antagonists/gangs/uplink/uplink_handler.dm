/datum/uplink_handler/gang
	item_stock = list() //stock is handled on the team
	can_take_objectives = FALSE
	maximum_active_objectives = 0
	maximum_potential_objectives = 0
	uplink_flag = UPLINK_GANGS
	///Ref to the gang that owns us
	var/datum/team/gang/owning_gang

/datum/uplink_handler/gang/get_item_stock()
	return owning_gang.shared_team_stock

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

//yes I know its near copypasta but the other options are much less performant
/datum/uplink_handler/gang/handle_duplicate(datum/traitor_objective/potential_duplicate)
	if(!owning_gang)
		return ..()

	if(!istype(potential_duplicate))
		return FALSE

	var/datum/traitor_objective/current_type = potential_duplicate.type
	while(current_type != /datum/traitor_objective)
		if(!owning_gang.potential_duplicate_objectives[current_type])
			owning_gang.potential_duplicate_objectives[current_type] = list(potential_duplicate)
		else
			owning_gang.potential_duplicate_objectives[current_type] += potential_duplicate

		current_type = type2parent(current_type)
	owning_gang.update_duplicate_objectives()
	return TRUE
