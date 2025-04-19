GLOBAL_DATUM_INIT(lobby_media, /datum/media_source/lobby, new)

/// A media source for lobby music.
/datum/media_source/lobby
	volume = 85
	mixer_channel = CHANNEL_LOBBYMUSIC

/datum/media_source/lobby/get_priority(mob/target)
	if(CONFIG_GET(flag/disallow_title_music))
		return -1
	if(target?.client?.prefs?.read_preference(/datum/preference/toggle/sound_lobby))
		return INFINITY
	return -1
