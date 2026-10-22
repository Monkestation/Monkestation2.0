/client/verb/mentorwho()
	set category = "Mentor"
	set name = "Mentorwho"

	var/msg = "<b>Current Mentors:</b>\n"
	//Admin version
	if(holder)
		for(var/client/mentor_clients in GLOB.mentors)
			if(!check_mentor_rights_for(mentor_clients, R_MENTOR))
				continue

			msg += "\t[mentor_clients] is "

			if(GLOB.dementors[mentor_clients.ckey])
				msg += "Dementored "

			msg += "a [join_mentor_ranks(mentor_clients.mentor_datum.ranks)] "
			msg += mentor_clients.mentor_datum.is_contributor ? "and Contributor " : ""

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

			if(check_mentor_rights_for(mentor_clients, R_HEADMENTOR))
				msg += "\t[mentor_clients] is a Head Mentor"
			else if(check_mentor_rights_for(mentor_clients, R_MENTOR))
				msg += "\t[mentor_clients] is a Mentor"
			else
				continue
			msg += mentor_clients.mentor_datum.is_contributor ? " and Contributor\n" : "\n"

	to_chat(src, msg)
