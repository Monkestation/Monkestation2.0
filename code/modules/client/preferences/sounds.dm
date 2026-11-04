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

/datum/preference/choiced/sound_tts
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts/init_possible_values()
	return list(TTS_SOUND_ENABLED, TTS_SOUND_BLIPS, TTS_SOUND_OFF)

/datum/preference/choiced/sound_tts/create_default_value()
	return TTS_SOUND_ENABLED

/datum/preference/choiced/sound_tts_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_radio"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts_radio/init_possible_values()
	return list(TTS_SOUND_ALL_RADIO, TTS_SOUND_DEPARTMENTAL_RADIO, TTS_SOUND_NO_RADIO)

/datum/preference/choiced/sound_tts_radio/create_default_value()
	return TTS_SOUND_ALL_RADIO

/datum/preference/toggle/sound_tts_hear_self_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_hear_self_radio"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE // turn this on at your own peril

/// Whether or not to hear curator music.
/datum/preference/toggle/hear_music
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hearmusic"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE
