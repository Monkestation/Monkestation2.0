/datum/antagonist/devil/proc/sign_contract(datum/mind/mind, list/clauses)
	contracted[mind] = clauses
	RegisterSignal(mind, COMSIG_QDELETING, PROC_REF(on_mind_deleted))
	register_contract(mind, mind.current)

/datum/antagonist/devil/proc/register_contract(datum/mind/mind, mob/living/victim, first_apply = TRUE)
	RegisterSignal(mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_soul_transfer))
	var/list/victim_clauses = contracted[mind]
	for(var/datum/devil_clause/clause as anything in victim_clauses)
		clause.apply(victim, first_apply)

// Not necessarily completelly removed the contract, we could be in the process of being re-assigned
/datum/antagonist/devil/proc/remove_contract(datum/mind/mind, mob/living/victim)
	UnregisterSignal(mind, COMSIG_MIND_TRANSFERRED)
	var/list/victim_clauses = contracted[mind]
	for(var/datum/devil_clause/clause as anything in victim_clauses)
		clause.remove(victim)

/// Fires when one of our victims transferred bodies, so we can re-apply the clauses to them. No escaping consequences.
/datum/antagonist/devil/proc/on_soul_transfer(datum/mind/mind, mob/living/old_current)
	SIGNAL_HANDLER
	remove_contract(mind, old_current)
	if(mind.current)
		register_contract(mind, mind.current, FALSE)

/datum/antagonist/devil/proc/on_mind_deleted(datum/mind/mind)
	SIGNAL_HANDLER
	UnregisterSignal(mind, COMSIG_QDELETING)
	remove_contract(mind, mind.current)
	contracted -= mind
