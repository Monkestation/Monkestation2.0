MENTOR_VERB(mentor_follow, R_MENTOR, FALSE, "Mentor Follow", "Visually follow a mob.", MENTOR_CATEGORY_MAIN, mob/living/followed_guy in world)
	if(isnull(followed_guy))
		return
	user.mob.reset_perspective(followed_guy)
	add_verb(user, /client/proc/mentor_unfollow)
	to_chat(GLOB.admins, span_adminooc("<span class='prefix'>MENTOR:</span> <EM>[key_name(user)]</EM> is now following <EM>[key_name(followed_guy)]</span>"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	to_chat(user, span_info("Click the \"Stop Following\" button in the Mentor tab to stop following [key_name(followed_guy)]."), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	log_mentor("[key_name(user)] began following [key_name(followed_guy)]")
	BLACKBOX_LOG_MENTOR_VERB("Mentor Follow")

/client/proc/mentor_unfollow()
	set category = "Mentor"
	set name = "Stop Following"
	set desc = "Stop following the followed mob."

	remove_verb(src, /client/proc/mentor_unfollow)
	to_chat(GLOB.admins, span_adminooc("<span class='prefix'>MENTOR:</span> <EM>[key_name(usr)]</EM> is no longer following <EM>[key_name(eye)]</span>"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	log_mentor("[key_name(usr)] stopped following [key_name(eye)]")
	usr.reset_perspective()
