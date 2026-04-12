/datum/round_event_control/antagonist/bloodcult
	name = "Blood Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_MAGICAL)
	antag_flag = ROLE_CULTIST
	antag_datum = /datum/antagonist/cult
	typepath = /datum/round_event/antagonist/bloodcult
	shared_occurence_type = SHARED_HIGH_THREAT
	repeated_mode_adjust = TRUE
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
		JOB_BRIDGE_ASSISTANT,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 5
	base_antags = 2
	maximum_antags = 3
	min_players = 35
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 4
	max_occurrences = 1
	event_icon_state = "cult"
	preferred_events = list(/datum/round_event_control/antagonist/clockcult = 1)

/datum/round_event/antagonist/bloodcult
	end_when = 60000
	var/static/datum/team/cult/main_cult

/datum/round_event/antagonist/bloodcult/setup()
	. = ..()
	if(!main_cult)
		main_cult = new()

/datum/round_event/antagonist/bloodcult/start()
	. = ..()
	main_cult.setup_objectives()

/datum/round_event/antagonist/bloodcult/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/cult/new_cultist = new antag_datum()
	new_cultist.cult_team = main_cult
	new_cultist.give_equipment = TRUE
	antag_mind.add_antag_datum(new_cultist)
