//some gang objectives are still subtypes of other things due to those types handling more logic than this
/datum/traitor_objective/gang //need to convert this into a component
	name = "gang objective"
	description = "this is a gang objective, also something broke if your seeing this"
	progression_minimum = 0
	valid_uplinks = UPLINK_GANGS
	global_progression_influence_intensity = 0
	abstract_type = /datum/traitor_objective/gang
	///How much passive TC do we give on completetion
	var/passive_tc_reward = 0.1
	///Ref to the gang that owns this objective
	var/datum/team/gang/owner

//soonest we can do things while staying modular, we want owner set ASAP
/datum/traitor_objective/gang/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	SHOULD_CALL_PARENT(TRUE) //do NOT forget to set owner
	var/datum/antagonist/gang_member/antag_datum = generating_for.has_antag_datum(/datum/antagonist/gang_member)
	if(!antag_datum?.gang_team)
		return FALSE

	owner = antag_datum.gang_team
	return ..()

/datum/traitor_objective/gang/fail_objective(penalty_cost, trigger_update)
	. = ..()
	if(penalty_cost && objective_state == OBJECTIVE_STATE_FAILED)
		owner.unallocated_tc -= penalty_cost //double total TC rewards but also double failure cost

/datum/traitor_objective/gang/get_extra_reward_data()
	return "[passive_tc_reward] Passive TC"
