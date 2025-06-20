/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"

	var/msg = "<b>Current Mentors:</b>\n"
	//Admin version
	if(holder)
		for(var/client/mentor_clients in GLOB.mentors)
			msg += "\t[mentor_clients] is a "

			if(GLOB.deadmins[mentor_clients.ckey])
				msg += "Deadmin "
			if(mentor_clients.mentor_datum.check_for_rights(R_MENTOR))
				if(mentor_clients.mentor_datum.check_for_rights(R_HEADMENTOR))
					msg += "Head Mentor "
				else
					msg += mentor_clients.mentor_datum.is_contributor ? "Contributor " : "Mentor "

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
			if(GLOB.deadmins[mentor_clients.ckey])
				continue

			if(mentor_clients.mentor_datum.check_for_rights(R_MENTOR))
				msg += mentor_clients.mentor_datum.is_contributor ? "\t[mentor_clients] is a Mentor\n" : "\t[mentor_clients] is a Mentor\n"

	to_chat(src, msg)
