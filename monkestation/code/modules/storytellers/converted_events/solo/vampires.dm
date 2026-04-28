/datum/round_event_control/antagonist/vampire
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
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
		JOB_CHAPLAIN,
		JOB_CURATOR,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_enemies = 1
	min_players = 8
	weight = 10
	base_antags = 1
	maximum_antags = 2
	denominator = 25 // need at least 25 pop for 2 vamps
	event_icon_state = "vampires"

/datum/round_event_control/antagonist/vampire/roundstart
	name = "Vampires"
	roundstart = TRUE
	earliest_start = 0 SECONDS

/datum/round_event_control/antagonist/vampire/midround
	name = "Vampiric Accident"
	typepath = /datum/round_event/antagonist/vampire
	antag_flag = ROLE_VAMPIRIC_ACCIDENT
	prompted_picking = TRUE
	max_occurrences = 1

/datum/round_event_control/antagonist/vampire/midround/can_spawn_event(players_amt, allow_magic, fake_check)
	. = ..()
	if(!.)
		return
	var/vampire_amt = 0
	for(var/datum/antagonist/vampire/vampire as anything in GLOB.all_vampires)
		var/mob/body = vampire.owner?.current
		if(!vampire.final_death && !QDELETED(body))
			vampire_amt++
	var/crew_amt = SSgamemode.get_correct_popcount() - vampire_amt
	if(crew_amt < 25 && vampire_amt > 0)
		return FALSE

/datum/round_event/antagonist/vampire/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/vampire/vampire_datum = antag_mind.add_antag_datum(/datum/antagonist/vampire)
	var/extra_levels = rand(2, 3)
	vampire_datum.vampire_level_unspent += extra_levels
	vampire_datum.free_levels_remaining = max(vampire_datum.free_levels_remaining - extra_levels, 0)
