/proc/format_mhelp_embed(message, id, ckey)
	var/datum/discord_embed/embed = new()
	embed.title = "Mentor Help"
	embed.description = @"[Join Server!](http://play.monkestation.com:7420)"
	embed.author = key_name(ckey)
	var/round_state
	var/admin_text
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			round_state = "Round has not started"
		if(GAME_STATE_PLAYING)
			round_state = "Round is ongoing."
			if(SSshuttle.emergency.getModeStr())
				round_state += "\n[SSshuttle.emergency.getModeStr()]: [SSshuttle.emergency.getTimerStr()]"
				if(SSticker.emergency_reason)
					round_state += ", Shuttle call reason: [SSticker.emergency_reason]"
		if(GAME_STATE_FINISHED)
			round_state = "Round has ended"
	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	embed.fields = list(
		"MENTOR ID" = id,
		"CKEY" = ckey,
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = ROUND_TIME(),
		"MESSAGE" = message,
		"ADMINS" = admin_text,
	)
	return embed

/client/verb/mentorhelp(message as text)
	set category = "Mentor"
	set name = "Mentorhelp"

	if(usr?.client?.prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<span class='danger'>Error: MentorPM: You are muted from Mentorhelps. (muted).</span>",
			confidential = TRUE)
		return
	/// Cleans the input message
	if(!message)
		return
	/// This shouldn't happen, but just in case.
	if(!mob)
		return

	message = sanitize(copytext(message,1,MAX_MESSAGE_LEN))
	var/mentor_msg = "<font color='purple'><span class='mentornotice'><b>MENTORHELP:</b> <b>[key_name_mentor(src, TRUE, FALSE)]</b> : </span><span class='message linkify'>[message]</span></font>"
	var/mentor_msg_observing = "<span class='mentornotice'><b><span class='mentorhelp'>MENTORHELP:</b> <b>[key_name_mentor(src, TRUE, FALSE)]</b> (<a href='byond://?_src_=mentor;[MentorHrefToken(TRUE)];mentor_friend=[REF(src.mob)]'>IF</a>) : [message]</span></span>"
	log_mentor("MENTORHELP: [key_name_mentor(src, null, FALSE, FALSE)]: [message]")

	/// Send the Mhelp to all Mentors/Admins
	for(var/client/honked_clients in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_clients?.mentor_datum) || !honked_clients?.mentor_datum?.check_for_rights(R_MENTOR))
			continue
		SEND_SOUND(honked_clients, sound('sound/items/bikehorn.ogg'))
		if(!isobserver(honked_clients.mob))
			to_chat(honked_clients,
					type = MESSAGE_TYPE_MODCHAT,
					html = mentor_msg,
					confidential = TRUE)
		else
			to_chat(honked_clients,
					type = MESSAGE_TYPE_MODCHAT,
					html = mentor_msg_observing,
					confidential = TRUE)

	/// Also show it to person Mhelping
	to_chat(usr,
		type = MESSAGE_TYPE_MODCHAT,
		html = "<font color='purple'><span class='mentornotice'>PM to-<b>Mentors</b>:</span> <span class='message linkify'>[message]</span></font>",
		confidential = TRUE)

	GLOB.mentor_requests.mentorhelp(usr.client, message)
	var/datum/request/request = GLOB.mentor_requests.requests[ckey][length(GLOB.mentor_requests.requests[ckey])]
	if(request)
		SSplexora.mticket_new(request)
	return
