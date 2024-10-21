///Takes an input from either proc/play_web_sound or the request manager and runs it through youtube-dl and prompts the user before playing it to the server.
/proc/web_sound(mob/user, input)
	if(!check_rights(R_SOUND))
		return
	if(!CONFIG_GET(string/yt_wrap_url))
		to_chat(user, span_boldwarning("ss13-yt-wrap was not configured, action unavailable"), confidential = TRUE)
		return
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	var/show_info = TRUE
	var/datum/internet_audio/audio
	if(istext(input))
		audio = fetch_internet_audio_cached(input)
		if(!audio.wait())
			to_chat(
				user,
				examine_block("[span_big(span_bolddanger("Failed to get web sound"))]\n[span_warning("[audio.error || "(unknown error)"]")]"),
				type = MESSAGE_TYPE_ADMINLOG,
				confidential = TRUE
			)
			return
		web_sound_url = audio.sound_url
		if (audio.duration > 10 MINUTES)
			if((tgui_alert(user, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning!", list("No", "Yes", "Cancel")) != "Yes"))
				return
		var/res = tgui_input_list(
			user,
			"Show the title of and link to this song to the players?\n[audio.title]",
			"Show Info?",
			list("Yes", "No", "Custom Title", "Cancel")
		)
		switch(res)
			if("Yes")
				EMPTY_BLOCK_GUARD
			if("No")
				show_info = FALSE
			if("Custom Title")
				var/custom_title = tgui_input_text(user, "Enter the title to show to players", "Custom sound info", null, encode = FALSE)
				if(!length(custom_title))
					tgui_alert(user, "No title specified, using default.", "Custom sound info", list("Okay"))
				else
					audio.title = custom_title
			if("Cancel", null)
				return
		var/anon = tgui_alert(user, "Display who played the song?", "Credit Yourself?", list("Yes", "No", "Cancel"))
		switch(anon)
			if("Yes")
				if(res == "Yes")
					to_chat(world, span_boldannounce("[user.key] played: <a href='[audio.webpage_url]'>[html_encode(audio.title)]</a>"))
				else
					to_chat(world, span_boldannounce("[user.key] played a sound"))
			if("No")
				if(res == "Yes")
					to_chat(world, span_boldannounce("An admin played: <a href='[audio.webpage_url]'>[html_encode(audio.title)]</a>"))
			if("Cancel", null)
				return
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
		log_admin("[key_name(user)] played web sound: [input]")
		message_admins("[key_name(user)] played web sound: [input]")
	else
		//pressed ok with blank
		log_admin("[key_name(user)] stopped web sounds.")
		message_admins("[key_name(user)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		tgui_alert(user, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", list("OK"))
		to_chat(user, span_boldwarning("BLOCKED: Content URL not using HTTP(S) Protocol!"), confidential = TRUE)
		return
	if(web_sound_url || stop_web_sounds)
		for(var/mob/player as anything in GLOB.player_list)
			var/client/client = player.client
			if(!client?.prefs?.read_preference(/datum/preference/toggle/sound_midi))
				continue
			if(stop_web_sounds)
				client?.tgui_panel?.stop_music()
			else
				audio.play_to_client(client, show_info)
	audio?.started_at = REALTIMEOFDAY

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")


/client/proc/play_web_sound()
	set category = "Admin.Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUND))
		return
	if(!CONFIG_GET(string/yt_wrap_url))
		to_chat(src, span_boldwarning("ss13-yt-wrap was not configured, action unavailable"), confidential = TRUE)
		return

	var/web_sound_input = tgui_input_text(usr, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound", null)

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(src, span_boldwarning("Non-http(s) URIs are not allowed."), confidential = TRUE)
			to_chat(src, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full URL from the website."), confidential = TRUE)
			return
		web_sound(usr, web_sound_input)
	else
		web_sound(usr, null)
