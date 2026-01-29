/datum/round_event_control/antagonist/from_ghosts/nuclear_operative
	name = "Nuclear Assault"
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_OUTSIDER_ANTAG, TAG_MUNDANE)
	antag_flag = ROLE_OPERATIVE_MIDROUND
	antag_datum = /datum/antagonist/nukeop
	typepath = /datum/round_event/antagonist/ghost/nuclear_operative
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
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
	maximum_antags = 4
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_enemies = 5
	min_players = 35
	earliest_start = 60 MINUTES
	weight = 3
	max_occurrences = 1
	prompted_picking = TRUE

/datum/round_event/antagonist/ghost/nuclear_operative
	var/static/datum/team/nuclear/nuke_team
	var/set_leader = FALSE
	var/required_role = ROLE_NUCLEAR_OPERATIVE
	var/datum/mind/most_experienced

/datum/round_event/antagonist/ghost/nuclear_operative/add_datum_to_mind(datum/mind/antag_mind)
	if(most_experienced == antag_mind)
		return
	var/mob/living/current_mob = antag_mind.current
	current_mob.clear_inventory()

	if(!most_experienced)
		most_experienced = get_most_experienced(setup_minds, required_role)
	antag_mind.set_assigned_role(SSjob.GetJobType(/datum/job/nuclear_operative))
	antag_mind.special_role = ROLE_NUCLEAR_OPERATIVE

	if(!most_experienced)
		most_experienced = antag_mind

	if(!set_leader)
		set_leader = TRUE
		var/datum/antagonist/nukeop/leader/leader_antag_datum = most_experienced.add_antag_datum(/datum/antagonist/nukeop/leader)
		nuke_team = leader_antag_datum.nuke_team

	if(antag_mind == most_experienced)
		return

	var/datum/antagonist/nukeop/new_op = new antag_datum()
	antag_mind.add_antag_datum(new_op)
