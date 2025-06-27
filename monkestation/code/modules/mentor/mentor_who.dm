/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"

	var/msg = "<b>Current Mentors:</b>\n"
	//Admin version
	if(holder)
		for(var/client/mentor_clients in GLOB.mentors)
			msg += "\t[mentor_clients] is "

			if(GLOB.dementors[mentor_clients.ckey])
				msg += "Dementored "

			if(check_mentor_rights_for(mentor_clients, R_MENTOR))
				msg += "a [join_mentor_ranks(mentor_clients.mentor_datum.ranks)]"
				msg += mentor_clients.mentor_datum.is_contributor ? "Contributor " : ""

			if(isobserver(mentor_clients.mob))
				msg += "- Observing"
			else if(isnewplayer(mentor_clients.mob))
				msg += "- Lobby"
			else
				msg += "- Playing"

			if(mentor_clients.is_afk())
				msg += "(AFK)"

			msg += "\n"

	//Regular version
	else
		for(var/client/mentor_clients in GLOB.mentors)
			if(GLOB.dementors[mentor_clients.ckey])
				continue

			if(check_mentor_rights_for(mentor_clients, R_MENTOR))
				msg += mentor_clients.mentor_datum.is_contributor ? "\t[mentor_clients] is a Mentor\n" : "\t[mentor_clients] is a Mentor\n"

	to_chat(src, msg)
