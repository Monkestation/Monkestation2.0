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
		//datum/round_event_control/antagonist/solo/heretic/roundstart = 1,
	)

/datum/round_event/antagonist/solo/brother/start()
	message_admins("BBs are selected")
	var/teams_amount = length(setup_minds)
	var/datum/round_event_control/antagonist/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/possible_candidates = cast_control.get_candidates()
	for(var/newTeam in 1 to teams_amount)
		message_admins("we are trying to make a team")
		var/datum/team/brother_team/new_team = new
		var/datum/mind/starting_brother = pick_n_take(setup_minds) //Picks a random brother for this new team we are making. They are added to the team later
		var/another_brother = 1
		while(another_brother > 0) //Adds 1 brother to the team (from anyone would could roll BB), with a 10% chance for another if we add one. keep rolling until it fails
			another_brother = 0
			new_team.add_member(pick_n_take(possible_candidates))
			var/and_another = prob(10)
			if(and_another)
				another_brother = 1
				message_admins("Another brother!!")
		message_admins("far3")
		//next line is for the rare case where everyone has BB off but the 1-3 people who origionally rolled BB. or if they are all taken (like the 1/1000000000000000000 chance for a team of 20))
		if(new_team.members.len == 0) //If a BB team is only 1 person long, we just add all the brothers without a team onto this one
			for(var/datum/mind/unteamed_brother in setup_minds)
				if(unteamed_brother)
					new_team.add_member(pop(setup_minds))
			message_admins("Trying to adding all unteamed brothers to a team")
		if(new_team.members.len == 0) //If no one is on their team still, they get heretic because all their possible brothers betrayed them. they also get their brothers as additional sac targets
			var/datum/antagonist/heretic/heretic_datum
			for(var/mob/player in GLOB.alive_player_list)
				if(player.mind.has_antag_datum(/datum/antagonist/brother))
					heretic_datum.add_sacrifice_target(player)
			starting_brother.add_antag_datum(heretic_datum)
			new_team.Destroy()
			message_admins("no brothers, heretic time")
			return
		new_team.add_member(starting_brother) //Add the first member we picked to the team that we got when this event rolled
		new_team.update_name()
		new_team.forge_brother_objectives()
		new_team.notify_whos_who()
	message_admins("you should be a bb with a team")
