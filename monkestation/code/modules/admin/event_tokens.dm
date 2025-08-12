ADMIN_VERB(adjust_players_event_tokens, R_FUN, FALSE, "Adjust Event Tokens", "Adjust how many event tokens someone has.", ADMIN_CATEGORY_FUN)
	var/client/chosen_client = tgui_input_list(user, "Choose a Player", "Player List", GLOB.clients)
	if(!chosen_client)
		return

	var/adjustment_amount = tgui_input_number(user, "How much should we adjust this users tokens by?", "Input Value", TRUE)
	if(!adjustment_amount || !chosen_client)
		return

	log_admin("[key_name(user)] adjusted the event tokens of [key_name(chosen_client)] by [adjustment_amount].")
	message_admins("[key_name(user)] adjusted the event tokens of [key_name(chosen_client)] by [adjustment_amount].")
	chosen_client.client_token_holder.adjust_event_tokens(adjustment_amount)
	BLACKBOX_LOG_ADMIN_VERB("Adjust Event Tokens")
