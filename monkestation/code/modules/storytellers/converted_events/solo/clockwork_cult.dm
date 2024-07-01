#define TAGS_DEPRIORITIZED list(TAG_DESTRUCTIVE, TAG_COMMUNAL, TAG_OUTSIDER_ANTAG, TAG_EXTERNAL, TAG_ALIEN)
#define TAGS_PRIORITIZED   list(TAG_CREW_ANTAG, TAG_POSITIVE)

/datum/round_event_control/antagonist/solo/clockcult
	name = "Clock Cult"
	tags = list(TAG_SPOOKY, TAG_DESTRUCTIVE, TAG_COMBAT, TAG_TEAM_ANTAG, TAG_EXTERNAL, TAG_MAGICAL)
	antag_flag = ROLE_CLOCK_CULTIST
	antag_datum = /datum/antagonist/clock_cultist
	typepath = /datum/round_event/antagonist/solo/clockcult
	shared_occurence_type = SHARED_HIGH_THREAT
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	enemy_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 5
	base_antags = 4
	maximum_antags = 4
	// I give up, just there should be enough heads with 35 players...
	min_players = 30
	roundstart = TRUE
	earliest_start = 0 SECONDS
	weight = 4
	max_occurrences = 1

/datum/round_event/antagonist/solo/clockcult
	end_when = 60000

/datum/round_event/antagonist/solo/clockcult/setup()
	. = ..()
	ensure_competition()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_reebe))

/datum/round_event/antagonist/solo/clockcult/add_datum_to_mind(datum/mind/antag_mind)
	antag_mind.special_role = ROLE_CLOCK_CULTIST
	antag_mind.add_antag_datum(antag_datum)

/datum/round_event/antagonist/solo/clockcult/proc/ensure_competition()
	var/did_heretics_spawn = try_spawn_roundstart_heretics()
	if(!did_heretics_spawn || prob(15)) // 15% to force midround heretics anyways
		force_event_after(/datum/round_event_control/antagonist/solo/heretic/midround, "clockwork cult rivalry", rand(20 MINUTES, 30 MINUTES))
	mutate_storyteller()

/datum/round_event/antagonist/solo/clockcult/proc/mutate_storyteller()
	SSgamemode.point_gain_multipliers[EVENT_TRACK_ROLESET]++
	for(var/bad_tag in TAGS_DEPRIORITIZED)
		var/multiplier = rand(45, 75) / 100
		var/original_val = SSgamemode.storyteller.tag_multipliers?[bad_tag] || 1
		var/new_val = max(FLOOR(original_val * multiplier, 0.1), 1)
		LAZYSET(SSgamemode.storyteller.tag_multipliers, bad_tag, new_val)
	for(var/good_tag in TAGS_PRIORITIZED)
		var/multiplier = 1 + (rand(20, 45) / 100)
		var/original_val = SSgamemode.storyteller.tag_multipliers?[good_tag] || 1
		var/new_val = min(CEILING(original_val * multiplier, 0.1), 1)
		LAZYSET(SSgamemode.storyteller.tag_multipliers, good_tag, new_val)

/datum/round_event/antagonist/solo/clockcult/proc/try_spawn_roundstart_heretics()
	var/datum/round_event_control/antagonist/solo/heretic/roundstart/roundstart_heretic_event = locate() in SSgamemode.event_pools[EVENT_TRACK_ROLESET]
	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(roundstart_heretic_event?.can_spawn_event(players_amt, fake_check = TRUE))
		log_game("Forced roundstart heretics to compete with clock cult.")
		message_admins("Roundstart heretics have been spawned due to the presence of a roundstart clockwork cult!")
		INVOKE_ASYNC(roundstart_heretic_event, TYPE_PROC_REF(/datum/round_event_control, run_event), random = FALSE, event_cause = "clockwork cult rivalry")
		return TRUE
	log_game("Failed to create roundstart heretics, will try again later.")
	message_admins("Failed to spawn roundstart heretics, will try again later.")
	return FALSE

#undef TAGS_PRIORITIZED
#undef TAGS_DEPRIORITIZED
