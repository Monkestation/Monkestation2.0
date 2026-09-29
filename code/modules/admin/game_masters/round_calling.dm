///Global var for tracking who has called the round
GLOBAL_VAR_INIT(called_gamemaster, null)

ADMIN_VERB(call_round, R_ADMIN, FALSE, "Call Round", "Call the round as its game master", ADMIN_CATEGORY_GAME)
	if(user.ckey == GLOB.called_gamemaster)
		tgui_alert(user, "You have already called this round!")
		return
	if(GLOB.called_gamemaster)
		var/return_option = tgui_alert(user, "Another game master has already called the round, do you wish to override their call?", "Override Call", list("Yes", "No"))
		if(return_option == "Yes")
			var/previous_call = GLOB.called_gamemaster
			GLOB.called_gamemaster = user.ckey
			message_admins("[key_name_admin(user)] override previous game master's call [key_name_admin(previous_call)].")
		else
			return
	else
		GLOB.called_gamemaster = user.ckey

	message_admins("[key_name_admin(GLOB.called_gamemaster)] has called the round.")
	BLACKBOX_LOG_ADMIN_VERB("Call Round")
