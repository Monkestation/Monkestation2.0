/// Controls hearing the combat mode toggle sound
/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_combatmode"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_achievement
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_achievement"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_achievement/init_possible_values()
	return list(CHEEVO_SOUND_PING, CHEEVO_SOUND_JINGLE, CHEEVO_SOUND_TADA, CHEEVO_SOUND_OFF)

/datum/preference/choiced/sound_achievement/create_default_value()
	return CHEEVO_SOUND_PING

/datum/preference/choiced/sound_achievement/apply_to_client_updated(client/client, value)
	var/sound/sound_to_send = LAZYACCESS(GLOB.achievement_sounds, value)
	if(sound_to_send)
		SEND_SOUND(client.mob, sound_to_send)

/// Whether or not to hear curator music.
/datum/preference/toggle/hear_music
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hearmusic"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE
