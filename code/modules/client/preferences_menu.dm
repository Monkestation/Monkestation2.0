DEFINE_VERB(/client, open_character_preferences, "Open Character Preferences", "Open Character Preferences", FALSE, "OOC")
	prefs?.open_window(PREFERENCE_PAGE_CHARACTERS)

DEFINE_VERB(/client, open_game_preferences, "Open Game Preferences", "Open Game Settings", FALSE, "OOC")
	prefs?.open_window(PREFERENCE_PAGE_SETTINGS)

DEFINE_VERB(/client, open_volume_mixer, "Volume Mixer", "Open Volume Mixer", FALSE, "OOC")
	prefs?.open_window(PREFERENCE_PAGE_PREFERENCES_VOLUME)
