ADMIN_VERB(summon_twitch_event, R_FUN, FALSE, "Summon Twitch Event", "Starts a twitch event with the given ID.", ADMIN_CATEGORY_FUN)
	var/datum/twitch_event/choice = tgui_input_list(user, "Choose an event", "Event Selection", subtypesof(/datum/twitch_event))
	if(!choice)
		return
	SStwitch.add_to_queue(initial(choice.id_tag), "an admin")

	log_admin("[key_name(user)] added [choice] to the Twitch Event Queue.")
	message_admins("[key_name_admin(user)] added [choice] to the Twitch Event Queue.")
	BLACKBOX_LOG_ADMIN_VERB("Summon Twitch Event")
