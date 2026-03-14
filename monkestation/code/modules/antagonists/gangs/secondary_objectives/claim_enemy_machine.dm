/datum/traitor_objective_category/gang_claim_enemy_machine
	name = "Claim Enemy Machine_gang"
	objectives = list(/datum/traitor_objective/gang/claim_enemy_machine = 1)

/datum/traitor_objective/gang/claim_enemy_machine
	name = "Claim an enemy credit converter or fabricator for your gang."
	description = "Use the provided machine converter to take control of an enemy credit converter or gang fabricator. \
				Should the converter be destroyed replacements can be purchased in your uplink for 5 TC."
	telecrystal_penalty = 8 //dont just use it to get a free converter
	progression_maximum = 1000
	progression_minimum = 75
	progression_reward = list(10, 18)
	telecrystal_reward = list(3, 4)
	passive_tc_reward = 0.5

/datum/traitor_objective/gang/claim_enemy_machine/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!owner)
		return FALSE

	RegisterSignal(owner, COMSIG_GANG_TOOK_MACHINE, PROC_REF(owner_took_machine))
	return TRUE

/datum/traitor_objective/gang/claim_enemy_machine/ungenerate_objective()
	UnregisterSignal(owner, COMSIG_GANG_TOOK_MACHINE)

/datum/traitor_objective/gang/claim_enemy_machine/proc/owner_took_machine(datum/team/gang/taker, obj/machinery/gang_machine/taken, datum/team/gang/old_owner)
	SIGNAL_HANDLER
	if(!istype(taken, /obj/machinery/gang_machine/credit_converter) && !istype(taken, /obj/machinery/gang_machine/credit_converter))
		return

	succeed_objective()
