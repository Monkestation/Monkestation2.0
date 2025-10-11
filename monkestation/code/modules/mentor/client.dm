/client
	///Contains mentor info. Null if client is not a mentor or a player with custom powers.
	var/datum/mentors/mentor_datum

/client/proc/add_mentor_verbs()
	control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	SSadmin_verbs.assosciate_mentor(src)

/client/proc/remove_mentor_verbs()
	control_freak = initial(control_freak)
	SSadmin_verbs.deassosciate_mentor(src)

/client/proc/rementor()
	set name = "Rementor"
	set category = "Mentor"
	set desc = "Regain your mentor powers."

	var/datum/mentors/mentor = GLOB.dementors[ckey]

	if(!mentor)
		mentor = GLOB.mentor_datums[ckey]
		if (!mentor)
			var/msg = " is trying to rementor but they have no mentor entry"
			message_admins("[key_name_mentor(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	mentor.associate(src)

	if (!mentor_datum) //Mentors can't vv so this probably doesn't apply. Keeping till otherwise noted.
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now a mentor."), confidential = TRUE)
	message_admins("[key_name_mentor(src)] re-mentored themselves.")
	log_admin("[key_name(src)] re-mentored themselves.")
	BLACKBOX_LOG_MENTOR_VERB("Rementor")

MENTOR_VERB(dementor, R_NONE, FALSE, "Dementor", "Shed your mentor powers.", MENTOR_CATEGORY_MAIN)
	user.mentor_datum.deactivate()
	to_chat(user, span_interface("You are now an unmentored player."), confidential = TRUE)
	log_admin("[key_name(user)] dementored themselves.")
	message_admins("[key_name_mentor(user)] dementored themselves.")
	BLACKBOX_LOG_MENTOR_VERB("Dementor")

// Overwrites /client/Topic to return for mentor client procs
/client/Topic(href, href_list, hsrc)
	if(mentor_client_procs(href_list))
		return
	return ..()

/client/proc/mentor_client_procs(href_list)
	if(href_list["mentor_msg"])
		cmd_mentor_pm(href_list["mentor_msg"],null)
		return TRUE

	/// Mentor Follow
	if(href_list["mentor_follow"])
		SSadmin_verbs.dynamic_invoke_mentor_verb(usr, /datum/mentor_verb/mentor_follow, locate(href_list["mentor_follow"]))
		return TRUE
