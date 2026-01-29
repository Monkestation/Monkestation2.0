/datum/preference/toggle/mapvote_hud
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "mapvote_hud"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/mapvote_autoclose
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "mapvote_autoclose"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/mapvote_autoclose/is_accessible(datum/preferences/preferences)
	return ..() && preferences.read_preference(/datum/preference/toggle/mapvote_hud)
