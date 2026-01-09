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
	base_antags = 1 //used to determine how many teams we will have
	maximum_antags = 3 //used to determine the max amount of teams we will have
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
	var/teams_amount = length(setup_minds)
	for(newTeam in teams_amount)
		var/datum/team/brother_team/team = new
		team.add_member(pick_n_take(setup_minds)) //Add the first member from the 1-3 that we got when this even rolled
		var/another_brother = 1
		while(another_brother == 1) //Adds 1 brother to the team (from anyone would could roll BB), with a 10% chance for another if we add one. keep rolling until it fails
			var/list/candidates = cast_control.get_candidates()
			team.add_member(anyone in candidates)
			var/and_another = prob(10)
			if(and_another)
				another_brother = 1
		//next line is for the rare case where everyone has BB off but the 1-3 people who origionally rolled BB. or if they are all taken (like the 1/1000000000000000000 chance for a team of 20))
		if(team.members.len == 1) //If a BB team is only 1 person long, we just add all the brothers without a team onto this one.
			for(var/unteamed_brother in setup_minds)
				if(unteamed_brother)
					team.add_member(pop(setup_minds))
			if(team.members.len == 1) //If no one is on their team still, they get heretic because all their possible brothers betrayed them. they also get their brothers as additional sac targets
				var/datum/mind/lonely_sap = setup_minds[1]
				var/datum/antagonist/heretic/heretic_datum
				for(var/mob/player in GLOB.alive_player_list)
					if(player.mind.has_antag_datum(/datum/antagonist/brother))
						heretic_datum.add_sacrifice_target(player)
				lonely_sap.add_antag_datum(heretic_datum)
				return
		team.update_name()
		team.forge_brother_objectives()
		team.notify_whos_who()
