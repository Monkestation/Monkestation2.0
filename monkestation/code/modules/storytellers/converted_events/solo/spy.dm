/datum/round_event_control/antagonist/solo/spy
	tags = list(TAG_COMBAT)
	antag_datum = /datum/antagonist/spy
	weight = 10
	base_antags = 1
	maximum_antags = 3
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
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)

/datum/round_event_control/antagonist/solo/spy/roundstart
	antag_flag = ROLE_SPY
	name = "Spy"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/spy/midround
	antag_flag = ROLE_DEFECTOR
	name = "Defector (Spy)"
	prompted_picking = TRUE
