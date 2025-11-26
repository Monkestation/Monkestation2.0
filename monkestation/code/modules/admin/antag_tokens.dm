ADMIN_VERB(adjust_players_antag_tokens, R_FUN, FALSE, "Adjust Antag Tokens", "You can modifiy a targets antag tokens by adding or subtracting from that tier.", ADMIN_CATEGORY_FUN)
	var/client/chosen_client = tgui_input_list(user, "Choose a Player", "Player List", GLOB.clients)
	if(!chosen_client)
		return

	var/adjustment_amount = tgui_input_number(user, "How much should we adjust this users antag tokens by?", "Input Value", TRUE, 10, -10)
	if(!adjustment_amount || !chosen_client)
		return
	var/tier = tgui_input_list(user, "Choose a tier for the token", "Tier list", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!tier)
		return

	log_admin("[key_name(user)] adjusted the [tier] antag tokens of [key_name(chosen_client)] by [adjustment_amount].")
	message_admins("[key_name_admin(user)] adjusted the [tier] antag tokens of [key_name(chosen_client)] by [adjustment_amount].")
	chosen_client.client_token_holder.adjust_antag_tokens(tier, adjustment_amount)
	BLACKBOX_LOG_ADMIN_VERB("Adjust Antag Tokens")
