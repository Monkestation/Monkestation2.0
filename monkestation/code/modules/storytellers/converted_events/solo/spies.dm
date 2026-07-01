/datum/round_event_control/antagonist/spy
	antag_flag = ROLE_SPY
	cost = 0.80
	maximum_antags = 3
	denominator = 28
	base_antags = 2
	required_enemies = 3
	tags = list(TAG_COMBAT, TAG_CREW_ANTAG, TAG_MUNDANE)
	antag_datum = /datum/antagonist/spy
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIDGE_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_PRISONER,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
	)
	weight = 10

/datum/round_event_control/antagonist/spy/roundstart
	name = "Spies"
	roundstart = TRUE
	earliest_start = 0 SECONDS
