/datum/round_event_control/antagonist/assault_operative
	name = "Roundstart Assault Operatives"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_OUTSIDER_ANTAG, TAG_MUNDANE)
	antag_flag = ROLE_ASSAULT_OPERATIVE
	antag_datum = /datum/antagonist/assault_operative
	typepath = /datum/round_event/antagonist/assault_operative
	shared_occurence_type = SHARED_HIGH_THREAT
	repeated_mode_adjust = TRUE
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	base_antags = 3
	maximum_antags = 5
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
	)
	required_enemies = 5
	// I give up, just there should be enough heads with 35 players...
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 3
	max_occurrences = 1

/datum/round_event/antagonist/assault_operative

/datum/round_event/antagonist/assault_operative/add_datum_to_mind(datum/mind/antag_mind)
	var/mob/living/current_mob = antag_mind.current
	SSjob.FreeRole(antag_mind.assigned_role.title)
	current_mob.clear_inventory()

	antag_mind.set_assigned_role(SSjob.GetJobType(/datum/job/assault_operative))
	antag_mind.special_role = ROLE_ASSAULT_OPERATIVE

	var/datum/antagonist/assault_operative/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)
