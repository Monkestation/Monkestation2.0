/datum/dynamic_ruleset/roundstart/bloodling
	name = "bloodling"
	antag_flag = ROLE_BLOODLING
	antag_datum = /datum/antagonist/bloodling
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,

	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10

	minimum_players = 25

	requirements = list(90,80,80,70,60,40,30,20,10,10)
	antag_cap = 1
	flags = HIGH_IMPACT_RULESET

/datum/dynamic_ruleset/roundstart/bloodling/pre_execute(population)
	if(candidates.len <= 0)
		break
	var/mob/mob = pick_n_take(candidates)
	assigned += mob.mind
	mob.mind.restricted_roles = restricted_roles
	mob.mind.special_role = ROLE_BLOODLING
	GLOB.pre_setup_antags += mob.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodling/execute()
	var/datum/antagonist/bloodling/new_antag = new antag_datum()
	bloodling.add_antag_datum(new_antag)
	GLOB.pre_setup_antags -= bloodling
	return TRUE
