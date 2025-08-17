MENTOR_VERB(cmd_mentor_say, R_MENTOR, FALSE, "Mentorsay", "Send a message to other mentors.", MENTOR_CATEGORY_MAIN, message as text)
	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(!message)
		return

	var/prefix = "MENTOR"
	var/prefix_color = "#E236D8"
	if(check_rights_for(user, R_ADMIN, 0))
		prefix = "STAFF"
		prefix_color = "#8A2BE2"
	else if(user.mentor_datum.is_contributor)
		prefix = "CONTRIB"
		prefix_color = "#16ABF9"

	SSplexora.relay_mentor_say(user, html_decode(message), prefix)
	message = emoji_parse(message)

	var/list/pinged_mentor_clients = check_mentor_pings(message)
	if(length(pinged_mentor_clients) && pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX])
		message = pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX]
		pinged_mentor_clients -= ASAY_LINK_PINGED_ADMINS_INDEX

	for(var/iter_ckey in pinged_mentor_clients)
		var/client/iter_mentor_client = pinged_mentor_clients[iter_ckey]
		if(iter_mentor_client?.mentor_datum.dementored)
			continue
		window_flash(iter_mentor_client)
		SEND_SOUND(iter_mentor_client.mob, sound('sound/misc/bloop.ogg'))

	log_mentor("MSAY: [key_name(user)] : [message]")
	message = keywords_lookup(message)
	message = "<b><font color = '[prefix_color]'><span class='prefix'>[prefix]:</span> <EM>[key_name(user, 0, 0)]</EM>: <span class='message linkify'>[message]</span></font></b>"

	to_chat(GLOB.admins | GLOB.mentors,
		type = MESSAGE_TYPE_MODCHAT,
		html = message,
		confidential = TRUE)

	BLACKBOX_LOG_MENTOR_VERB("Msay")

// Checks a given message to see if any of the words contain an active mentor's ckey with an @ before it
/proc/check_mentor_pings(message)
	var/list/msglist = splittext(message, " ")
	var/list/mentors_to_ping = list()

	var/i = 0
	for(var/word in msglist)
		i++
		if(!length(word))
			continue
		if(word[1] != "@")
			continue
		var/ckey_check = ckey(copytext(word, 2))
		var/client/client_check = GLOB.directory[ckey_check]
		if(client_check?.mentor_datum?.check_for_rights(R_MENTOR))
			msglist[i] = "<u>[word]</u>"
			mentors_to_ping[ckey_check] = client_check

	if(length(mentors_to_ping))
		mentors_to_ping[ASAY_LINK_PINGED_ADMINS_INDEX] = jointext(msglist, " ")
		return mentors_to_ping

/client/proc/get_mentor_say()
	var/msg = input(src, null, "msay \"text\"") as text|null
	SSadmin_verbs.dynamic_invoke_mentor_verb(src, /datum/mentor_verb/cmd_mentor_say, msg)
