/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/hear_music
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hearmusic"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/hear_music/apply_to_client_updated(client/client, value)
	if(QDELETED(GLOB.dj_booth) || isnewplayer(client.mob) || !SSticker.HasRoundStarted())
		return
	if(value)
		if(GLOB.dj_booth.broadcasting && !(client in GLOB.dj_booth.active_listeners))
			GLOB.dj_booth.active_listeners |= client
			INVOKE_ASYNC(GLOB.dj_booth, TYPE_PROC_REF(/obj/machinery/cassette/dj_station, start_playing), list(client))
	else
		if(client in GLOB.dj_booth.active_listeners)
			GLOB.dj_booth.active_listeners -= client
			GLOB.youtube_exempt["dj-station"] -= client
			client.tgui_panel?.stop_music()
