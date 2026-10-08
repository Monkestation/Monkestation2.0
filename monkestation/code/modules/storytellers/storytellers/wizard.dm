/datum/storyteller/wizard
	name = "The Wizard"
	desc = "The Wizard will spawn a great deal of magical events."
	event_repetition_multiplier = 1
	tag_multipliers = list(TAG_SPOOKY = 1.2, TAG_MAGICAL = 4, TAG_SPACE = 1.1, TAG_DESTRUCTIVE = 1.5)
	point_gains_multipliers = list(
		EVENT_TRACK_MUNDANE = 2,
		EVENT_TRACK_MODERATE = 2,
		EVENT_TRACK_MAJOR = 2,
		EVENT_TRACK_ROLESET = 2,
		)
	restricted = TRUE

/datum/storyteller/wizard/find_and_buy_event_from_track(track)
	var/datum/controller/subsystem/gamemode/mode = SSgamemode
	if(track == EVENT_TRACK_ROLESET || prob(30) || mode.forced_next_events[track])
		return ..()

//simplfied version of parent that handles buying the event as well
	mode.update_crew_infos()
	var/list/valid_events = list()
	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	for(var/datum/round_event_control/event in mode.uncategorized[WIZARD_EVENT_UNCATEGORIZED])
		if(QDELETED(event))
			mode.uncategorized[WIZARD_EVENT_UNCATEGORIZED] -= event
			message_admins("[event.name] was deleted!")
			continue

		if(event.can_spawn_event(players_amt, TRUE) && calculate_single_weight(event) > 0)
			valid_events[event] = round(event.calculated_weight * 10)

	if(!length(valid_events))
		message_admins("Storyteller failed to pick an event for track of [track].")
		var/datum/storyteller_track/track_datum = mode.event_tracks[track]
		track_datum.points -= track_datum.points - (TRACK_FAIL_POINT_PENALTY_MULTIPLIER * track_datum.points)
		return FALSE

	var/datum/round_event_control/picked_event = pick_weight(valid_events)
	var/datum/storyteller_track/track_datum = mode.event_tracks[track]
	track_datum.points = max(track_datum.points - track_datum.threshold, 0)
	message_admins("Storyteller purchased and triggered [picked_event] event, on [track] track, for [track_datum.threshold] cost.")
	//TODO: let scheduled events have an unset track so we can schedule these
	INVOKE_ASYNC(mode, TYPE_PROC_REF(/datum/controller/subsystem/gamemode, TriggerEvent), picked_event)
	SSgamemode.triggered_round_events |= picked_event.type
	return TRUE

/datum/storyteller/mystic/can_run_event(datum/round_event_control/event)
	if((TAG_MUNDANE in event.tags)) //we do not allow mundane events, those are BORING
		return FALSE
	return TRUE
