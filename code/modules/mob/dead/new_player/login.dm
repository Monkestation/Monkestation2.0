/mob/dead/new_player/Login()
	if(!client)
		return

	if(CONFIG_GET(flag/use_exp_tracking))
		client?.set_exp_from_db()
		client?.set_db_player_flags()
		if(!client)
			// client disconnected during one of the db queries
			return FALSE

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.set_current(src)

	if(!SSplexora.lookup_id(client.ckey))
		client.not_discord_verified = TRUE

	. = ..()
	if(!. || !client)
		return FALSE

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	// MONKESTATION EDIT START - lobby notices
	if (SSticker.current_state != GAME_STATE_STARTUP && length(config.lobby_notices))
		config.ShowLobbyNotices(src)
	// MONKESTATION END
	if(GLOB.admin_notice)
		to_chat(src, span_notice("<b>Admin Notice:</b>\n \t [GLOB.admin_notice]"))

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, span_notice("<b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]"))

	add_sight(SEE_TURFS)

	if(!client.media)
		client.media = new /datum/media_manager(client)
		client.media.open()
		client.media.update_music()

	var/datum/asset/asset_datum = get_asset_datum(/datum/asset/simple/lobby)
	asset_datum.send(client)
	if(QDELETED(client)) // client disconnected during asset transit
		return FALSE

	// The parent call for Login() may do a bunch of stuff, like add verbs.
	// Delaying the register_for_verification until the very end makes sure it can clean everything up
	// and set the player's client up for verification.

	///guh
	client.check_overwatch()
	if(QDELETED(client)) // client disconnected during overwatch check
		return FALSE

	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		to_chat(src, "Please set up your character and select \"Ready\". The game will start [tl > 0 ? "in about [DisplayTimeText(tl)]" : "soon"].")

	if(QDELETED(client)) // client disconnected during- yeah you get the point
		return FALSE

	addtimer(CALLBACK(client, TYPE_PROC_REF(/client, playtitlemusic)), 4 SECONDS, TIMER_DELETE_ME)
