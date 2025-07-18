ADMIN_VERB(kick_player_by_ckey, R_ADMIN, FALSE, "Kick Player (by ckey)", "Kicks a player by their ckey.", ADMIN_CATEGORY_MAIN)
	var/client/to_kick = input(user, "Select a ckey to kick.", "Select a ckey") as null|anything in sort_list(GLOB.clients)
	if(!to_kick)
		return

	var/confirmation = alert(user, "Kick [key_name(to_kick)]?", "Confirm", "Yes", "No")
	if(confirmation != "Yes")
		return

	kick_client(to_kick)
