/atom/movable
	var/datum/atom_voice/voice = null
	/// When barks are queued, this gets passed to the bark proc. If long_bark_start_time doesn't match the args passed to the bark proc (if passed at all), then the bark simply doesn't play. Basic curtailing of spam~
	var/long_bark_start_time = -1

/atom/movable/proc/initial_bark_id()
	return null

/atom/movable/proc/get_voice()
	RETURN_TYPE(/datum/atom_voice/)
	if (voice)
		return voice
	voice = new()
	voice.set_bark(initial_bark_id())
	return voice

/// Sets the vocal bark for the atom, using the bark's ID
/atom/movable/proc/set_bark(id)
	if (voice)
		voice.set_bark(id)
	else
		voice = new()
		voice.set_bark(id)

/atom/movable/proc/can_long_bark()
	return FALSE

/mob/initial_bark_id()
	return pick(GLOB.random_voice_packs)

/mob/can_long_bark()
	return !isnull(client)
