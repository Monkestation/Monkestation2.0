/datum/round_event_control/antagonist/solo/gangs
	name = "Roundstart Gangs"
	tags = list(TAG_COMMUNAL, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_CREW_ANTAG, TAG_MUNDANE)
	antag_flag = ROLE_GANG_MEMBER
	antag_datum = /datum/antagonist/gang_member/boss
	typepath = /datum/round_event/antagonist/solo/gangs
	shared_occurence_type = SHARED_HIGH_THREAT
	repeated_mode_adjust = TRUE
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
		JOB_BRIDGE_ASSISTANT,
	)
	base_antags = 3
	maximum_antags = 3
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
	)
	required_enemies = 6
	min_players = 40
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 0
	max_occurrences = 0
//	preferred_events = list(/datum/round_event_control/antagonist/solo/traitor = 1)

/datum/round_event/antagonist/solo/gangs

/datum/round_event/antagonist/solo/gangs/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/gang_member/boss/boss_datum = ..()
	boss_datum.handler.telecrystals = /obj/item/implant/uplink/gang/boss::starting_tc
	return boss_datum
