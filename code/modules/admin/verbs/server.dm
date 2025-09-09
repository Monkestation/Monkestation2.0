// Server Tab - Server Verbs

ADMIN_VERB(toggle_random_events, R_SERVER, FALSE, "Toggle Random Events", "Toggles random events on or off.", ADMIN_CATEGORY_SERVER)
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	message_admins("[key_name_admin(user)] has [new_are ? "enabled" : "disabled"] random events.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Random Events", "[new_are ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(toggle_hub, R_SERVER, FALSE, "Toggle Hub", "Toggles the server's visilibility on the BYOND Hub.", ADMIN_CATEGORY_SERVER)
	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(user)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(user)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggled Hub Visibility", "[GLOB.hub_visibility ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(restart, R_SERVER, FALSE, "Reboot World", "Restarts the world immediately.", ADMIN_CATEGORY_SERVER)
	var/list/options = list("Regular Restart", "Regular Restart (with delay)", "Hard Restart (No Delay/Feeback Reason)", "Hardest Restart (No actions, just reboot)")
	if(world.TgsAvailable())
		options += "Server Restart (Kill and restart DD)";

	if(SSticker.admin_delay_notice)
		if(alert(user, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") != "Yes")
			return FALSE

	var/result = input(user, "Select reboot method", "World Reboot", options[1]) as null|anything in options
	if(result)
		BLACKBOX_LOG_ADMIN_VERB("Reboot World")
		var/init_by = "Initiated by [user.holder.fakekey ? "Admin" : user.key]."
		switch(result)
			if("Regular Restart")
				if(!user.is_localhost())
					if(alert(user, "Are you sure you want to restart the server?","This server is live", "Restart", "Cancel") != "Restart")
						return FALSE
				// monkestation start - plexora
				SSplexora.restart_requester = user.mob
				SSplexora.restart_type = PLEXORA_SHUTDOWN_NORMAL
				// monkestation end
				SSticker.Reboot(init_by, "admin reboot - by [user.key] [user.holder.fakekey ? "(stealth)" : ""]", 10)
			if("Regular Restart (with delay)")
				var/delay = input(user, "What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
				if(!delay)
					return FALSE
				if(!user.is_localhost())
					if(alert(user,"Are you sure you want to restart the server?","This server is live", "Restart", "Cancel") != "Restart")
						return FALSE
				// monkestation start - plexora
				SSplexora.restart_requester = user.mob
				SSplexora.restart_type = PLEXORA_SHUTDOWN_NORMAL
				// monkestation end
				SSticker.Reboot(init_by, "admin reboot - by [user.key] [user.holder.fakekey ? "(stealth)" : ""]", delay * 10)
			if("Hard Restart (No Delay, No Feedback Reason)")
				// monkestation start - plexora
				SSplexora.restart_requester = user.mob
				SSplexora.restart_type = PLEXORA_SHUTDOWN_HARD
				// monkestation end
				to_chat(world, "World reboot - [init_by]")
				world.Reboot()
			if("Hardest Restart (No actions, just reboot)")
				// monkestation start - plexora
				SSplexora.restart_requester = user.mob
				SSplexora.restart_type = PLEXORA_SHUTDOWN_HARDEST
				// monkestation end
				to_chat(world, "Hard world reboot - [init_by]")
				world.Reboot(fast_track = TRUE)
			if("Server Restart (Kill and restart DD)")
				// monkestation start - plexora
				SSplexora.restart_requester = user.mob
				SSplexora.notify_shutdown(PLEXORA_SHUTDOWN_KILLDD)
				// monkestation end
				to_chat(world, "Server restart - [init_by]")
				world.TgsEndProcess()

ADMIN_VERB(cancel_reboot, R_SERVER, FALSE, "Cancel Reboot", "Cancels a pending world reboot.", ADMIN_CATEGORY_SERVER)
	if(!SSticker.cancel_reboot(user))
		return
	SSplexora.restart_requester = null // monkestation edit: Plexora
	log_admin("[key_name(user)] cancelled the pending world reboot.")
	message_admins("[key_name_admin(user)] cancelled the pending world reboot.")
	BLACKBOX_LOG_ADMIN_VERB("Cancel Reboot")

ADMIN_VERB(end_round, R_SERVER, FALSE, "End Round", "Forcibly ends the round and allows the server to restart normally.", ADMIN_CATEGORY_SERVER)
	var/confirm = tgui_alert(user, "End the round and  restart the game world?", "End Round", list("Yes", "Cancel"))
	if(confirm != "Yes")
		return
	SSticker.force_ending = FORCE_END_ROUND
	BLACKBOX_LOG_ADMIN_VERB("End Round")

ADMIN_VERB(toggle_ooc, R_ADMIN, FALSE, "Toggle OOC", "Toggle the OOC channel on or off.", ADMIN_CATEGORY_SERVER)
	toggle_ooc()
	log_admin("[key_name(user)] toggled OOC.")
	message_admins("[key_name_admin(user)] toggled OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle OOC", "[GLOB.ooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(toggle_ooc_dead, R_ADMIN, FALSE, "Toggle Dead OOC", "Toggle the OOC channel for dead players on or off.", ADMIN_CATEGORY_SERVER)
	toggle_dooc()
	log_admin("[key_name(user)] toggled OOC.")
	message_admins("[key_name_admin(user)] toggled Dead OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead OOC", "[GLOB.dooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(start_now, R_SERVER, FALSE, "Start Now", "Start the round RIGHT NOW.", ADMIN_CATEGORY_SERVER)
	var/static/list/waiting_states = list(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
	if(!(SSticker.current_state in waiting_states))
		to_chat(user, span_warning(span_red("The game has already started!")))
		return

	if(SSticker.start_immediately)
		SSticker.start_immediately = FALSE
		SSticker.SetTimeLeft(3 MINUTES)
		to_chat(world, span_big(span_notice("The game will start in 3 minutes.")))
		SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
		message_admins(span_adminnotice("[key_name_admin(user)] has cancelled immediate game start. Game will start in 3 minutes."))
		log_admin("[key_name(user)] has cancelled immediate game start.")
		return

	if(!user.is_localhost())
		var/response = tgui_alert(user, "Are you sure you want to start the round?", "Start Now", list("Start Now", "Cancel"))
		if(response != "Start Now")
			return
	SSticker.start_immediately = TRUE

	log_admin("[key_name(user)] has started the game.")
	message_admins("[key_name_admin(user)] has started the game.")
	if(SSticker.current_state == GAME_STATE_STARTUP)
		message_admins("The server is still setting up, but the round will be started as soon as possible.")
	BLACKBOX_LOG_ADMIN_VERB("Start Now")

ADMIN_VERB(delay_round_end, R_SERVER, FALSE, "Delay Round End", "Prevent the server from restarting.", ADMIN_CATEGORY_SERVER)
	if(SSticker.delay_end)
		tgui_alert(user, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	var/delay_reason = input(user, "Enter a reason for delaying the round end", "Round Delay Reason") as null | text

	if(isnull(delay_reason))
		return

	if(SSticker.delay_end)
		tgui_alert(user, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	SSticker.delay_end = TRUE
	SSticker.admin_delay_notice = delay_reason
	if(SSticker.reboot_timer)
		SSticker.cancel_reboot(user)

	log_admin("[key_name(user)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	message_admins("[key_name_admin(user)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Delay Round End", "Reason: [delay_reason]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

ADMIN_VERB(toggle_enter, R_SERVER, FALSE, "Toggle Entering", "Toggle the ability to enter the game.", ADMIN_CATEGORY_SERVER)
	if(!SSlag_switch.initialized)
		return
	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, !SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	log_admin("[key_name(user)] toggled new player game entering. Lag Switch at index ([DISABLE_NON_OBSJOBS])")
	message_admins("[key_name_admin(user)] toggled new player game entering [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "OFF" : "ON"].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Entering", "[!SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

ADMIN_VERB(toggle_ai, R_SERVER, FALSE, "Toggle AI", "Toggle the ability to choose AI jobs.", ADMIN_CATEGORY_SERVER)
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>", confidential = TRUE)
	log_admin("[key_name(user)] toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle AI", "[!alai ? "Disabled" : "Enabled"]")) //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

ADMIN_VERB(toggle_respawn, R_SERVER, FALSE, "Toggle Respawn", "Toggle the ability to respawn.", ADMIN_CATEGORY_SERVER) // TG respawn has newer options. Consider porting this.
	var/new_nores = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, new_nores)
	if (!new_nores)
		to_chat(world, "<B>You may now respawn.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>You may no longer respawn :(</B>", confidential = TRUE)
	message_admins(span_adminnotice("[key_name_admin(user)] toggled respawn to [!new_nores ? "On" : "Off"]."))
	log_admin("[key_name(user)] toggled respawn to [!new_nores ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Respawn", "[!new_nores ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(delay, R_SERVER, FALSE, "Delay Pre-Game", "Delay the game start.", ADMIN_CATEGORY_SERVER)
	var/newtime = input(user, "Set a new time in seconds. Set -1 for indefinite delay.", "Set Delay", round(SSticker.GetTimeLeft()/10)) as num | null
	if(!newtime)
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return tgui_alert(user, "Too late... The game has already started!")
	newtime = newtime*10
	SSticker.SetTimeLeft(newtime)
	SSticker.start_immediately = FALSE
	if(newtime < 0)
		to_chat(world, "<span class='infoplain'><b>The game start has been delayed.</b></span>", confidential = TRUE)
		log_admin("[key_name(user)] delayed the round start.")
	else
		to_chat(world, span_infoplain(span_bold("The game will start in [DisplayTimeText(newtime)].")), confidential = TRUE)
		SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
		log_admin("[key_name(user)] set the pre-game delay to [DisplayTimeText(newtime)].")
	BLACKBOX_LOG_ADMIN_VERB("Delay Game Start")

ADMIN_VERB(set_admin_notice, R_SERVER, FALSE, "Set Admin Notice", "Set an announcement that appears to everyone who joins the server. Only lasts this round.", ADMIN_CATEGORY_SERVER)
	var/new_admin_notice = input(
		user,
		"Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):",
		"Set Notice",
		GLOB.admin_notice,
	) as message | null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(user)] removed the admin notice.")
		log_admin("[key_name(user)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(user)] set the admin notice.")
		log_admin("[key_name(user)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, span_adminnotice("<b>Admin Notice:</b>\n \t [new_admin_notice]"))
	BLACKBOX_LOG_ADMIN_VERB("Set Admin Notice")
	GLOB.admin_notice = new_admin_notice

ADMIN_VERB(toggle_guests, R_SERVER, FALSE, "Toggle Guests", "Toggle the ability for guests to enter the game.", ADMIN_CATEGORY_SERVER)
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>Guests may now enter the game.</B>", confidential = TRUE)
	log_admin("[key_name(user)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins(span_adminnotice("[key_name_admin(user)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Guests", "[!new_guest_ban ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
