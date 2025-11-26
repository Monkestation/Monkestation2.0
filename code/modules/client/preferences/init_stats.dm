/datum/preference/toggle/show_init_stats
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "show_init_stats"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/show_init_stats/apply_to_client_updated(client/client, value)
	if(isnewplayer(client.mob))
		SStitle?.maptext_holder?.check_client(client)
