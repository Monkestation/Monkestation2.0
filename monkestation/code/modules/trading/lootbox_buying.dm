/// Attempt to buy a given number of lootboxes. Fails if the client does not have enough monkecoin to do so.
/client/proc/attempt_lootbox_buy(num_lootboxes = 1)
	if(!prefs.has_coins(LOOTBOX_COST))
		to_chat(src, span_warning("You do not have enough Monkecoins to buy a lootbox!"))
		return
	if(!prefs.adjust_metacoins(ckey, -LOOTBOX_COST * num_lootboxes, "Bought [num_lootboxes] lootbox[num_lootboxes > 1 ? "es" : ""]"))
		return
	prefs.lootboxes_owned += num_lootboxes
	prefs.save_preferences()

/client/proc/bulk_open_lootboxes(amount)
	message_admins("[ckey] opened mutiple lootboxs!")
	logger.Log(LOG_CATEGORY_META, "[src] has opened lootboxs!", list("currency_left" = prefs.metacoins))
	log_game("[key_name(src)] opened lootboxs!")
	if(!mob)
		return

	if(isnewplayer(mob))
		to_chat(mob, span_warning("You can't open a lootbox here! The lootbox has been added to your inventory. Observe or spawn in first, then click the button again."))
		return

	if(!prefs.lootboxes_owned)
		return

	prefs.lootboxes_owned--
	prefs.save_preferences()
	// var/atom/movable/screen/fullscreen/lootbox_overlay/main/overlay = mob.trigger_lootbox_on_self()

///Gives the passed amount of clients a single lootbox, at random, from all clients
/proc/give_lootboxes_to_randoms(amount)
	for(var/i = 1 to amount)
		var/mob/mob = pick(GLOB.player_list)
		if(!mob.client)
			continue
		mob.client.give_lootbox(1)

///Adds amount lootboxes to the given clients storage
/client/proc/give_lootbox(amount)
	if(!prefs)
		return
	prefs.lootboxes_owned += amount
	to_chat(mob, span_notice("You have been given [amount] lootboxes! Open it using the escape menu."))
	prefs.save_preferences()
