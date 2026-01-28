#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event_control/antagonist/vampire
#else
/datum/round_event_control/antagonist/solo/vampire
#endif
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
	weight = 10
	base_antags = 3
	maximum_antags = 4
	event_icon_state = "vampires"

#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event_control/antagonist/vampire/roundstart
#else
/datum/round_event_control/antagonist/solo/vampire/roundstart
#endif
	name = "Vampires"
	roundstart = TRUE
	earliest_start = 0 SECONDS

#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event_control/antagonist/vampire/midround
#else
/datum/round_event_control/antagonist/solo/vampire/midround
#endif
	name = "Vampiric Accident"
#ifdef STORYTELLER_TRACK_BOOSTER
	typepath = /datum/round_event/antagonist/vampire
#else
	typepath = /datum/round_event/antagonist/solo/vampire
#endif
	antag_flag = ROLE_VAMPIRIC_ACCIDENT
	prompted_picking = TRUE
	max_occurrences = 1

#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event_control/antagonist/vampire/midround/get_weight()
#else
/datum/round_event_control/antagonist/solo/vampire/midround/get_weight()
#endif
	. = ..()
	// if there's only one or two vamps, let's raise the chance of giving them some friends
	var/vampire_count = length(GLOB.all_vampires)
	if(vampire_count == 1)
		. *= 2
	else if(vampire_count == 2)
		. *= 1.5

#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event_control/antagonist/vampire/midround/get_antag_amount()
#else
/datum/round_event_control/antagonist/solo/vampire/midround/get_antag_amount()
#endif
	. = ..()
	var/vampire_amt = 0
	for(var/datum/antagonist/vampire/vampire as anything in GLOB.all_vampires)
		var/mob/body = vampire.owner?.current
		if(!vampire.final_death && !QDELETED(body))
			vampire_amt++
	if(vampire_amt >= 7)
		return min(., 1)
	else if(vampire_amt >= 4)
		return min(., 2)
	else
		return .

#ifdef STORYTELLER_TRACK_BOOSTER
/datum/round_event/antagonist/vampire/add_datum_to_mind(datum/mind/antag_mind)
#else
/datum/round_event/antagonist/solo/vampire/add_datum_to_mind(datum/mind/antag_mind)
#endif
	var/datum/antagonist/vampire/vampire_datum = antag_mind.add_antag_datum(/datum/antagonist/vampire)
	vampire_datum.vampire_level_unspent += rand(2, 3)
