/datum/round_event_control/antagonist/solo/changeling
	maximum_antags = 5
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
		JOB_BRIG_PHYSICIAN,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
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
	denominator = 22
	name = "Changelings"
	roundstart = TRUE
	earliest_start = 0
	extra_spawned_events = list(
	/datum/round_event_control/antagonist/solo/traitor/extra = 20,
	/datum/round_event_control/antagonist/solo/changeling/extra = 30,
	/datum/round_event_control/antagonist/solo/bloodsucker/extra = 15,
	/datum/round_event_control/antagonist/solo/heretic/extra = 10,
	null = 25
	)

/datum/round_event_control/antagonist/solo/changeling/midround
	denominator = 27
	name = "Genome Awakening (Changelings)"
	antag_flag = ROLE_GENOMEAWAKENING
	prompted_picking = TRUE
	max_occurrences = 2
/datum/round_event_control/antagonist/solo/changeling/extra
	name = "Extra Changelings"
	base_antags = 0
	denominator = 20
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	weight = 0 //shouldnt be spawned by storyteller
	maximum_antags = 3
	min_players = 20
