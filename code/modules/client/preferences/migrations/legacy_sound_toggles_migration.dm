/// Previously, sound preferences were legacy toggles.
/// PR #71040 changed these to modern toggles.
/// This migration transfers the player's existing preferences into the new toggles

/datum/preferences/proc/migrate_legacy_sound_toggles(savefile/savefile)
	if(!(toggles & 1<<2))
		channel_volume["[CHANNEL_AMBIENCE]"] = 0
	if(!(toggles & 1<<3))
		channel_volume["[CHANNEL_LOBBYMUSIC]"] = 0
	if(!(toggles & 1<<8))
		channel_volume["[CHANNEL_BUZZ]"] = 0
	if(!(toggles & 1<<11))
		channel_volume["[CHANNEL_ANNOUNCEMENTS_VOX]"] = 0
	write_preference(GLOB.preference_entries[/datum/preference/toggle/sound_combatmode], toggles & 1<<22)
	write_preference(GLOB.preference_entries[/datum/preference/toggle/sound_instruments], toggles & 1<<7)
	write_preference(GLOB.preference_entries[/datum/preference/toggle/sound_midi], toggles & 1<<1)
