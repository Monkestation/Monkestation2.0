ADMIN_VERB(play_sound, R_SOUND, FALSE, "Play Global Sound", "Play a sound to all connected players.", ADMIN_CATEGORY_FUN, sound as sound)
	var/freq = 1
	var/vol = tgui_input_number(user, "What volume would you like the sound to play at?", max_value = 100)
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = sound
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = tgui_alert(user, "Show the title of this song to the players?",, list("Yes","No", "Cancel"))
	switch(res)
		if("Yes")
			to_chat(world, span_boldannounce("An admin played: [sound]"), confidential = TRUE)
		if("Cancel")
			return

	log_admin("[key_name(user)] played sound [sound]")
	message_admins("[key_name_admin(user)] played sound [sound]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.read_preference(/datum/preference/toggle/sound_midi))
			admin_sound.volume = vol * M.client.admin_music_volume
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol

	BLACKBOX_LOG_ADMIN_VERB("Play Global Sound")

ADMIN_VERB(play_local_sound, R_SOUND, FALSE, "Play Local Sound", "Plays a sound only you can hear.", ADMIN_CATEGORY_FUN, sound as sound)
	log_admin("[key_name(user)] played a local sound [sound]")
	message_admins("[key_name_admin(user)] played a local sound [sound]")
	playsound(get_turf(user.mob), sound, 50, FALSE, FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Play Local Sound")

ADMIN_VERB(play_direct_mob_sound, R_SOUND, FALSE, "Play Direct Mob Sound", "Play a sound directly to a mob.", ADMIN_CATEGORY_FUN, sound as sound, mob/target in world)
	if(!target)
		target = input(user, "Choose a mob to play the sound to. Only they will hear it.", "Play Mob Sound") as null | anything in sort_names(GLOB.player_list)
	if(QDELETED(target))
		return
	log_admin("[key_name(user)] played a direct mob sound [sound] to [key_name_admin(target)].")
	message_admins("[key_name_admin(user)] played a direct mob sound [sound] to [ADMIN_LOOKUPFLW(target)].")
	SEND_SOUND(target, sound)
	BLACKBOX_LOG_ADMIN_VERB("Play Direct Mob Sound")

///Takes an input from either proc/play_web_sound or the request manager and runs it through youtube-dl and prompts the user before playing it to the server.
/proc/web_sound(mob/user, input)
	if(!check_rights(R_SOUND))
		return
	if(!CONFIG_GET(string/floxy_url))
		to_chat(user, span_boldwarning("Floxy was not configured, action unavailable."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	var/list/music_extra_data = list()
	if(istext(input))
		var/list/info = SSfloxy.download_and_wait(input, timeout = 30 SECONDS, discard_failed = TRUE)
		if(!info)
			to_chat(user, span_boldwarning("Failed to fetch [input]"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		else if(info["status"] != FLOXY_STATUS_COMPLETED)
			to_chat(user, span_boldwarning("Floxy returned status '[info["status"]]' while trying to fetch [input]"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		if(length(info["endpoints"]))
			web_sound_url = info["endpoints"][1]
		else
			log_floxy("Floxy did not return a music endpoint for [input]")
			to_chat(user, span_boldwarning("Floxy did not return an endpoint for [input]! That's weird!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		var/list/metadata = info["metadata"]
		var/webpage_url = info["url"]
		var/title = webpage_url
		var/duration = 0
		if(metadata)
			if(metadata["title"])
				title = metadata["title"]
			if(metadata["url"])
				webpage_url = "<a href=\"[metadata["url"]]\">[title]</a>"
			if(metadata["duration"])
				duration = metadata["duration"] * 1 SECONDS
				music_extra_data["duration"] = DisplayTimeText(duration)
			if(metadata["artist"])
				music_extra_data["artist"] = metadata["artist"]
			if(metadata["album"])
				music_extra_data["album"] = metadata["album"]
		if (duration > 10 MINUTES)
			if((tgui_alert(user, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning!", list("No", "Yes", "Cancel")) != "Yes"))
				return
		var/res = tgui_input_list(user, "Show the title of and link to this song to the players?\n[title]", "Show Info?", list("Yes", "No", "Custom Title", "Cancel")) // MONKESTATION EDIT - Custom title
		switch(res)
			if("Yes")
				music_extra_data["title"] = title
				music_extra_data["link"] = info["url"]
			if("No")
				music_extra_data["link"] = "Song Link Hidden"
				music_extra_data["title"] = "Song Title Hidden"
				music_extra_data["artist"] = "Song Artist Hidden"
				music_extra_data["album"] = "Song Album Hidden"
			if("Custom Title")
				var/custom_title = tgui_input_text(user, "Enter the title to show to players", "Custom sound info", null)
				if (!length(custom_title))
					tgui_alert(user, "No title specified, using default.", "Custom sound info", list("Okay"))
				else
					music_extra_data["title"] = custom_title
			if("Cancel", null)
				return
		var/anon = tgui_alert(user, "Display who played the song?", "Credit Yourself?", list("Yes", "No", "Cancel"))
		switch(anon)
			if("Yes")
				if(res == "Yes")
					to_chat(world, span_boldannounce("[user.key] played: [webpage_url]"), type = MESSAGE_TYPE_OOC, confidential = TRUE)
				else
					to_chat(world, span_boldannounce("[user.key] played a sound"), type = MESSAGE_TYPE_OOC, confidential = TRUE)
			if("No")
				if(res == "Yes")
					to_chat(world, span_boldannounce("An admin played: [webpage_url]"), type = MESSAGE_TYPE_OOC, confidential = TRUE)
			if("Cancel", null)
				return
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
		log_admin("[key_name(user)] played web sound: [input]")
		message_admins("[key_name(user)] played web sound: [webpage_url]")
	else
		//pressed ok with blank
		log_admin("[key_name(user)] stopped web sounds.")

		message_admins("[key_name(user)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !is_http_protocol(web_sound_url))
		tgui_alert(user, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", list("OK"))
		to_chat(user, span_boldwarning("BLOCKED: Content URL not using HTTP(S) Protocol!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

		return
	if(web_sound_url || stop_web_sounds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if(C.prefs.read_preference(/datum/preference/toggle/sound_midi))
				if(!stop_web_sounds)
					C.tgui_panel?.play_music(web_sound_url, music_extra_data)
					C.media_player?.stop()
				else
					C.tgui_panel?.stop_music()

	BLACKBOX_LOG_ADMIN_VERB("Play Internet Sound")

ADMIN_VERB_CUSTOM_EXIST_CHECK(play_web_sound)
	return !!CONFIG_GET(string/floxy_url)

ADMIN_VERB(play_web_sound, R_SOUND, FALSE, "Play Internet Sound", "Play a given internet sound to all players.", ADMIN_CATEGORY_FUN)
	var/web_sound_input = tgui_input_text(user, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound", null)

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !is_http_protocol(web_sound_input))
			to_chat(user, span_boldwarning("Non-http(s) URIs are not allowed."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			to_chat(user, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full URL from the website."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
		web_sound(user, shell_scrubbed_input)
	else
		web_sound(user, null)

ADMIN_VERB(set_round_end_sound, R_SOUND, FALSE, "Set Round End Sound", "Set the sound that plays on round end.", ADMIN_CATEGORY_FUN, sound as sound)
	SSticker.SetRoundEndSound(sound)

	log_admin("[key_name(user)] set the round end sound to [sound]")
	message_admins("[key_name_admin(user)] set the round end sound to [sound]")
	BLACKBOX_LOG_ADMIN_VERB("Set Round End Sound")

ADMIN_VERB(stop_sounds, R_NONE, FALSE, "Stop All Playing Sounds", "Stops all playing sounds for EVERYONE.", ADMIN_CATEGORY_DEBUG)
	log_admin("[key_name(user)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(user)] stopped all currently playing sounds.")
	for(var/mob/player as anything in GLOB.player_list)
		SEND_SOUND(player, sound(null))
		var/client/player_client = player.client
		player_client?.tgui_panel?.stop_music()
	BLACKBOX_LOG_ADMIN_VERB("Stop All Playing Sounds")
