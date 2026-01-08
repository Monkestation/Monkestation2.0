/datum/round_event_control/antagonist/solo/bloodsucker
	maximum_antags = 5
	antag_flag = ROLE_BLOODSUCKER
	tags = list(TAG_COMBAT, TAG_MAGICAL, TAG_CREW_ANTAG, TAG_SPOOKY)
	antag_datum = /datum/antagonist/bloodsucker
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
	weight = 8
	event_icon_state = "vampires"

/datum/round_event_control/antagonist/solo/bloodsucker/roundstart
	denominator = 22 //Lower to account for latejoiners.
	name = "Bloodsuckers"
	roundstart = TRUE
	earliest_start = 0 SECONDS
	extra_spawned_events = list(
	/datum/round_event_control/antagonist/solo/traitor/extra = 20,
	/datum/round_event_control/antagonist/solo/changeling/extra = 30,
	/datum/round_event_control/antagonist/solo/bloodsucker/extra = 15,
	/datum/round_event_control/antagonist/solo/heretic/extra = 10,
	null = 25
	)

/datum/round_event_control/antagonist/solo/bloodsucker/midround
	typepath = /datum/round_event/antagonist/solo/bloodsucker
	denominator = 27
	antag_flag = ROLE_VAMPIRICACCIDENT
	name = "Vampiric Accident"
	prompted_picking = TRUE
	max_occurrences = 1
	weight = 10
/datum/round_event_control/antagonist/solo/bloodsucker/extra
	name = "Extra Bloodsuckers"
	base_antags = 0
	denominator = 20
	maximum_antags = 3
	antag_flag = ROLE_BLOODSUCKER
	antag_datum = /datum/antagonist/bloodsucker
	earliest_start = 0 SECONDS
	weight = 0 // shouldnt be spawned by storyteller

/datum/round_event/antagonist/solo/bloodsucker/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = antag_mind.make_bloodsucker()
	bloodsuckerdatum.bloodsucker_level_unspent = rand(2,3)
