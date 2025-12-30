/datum/round_event_control/antagonist/solo/brother
	name = "Blood Brothers"
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/solo/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG, TAG_CREW_ANTAG, TAG_MUNDANE)
	cost = 0.45 // so it doesn't eat up threat for a relatively low-threat antag
	weight = 10
	required_enemies = 1
	roundstart = TRUE
	earliest_start = 0 SECONDS
	base_antags = 2
	maximum_antags = 4
	denominator = 30
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
		JOB_CYBORG
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
	extra_spawned_events = list(
		/datum/round_event_control/antagonist/solo/traitor/roundstart = 8,
		/datum/round_event_control/antagonist/solo/bloodsucker/roundstart = 6,
		/datum/round_event_control/antagonist/solo/heretic/roundstart = 1,
	)
	var/static/allow_3_person_teams

/datum/round_event_control/antagonist/solo/brother/get_antag_amount()
	if(isnull(allow_3_person_teams))
		allow_3_person_teams = prob(10) // 3-brother teams only happen around 10% of the time
	. = ..()
	if(!allow_3_person_teams)
		return FLOOR(., 2)

/datum/round_event/antagonist/solo/brother/start()
	if(length(setup_minds) < 2) // if we somehow only got one BB chosen, despite the fact we asked for 2, fuck it, they just get to be a traitor, and we'll throw the storyteller a bone
		var/datum/mind/lonely_sap = setup_minds[1]
		lonely_sap.add_antag_datum(/datum/antagonist/traitor)
		SSgamemode.point_gain_multipliers[EVENT_TRACK_ROLESET] *= 1.5
		return
	while(length(setup_minds))
		var/amt = 2
		if(length(setup_minds) == 3) // if there would be one candidate left afterwards, we'll just make this a 3-person team
			amt++
		var/datum/team/brother_team/team = new
		for(var/_ in 1 to amt)
			team.add_member(pick_n_take(setup_minds))
		team.update_name()
		team.forge_brother_objectives()
		team.notify_whos_who()
