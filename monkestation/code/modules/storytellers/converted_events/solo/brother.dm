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
		JOB_BRIG_PHYSICIAN,
	)
	extra_spawned_events = list(
		/datum/round_event_control/antagonist/solo/traitor/roundstart = 8,
		/datum/round_event_control/antagonist/solo/bloodsucker/roundstart = 6,
		/datum/round_event_control/antagonist/solo/heretic/roundstart = 1,
	)

/datum/round_event/antagonist/solo/brother/start()
	var/teams_amount = length(setup_minds)
	var/list/possible_bro = list()
	for (var/mob/player in GLOB.alive_player_list)
		if(ROLE_BROTHER in player.mind.current.client.prefs.be_special) //This should try to grab from anyone who has BB enabled
			possible_bro.Add(player)
	for(var/teamAmount in 1 to teams_amount)
		var/datum/team/brother_team/new_team = new
		var/datum/mind/starting_brother = pick_n_take(setup_minds) //Picks a random brother for this new team we are making. They are added to the team later
		var/another_brother = 1
		while(another_brother > 0) //Adds 1 brother to the team (from anyone would could roll BB), with a 10% chance for another if we add one. keep rolling until it fails
			another_brother = 0
			var/and_another = prob(10)
			if(and_another)
				another_brother = 1
			var/mob/target_player = astype(pick_n_take(possible_bro))
			message_admins("Target brother found, checking if valid")
			if(isnull(target_player)) //skip adding a brother if we picked null (like if only one person has BB enabled)
				message_admins("Target brother null")
				continue
			if(target_player.mind == starting_brother) // If we are trying to add the starting player in this loop. THEY ARE ADDED LATER BECAUSE MAYBE THERES NO OTHER BROTHERS
				message_admins("Target brother found is self")
				continue
			if(target_player.mind.has_antag_datum(/datum/antagonist/brother)) // Check if they are already a brother
				message_admins("Target brother has a brother")
				continue
			message_admins("Adding brother")
			new_team.add_member(target_player.mind)
		//next line is for the rare case where everyone has BB off but the 1-3 people who origionally rolled BB. or if they are all taken (like the 1/1000000000000000000 chance for a team of 20))
		if(new_team.members.len == 0) //If a BB team is only 1 person long, we just add all the brothers without a team onto this one
			for(var/unteamed_brother in setup_minds.len)
				if(unteamed_brother)
					new_team.add_member(pop(setup_minds))
		if(new_team.members.len == 0) //If no one is on their team still, they get heretic because all their possible brothers betrayed them. they also get their brothers as additional sac targets
			var/list/enemy_brothers = list()
			for(var/mob/player in GLOB.alive_player_list)
				if(player.mind.has_antag_datum(/datum/antagonist/brother))
					enemy_brothers.Add(player)
			if(ROLE_HERETIC in starting_brother.current.client.prefs.be_special)
				var/datum/antagonist/heretic/heretic_datum = starting_brother.add_antag_datum(/datum/antagonist/heretic)
				for(var/mob/heretic_target in enemy_brothers)
					heretic_datum.add_sacrifice_target(heretic_target)
			else
				starting_brother.add_antag_datum(/datum/antagonist/traitor) // Give them traitor if they dont have heretic on
			qdel(new_team)
			return
		new_team.add_member(starting_brother) //Add the first member we picked to the team that we got when this event rolled
		new_team.update_name()
		new_team.forge_brother_objectives()
		new_team.notify_whos_who()
