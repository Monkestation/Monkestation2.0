ADMIN_VERB(adjust_players_metacoins, R_FUN, FALSE, "Adjust Metacoins", "You can modifiy a targets metacoin balance by adding or subtracting.", ADMIN_CATEGORY_FUN)
	var/mob/chosen_player
	chosen_player = tgui_input_list(user, "Choose a Player", "Player List", GLOB.player_list)
	if(!chosen_player)
		return
	var/client/chosen_client = chosen_player.client

	var/adjustment_amount = tgui_input_number(user, "How much should we adjust this users metacoins by?", "Input Value", TRUE, 1000000, -100000)
	if(!adjustment_amount)
		return

	if(adjustment_amount + chosen_client.prefs.metacoins < 0)
		adjustment_amount = -chosen_client.prefs.metacoins
	log_admin("[key_name(user)] adjusted the metaoins of [key_name(chosen_client)] by [adjustment_amount].")
	message_admins("[key_name_admin(user)] adjusted the metacoins of [key_name(chosen_client)] by [adjustment_amount].")
	chosen_client.prefs.adjust_metacoins(chosen_client.ckey, adjustment_amount, "Admin [user.ckey] adjusted coins", announces = FALSE, donator_multiplier = FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Adjust Metacoins")

ADMIN_VERB(mass_add_metacoins, R_FUN, FALSE, "Mass Add Coins", "You give everyone some metacoins.", ADMIN_CATEGORY_FUN)
	var/adjustment_amount = tgui_input_number(user, "How much should we adjust this users metacoins by?", "Input Value", TRUE, 10000, 0)
	if(!adjustment_amount)
		return

	for(var/mob/player in GLOB.player_list)
		if(!player.client)
			continue
		if(!player.client.prefs)
			continue

		player.client.prefs.adjust_metacoins(player.client.ckey, adjustment_amount, "You have been gifted some coins from the staff", donator_multiplier = FALSE)
	log_admin("[key_name(user)] has mass adjusted metaoins.")
	message_admins("[key_name_admin(user)] has mass adjusted metaoins.")
	BLACKBOX_LOG_ADMIN_VERB("Mass Add Coins")
