GAME_VERB_DESC(/client, open_character_preferences, "Open Character Preferences", "Open Character Preferences", "OOC")

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_CHARACTERS)

GAME_VERB_DESC(/client, open_game_preferences, "Open Game Preferences", "Open Game Preferences", "OOC")

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_SETTINGS)

GAME_VERB_DESC(/client, open_volume_mixer, "Volume Mixer", "Open Volume Mixer", "OOC")

	usr?.client?.prefs?.open_window(PREFERENCE_PAGE_PREFERENCES_VOLUME)
