ADMIN_VERB(check_players, R_ADMIN, FALSE, "Check Players", "Check current player statistics such as total clients.", ADMIN_CATEGORY_GAME)
	var/datum/check_players/tgui = new
	tgui.ui_interact(user.mob)
	to_chat(user, span_interface("Player statistics displayed."), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Check Players") //Logging
	message_admins("[key_name(user)] checked players.") //Logging

/datum/check_players/ui_data(mob/user) //Data required for the frontend
	return list(
		"total_clients" = length(GLOB.player_list),
		"living_players" = length(GLOB.alive_player_list),
		"dead_players" = length(GLOB.dead_player_list),
		"observers" = length(GLOB.current_observers_list),
		"living_antags" = length(GLOB.current_living_antags),
	)

/datum/check_players //datum required for the tgui window

/datum/check_players/ui_close()
	qdel(src)

/datum/check_players/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerStatistics")
		ui.open()

/datum/check_players/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)
