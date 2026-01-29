/datum/round_event_control
	///do we check against the antag cap before attempting a spawn?
	var/checks_antag_cap = FALSE
	/// List of enemy roles, will check if x amount of these exist exist
	var/list/enemy_roles
	///required number of enemies in roles to exist
	var/required_enemies = 0

/datum/round_event_control/proc/return_failure_string(players_amt)
	var/string
	if(roundstart && (world.time-SSticker.round_start_time >= 2 MINUTES))
		string += "Roundstart"
	if(occurrences >= max_occurrences)
		if(string)
			string += ","
		string += "Cap Reached"
	if(earliest_start >= world.time-SSticker.round_start_time)
		if(string)
			string += ","
		string +="Too Soon"
	if(players_amt < min_players)
		if(string)
			string += ","
		string += "Lack of players"
	if(holidayID && !check_holidays(holidayID))
		if(string)
			string += ","
		string += "Holiday Event"
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		if(string)
			string += ","
		string += "Round End"
	if(checks_antag_cap)
		if(!roundstart && !SSgamemode.can_inject_antags())
			if(string)
				string += ","
			string += "Too Many Antags"
	return string

/// Check if our enemy_roles requirement is met, if return_players is set then we will return the list of enemy players instead
/datum/round_event_control/proc/check_enemies(return_players = FALSE)
	if(!length(enemy_roles))
		return return_players ? list() : TRUE

	var/job_check = 0
	var/list/enemy_players = list()
	if(roundstart)
		for(var/enemy in enemy_roles)
			var/datum/job/enemy_job = SSjob.GetJob(enemy)
			if(enemy_job && SSjob.assigned_players_by_job[enemy_job.type])
				job_check += length(SSjob.assigned_players_by_job[enemy_job.type])
				enemy_players += SSjob.assigned_players_by_job[enemy_job.type]

	else
		for(var/mob/living/player in GLOB.alive_player_list)
			if(player.stat == DEAD)
				continue // Dead players cannot count as opponents

			if(player.mind && (player.mind.assigned_role.title in enemy_roles))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that
				enemy_players += player

	return return_players ? enemy_players : job_check >= required_enemies

/datum/round_event_control/proc/generate_image(list/mobs)
	return

/datum/round_event_control/antagonist
	typepath = /datum/round_event/antagonist
	checks_antag_cap = TRUE
	track = EVENT_TRACK_ROLESET
	dont_spawn_near_roundend = TRUE
	///list of required roles, needed for this to form
	var/list/required_roles
	/// Protected roles from the antag roll. People will not get those roles if a config is enabled
	var/list/protected_roles
	/// Restricted roles from the antag roll
	var/list/restricted_roles
	///Our credits banner icon
	var/event_icon_state
	/// How many baseline antags do we spawn
	var/base_antags = 1 //this seems to not actually get scaled
	/// How many maximum antags can we spawn
	var/maximum_antags = 2
	/// For this many players we'll add 1 up to the maximum antag amount
	var/denominator = 26
	/// The antag flag to be used
	var/antag_flag
	/// The antag datum to be applied
	var/antag_datum
	/// Prompt players for consent to turn them into antags before doing so. Dont allow this for roundstart.
	var/prompted_picking = FALSE
	/// A list of extra events to force whenever this one is chosen by the storyteller.
	/// Can either be normal list or a weighted list.
	var/list/extra_spawned_events
	/// Similar to extra_spawned_events however these are only used by roundstart events and will only try and run if we have the points to do so
	var/list/preferred_events

/datum/round_event_control/antagonist/New()
	. = ..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles |= protected_roles

/datum/round_event_control/antagonist/return_failure_string(players_amt)
	. =..()
	if(!check_enemies())
		if(.)
			. += ", "
		. += "No Enemies"
	if(!check_required_roles())
		if(.)
			. += ", "
		. += "No Required"
	var/antag_amt = get_antag_amount()
	var/list/candidates = get_candidates() //we should optimize this
	if(length(candidates) < antag_amt)
		if(.)
			. += ", "
		. += "Not Enough Candidates!"
	return .

/datum/round_event_control/antagonist/generate_image(list/mobs)
	SScredits.generate_major_icon(mobs, event_icon_state)

/datum/round_event_control/antagonist/proc/check_required_roles()
	if(!length(required_roles))
		return TRUE
	for (var/mob/M in GLOB.alive_player_list)
		if (M.stat == DEAD)
			continue
		if(M.mind && (M.mind.assigned_role.title in required_roles))
			return TRUE

/datum/round_event_control/antagonist/proc/trim_candidates(list/candidates)
	return candidates

/datum/round_event_control/antagonist/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return
	if(!check_required_roles())
		return FALSE
	/*var/list/recent_storyteller_events = SSgamemode.recent_storyteller_events
	if(shared_occurence_type == SHARED_HIGH_THREAT && length(recent_storyteller_events))
		var/list/last_round = recent_storyteller_events[1] //TODO: change this to a weight reduction
		if(type in last_round)
			return FALSE
		for(var/datum/round_event_control/event as anything in last_round)
			if(event::shared_occurence_type == shared_occurence_type)
				return FALSE*/ //temp removal to see if this causes issues or not
	var/antag_amt = get_antag_amount()
	var/list/candidates = get_candidates()
	if(length(candidates) < antag_amt)
		return FALSE

/datum/round_event_control/antagonist/proc/get_antag_amount()
	var/people = SSgamemode.get_correct_popcount()
	var/amount = base_antags + FLOOR(people / denominator, 1)
	return min(amount, maximum_antags)

/datum/round_event_control/antagonist/proc/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/new_players_arg = round_started ? FALSE : TRUE
	var/living_players_arg = round_started ? TRUE : FALSE
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, FALSE, new_players_arg, living_players_arg, midround_antag_pref = midround_antag_pref_arg, \
													restricted_roles = restricted_roles, required_roles = required_roles)
	candidates = trim_candidates(candidates)
	return candidates

/datum/round_event_control/antagonist/from_ghosts

/datum/round_event_control/antagonist/from_ghosts/get_candidates()
	var/round_started = SSticker.HasRoundStarted()
	var/midround_antag_pref_arg = round_started ? FALSE : TRUE

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, observers = TRUE, midround_antag_pref = midround_antag_pref_arg, restricted_roles = restricted_roles)
	candidates = trim_candidates(candidates)
	return candidates
