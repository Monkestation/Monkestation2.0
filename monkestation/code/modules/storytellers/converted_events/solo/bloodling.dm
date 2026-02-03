/datum/round_event_control/antagonist/solo/bloodling
	name = "Bloodling"
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG)
	antag_flag = ROLE_BLOODLING
	antag_datum = /datum/antagonist/bloodling
	typepath = /datum/round_event/antagonist/solo/bloodling
	shared_occurence_type = SHARED_HIGH_THREAT
	repeated_mode_adjust = TRUE
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
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_DETECTIVE,
		JOB_WARDEN,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
	)
	required_enemies = 5
	weight = 4
	max_occurrences = 0
	maximum_antags = 1
	min_players = 45
	denominator = 30

/datum/round_event_control/antagonist/solo/bloodling/roundstart
	name = "Bloodlings"
	roundstart = TRUE
	earliest_start = 0 SECONDS
	max_occurrences = 1

/datum/round_event/antagonist/solo/bloodling/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.special_role = ROLE_BLOODLING
	antag_mind.add_antag_datum(antag_datum)
