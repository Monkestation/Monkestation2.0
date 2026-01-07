/datum/round_event_control/antagonist/solo/traitor
	maximum_antags = 5
	antag_flag = ROLE_SYNDICATE_INFILTRATOR
	tags = list(TAG_COMBAT, TAG_CREW_ANTAG, TAG_MUNDANE)
	antag_datum = /datum/antagonist/traitor/infiltrator
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
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	weight = 18
	event_icon_state = "traitor"

/datum/round_event_control/antagonist/solo/traitor/roundstart
	name = "Traitors"
	denominator = 19
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	roundstart = TRUE
	earliest_start = 0 SECONDS
	extra_spawned_events = list(
	/datum/round_event_control/antagonist/solo/traitor/extra = 30,
    /datum/round_event_control/antagonist/solo/changeling/extra = 15,
    /datum/round_event_control/antagonist/solo/bloodsucker/extra = 20,
    /datum/round_event_control/antagonist/solo/heretic/extra = 10,
	null = 25
	)

/datum/round_event_control/antagonist/solo/traitor/midround
	name = "Sleeper Agents (Traitors)"
	denominator = 22
	antag_flag = ROLE_SLEEPER_AGENT
	antag_datum = /datum/antagonist/traitor/infiltrator/sleeper_agent
	prompted_picking = TRUE
	weight = 20
/datum/round_event_control/antagonist/solo/traitor/extra
	name = "Extra Traitors"
	base_antags = 0
	denominator = 14
	maximum_antags = 3
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	earliest_start = 0 SECONDS
	weight = 0 // shouldnt be spawned by storyteller
