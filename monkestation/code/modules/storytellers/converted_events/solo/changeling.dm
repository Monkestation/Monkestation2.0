/datum/round_event_control/antagonist/solo/changeling
	antag_flag = ROLE_CHANGELING
	tags = list(TAG_COMBAT, TAG_ALIEN, TAG_CREW_ANTAG)
	antag_datum = /datum/antagonist/changeling
	repeated_mode_adjust = TRUE // apparently these roll too often despite their weight, maybe this will help?
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
		JOB_BRIDGE_ASSISTANT,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 20
	weight = 10
	shared_occurence_type = SHARED_CHANGELING
	event_icon_state = "changeling"

/datum/round_event_control/antagonist/solo/changeling/roundstart
	name = "Changelings"
	roundstart = TRUE
	earliest_start = 0
	maximum_antags = 1

/datum/round_event_control/antagonist/solo/changeling/midround
	name = "Genome Awakening (Changelings)"
	antag_flag = ROLE_CHANGELING_MIDROUND
	prompted_picking = TRUE
	max_occurrences = 2
