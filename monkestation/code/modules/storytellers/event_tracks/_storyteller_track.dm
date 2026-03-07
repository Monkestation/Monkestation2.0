///datum corresponding to a track on the storyteller
/datum/storyteller_track //should move more stuff over to these, im just doing the bare minimum for now
	///The track ID of this track
	var/id
	///Our threshold for triggering
	var/threshold = 0
	///How many points does this track have currently
	var/points = 0

///Called whenever our points go over our threshold, please note that points must be taken somewhere within this proc
/datum/storyteller_track/proc/on_trigger(datum/storyteller/triggered_by)
	return

//event tracks
/datum/storyteller_track/event

/datum/storyteller_track/event/on_trigger(datum/storyteller/triggered_by)
	triggered_by.find_and_buy_event_from_track(id)

/datum/storyteller_track/event/mundane
	id = EVENT_TRACK_MUNDANE
	threshold = MUNDANE_POINT_THRESHOLD

/datum/storyteller_track/event/moderate
	id = EVENT_TRACK_MODERATE
	threshold = MODERATE_POINT_THRESHOLD

/datum/storyteller_track/event/major
	id = EVENT_TRACK_MAJOR
	threshold = MAJOR_POINT_THRESHOLD

/datum/storyteller_track/event/roleset
	id = EVENT_TRACK_ROLESET
	threshold = ROLESET_POINT_THRESHOLD

//should not be triggered
/datum/storyteller_track/event/objectives
	id = EVENT_TRACK_OBJECTIVES

//whenever this ticks over it gives a point to a random other track, exists to add more variabilty to event timing. TODO: allow for variable points given
/datum/storyteller_track/booster
	id = STORYTELLER_TRACK_BOOSTER
	threshold = BOOSTER_POINT_THRESHOLD

/datum/storyteller_track/booster/on_trigger(datum/storyteller/triggered_by)
	var/datum/storyteller_track/track = pick(SSgamemode.point_gain_multipliers - id)
	track = SSgamemode.event_tracks[track]
	track.points += BOOSTER_POINT_THRESHOLD / 2
	points = max(points - threshold, 0)
