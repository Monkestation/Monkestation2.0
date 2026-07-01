GLOBAL_VAR_INIT(tram_isekai, FALSE)

ADMIN_VERB(toggle_tram_isekai, R_FUN, FALSE, "Toggle Tram Impact Reconnect", "Toggles whether clients hit by the tram reconnect to Vanderlin if they are put in hard crit or killed.", ADMIN_CATEGORY_FUN)
	if(!SStransport.can_fire)
		to_chat(usr, span_adminnotice("The tram is not enabled on this map!"), confidential = TRUE)
		return

	GLOB.tram_isekai = !GLOB.tram_isekai
	log_admin("[key_name(user)] has toggled tram impact reconnecting to Vanderlin, it is now [GLOB.tram_isekai ? "enabled" : "disabled"].")
	message_admins("[key_name(user)] has toggled tram impact reconnecting to Vanderlin, it is now [GLOB.tram_isekai ? "enabled" : "disabled"].")
