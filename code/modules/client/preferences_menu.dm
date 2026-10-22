/datum/verbs/menu/Preferences/verb/open_character_preferences()
	set category = "OOC"
	set name = "Open Character Preferences"
	set desc = "Open Character Preferences"

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_CHARACTERS)

/datum/verbs/menu/Preferences/verb/open_game_preferences()
	set category = "OOC"
	set name = "Open Game Preferences"
	set desc = "Open Game Settings"

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_SETTINGS)

/datum/verbs/menu/Preferences/verb/open_volume_mixer()
	set category = "OOC"
	set name = "Volume Mixer"
	set desc = "Open Volume Mixer"

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_PREFERENCES_VOLUME)
