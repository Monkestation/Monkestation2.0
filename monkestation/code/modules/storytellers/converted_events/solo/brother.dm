/datum/round_event_control/antagonist/brother
	name = "Blood Brothers"
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	typepath = /datum/round_event/antagonist/brother
	tags = list(TAG_COMBAT, TAG_TEAM_ANTAG, TAG_CREW_ANTAG, TAG_MUNDANE)
	cost = 0.45 // so it doesn't eat up threat for a relatively low-threat antag
	weight = 10
	required_enemies = 1
	roundstart = TRUE
	earliest_start = 0 SECONDS
	base_antags = 1
	maximum_antags = 3
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
		/datum/round_event_control/antagonist/traitor/roundstart = 9, //Traitors are always fun
		VAMPIRE_ROUNDSTART_EVENT = 1, //Vampires can vassalize people making very big teams.
		/datum/round_event_control/antagonist/heretic/roundstart = 2, //Heretics cant convert crew to their side. So it gets a higher weight then Vampires
	)

/datum/round_event_control/antagonist/brother/midround
	name = "Sleeper Agents (Blood Brothers)"
	prompted_picking = TRUE
	required_enemies = 2

/datum/round_event/antagonist/brother/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/team/brother_team/team = new
	team.add_member(antag_mind)
	team.forge_brother_objectives()
	antag_mind.add_antag_datum(/datum/antagonist/brother, team)
