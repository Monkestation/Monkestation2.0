/datum/round_event_control/antagonist/solo/vampire
	antag_flag = ROLE_VAMPIRE
	tags = list(TAG_COMBAT, TAG_MAGICAL, TAG_CREW_ANTAG, TAG_SPOOKY)
	antag_datum = /datum/antagonist/vampire
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
		JOB_CURATOR,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 20
	weight = 8
	base_antags = 3
	maximum_antags = 4
	event_icon_state = "vampires"

/datum/round_event_control/antagonist/solo/vampire/roundstart
	name = "Vampires"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/solo/vampire/midround
	name = "Vampiric Accident"
	typepath = /datum/round_event/antagonist/solo/vampire
	antag_flag = ROLE_VAMPIRIC_ACCIDENT
	prompted_picking = TRUE
	max_occurrences = 1

/datum/round_event_control/antagonist/solo/vampire/midround/get_weight()
	. = ..()
	// if there's only one or two vamps, let's raise the chance of giving them some friends
	switch(length(GLOB.all_vampires))
		if(1)
			. *= 2
		if(2)
			. *= 1.5
		else
			return

/datum/round_event/antagonist/solo/vampire/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/vampire/vampire_datum = antag_mind.add_antag_datum(/datum/antagonist/vampire)
	vampire_datum.vampire_level_unspent += rand(2, 3)
