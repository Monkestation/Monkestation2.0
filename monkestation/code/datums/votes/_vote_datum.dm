/datum/vote
	/// The volume of the vote sound, from 0 to 100 or above.
	var/vote_sound_volume

/datum/vote/proc/can_vote(mob/voter)
	return TRUE
