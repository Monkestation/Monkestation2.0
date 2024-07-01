/// Simple helper component that sends an objective along with some flags to all handlers within linked_handlers whenever the objective is completed or failed]
/datum/component/linked_traitor_objective
	dupe_mode = COMPONENT_DUPE_ALLOWED

	///List of handlers we send to
	var/list/linked_handlers = list()
	///Shared TC reward
	var/shared_tc_reward = 0
	///Shared progression point reward
	var/shared_point_reward = 0
	///Shared penalty for failing
	var/shared_penalty = 0

/datum/component/linked_traitor_objective/Initialize(list/linked_handlers, shared_tc_reward, shared_point_reward, shared_penalty)
	. = ..()
	if(!istype(parent, /datum/traitor_objective))
		return COMPONENT_INCOMPATIBLE

	src.linked_handlers = linked_handlers
	src.shared_tc_reward = shared_tc_reward
	src.shared_point_reward = shared_point_reward
	src.shared_penalty = shared_penalty

/datum/component/linked_traitor_objective/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRAITOR_OBJECTIVE_COMPLETED, PROC_REF(on_success))
	RegisterSignal(parent, COMSIG_TRAITOR_OBJECTIVE_FAILED, PROC_REF(on_fail))

/datum/component/linked_traitor_objective/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_TRAITOR_OBJECTIVE_COMPLETED,
		COMSIG_TRAITOR_OBJECTIVE_FAILED
	))

/datum/component/linked_traitor_objective/proc/on_fail(datum/traitor_objective/source)
	SIGNAL_HANDLER
	for(var/datum/uplink_handler/handler in linked_handlers)
		handler.telecrystals += shared_penalty
	qdel(src)

/datum/component/linked_traitor_objective/proc/on_success()
	SIGNAL_HANDLER
	for(var/datum/uplink_handler/handler in linked_handlers)
		handler.telecrystals += shared_tc_reward
		handler.progression_points += shared_point_reward
	qdel(src)
