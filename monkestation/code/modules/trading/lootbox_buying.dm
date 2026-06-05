/client/var/lootbox_prompt = FALSE

/client/proc/try_open_or_buy_lootbox()
	if(!prefs || lootbox_prompt)
		return
	if(isnewplayer(mob))
		to_chat(src, span_warning("You can't [prefs.lootboxes_owned ? "open" : "buy"] a lootbox here! Observe or spawn in first, then try again."))
		return
	if(!prefs.lootboxes_owned)
		lootbox_prompt = TRUE
		buy_lootbox()
	if(prefs.lootboxes_owned == 1)
		open_lootbox()
	else if(prefs.lootboxes_owned > 1)
		var/amt_to_open = 0
		switch(tgui_alert(src, "Open how many lootboxes?", "How Many?", list("All", "One", "Certain Amount")))
			if("One")
				open_lootbox()
				return
			if("All")
				amt_to_open = prefs.lootboxes_owned
			if("Certain Amount")
				amt_to_open = tgui_input_number(src, "How many?", "Lets go gambling!", 1, prefs.lootboxes_owned, 0)
		bulk_open_lootboxes(amt_to_open)


/client/proc/buy_lootbox()
	if(!prefs)
		lootbox_prompt = FALSE
		return
	if(!prefs.has_coins(LOOTBOX_COST))
		to_chat(src, span_warning("You do not have enough Monkecoins to buy a lootbox!"))
		lootbox_prompt = FALSE
		return
	switch(tgui_alert(src, "Would you like to purchase a lootbox? 5K", "Buy a lootbox!", list("Yes", "No")))
		if("Yes")
			var/num_lootboxes = tgui_input_number(src, "How many?", "The economy is booming", 1, prefs.metacoins / LOOTBOX_COST, 0)
			attempt_lootbox_buy(num_lootboxes)
			lootbox_prompt = FALSE
		else
			lootbox_prompt = FALSE
			return

/client/proc/attempt_lootbox_buy(num_lootboxes = 1)
	if(!prefs.has_coins(LOOTBOX_COST))
		to_chat(src, span_warning("You do not have enough Monkecoins to buy a lootbox!"))
		lootbox_prompt = FALSE
		return
	if(!prefs.adjust_metacoins(ckey, -LOOTBOX_COST * num_lootboxes, "Bought a lootbox(s)"))
		return
	prefs.lootboxes_owned += num_lootboxes
	prefs.save_preferences()

/client/proc/open_lootbox()
	message_admins("[ckey] opened a lootbox!")
	logger.Log(LOG_CATEGORY_META, "[src] has opened a lootbox!", list("currency_left" = prefs.metacoins))
	log_game("[key_name(src)] opened a lootbox!")
	if(!mob)
		return

	if(isnewplayer(mob))
		to_chat(mob, span_warning("You can't open a lootbox here! The lootbox has been added to your inventory. Observe or spawn in first, then click the button again."))
		return

	if(!prefs.lootboxes_owned)
		return
	prefs.lootboxes_owned--
	prefs.save_preferences()
	mob.trigger_lootbox_on_self()

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
	var/atom/movable/screen/fullscreen/lootbox_overlay/main/overlay = mob.trigger_lootbox_on_self()
	open_bulk_boxes(amount - 1, overlay)

/client/proc/open_bulk_boxes(amount_left_to_open, atom/movable/screen/fullscreen/lootbox_overlay/main/overlay)
	if(!prefs.lootboxes_owned)
		return

	if(!mob)
		return

	if(isnewplayer(mob))
		to_chat(mob, span_warning("You can't open a lootbox here! The lootbox has been added to your inventory. Observe or spawn in first, then click the button again."))
		return

	if(!amount_left_to_open)
		return

	var/type_string
	var/type_rolled
	for(var/i in 1 to amount_left_to_open)
		type_rolled = rand(1, 200)
		switch(type_rolled)
			if(1 to 2)
				type_string = "Unusual"
			if(3 to 4)
				type_string = "High Tier"
			if(5 to 9)
				type_string = "Medium Tier"
			if(10 to 16)
				type_string = "Low Tier"
			else
				type_string = "Loadout Item"

		var/obj/item/rolled_item = return_rolled(type_string, mob)
		if(type_string == "Unusual")
			to_chat(world, span_boldannounce("[mob] has unboxed an [rolled_item.name]!"))
			if(isliving(mob) && !mob.put_in_hands(rolled_item))
				rolled_item.forceMove(get_turf(mob))
		to_chat(mob, span_boldannounce("You have unboxed an [rolled_item.name]!"))
		prefs.lootboxes_owned--
	overlay.cleanup(mob)
	prefs.save_preferences()
/proc/give_lootboxes_to_randoms(amount)
	for(var/i = 1 to amount)
		var/mob/mob = pick(GLOB.player_list)
		if(!mob.client)
			continue
		mob.client.give_lootbox(1)

/client/proc/give_lootbox(amount)
	if(!prefs)
		return
	prefs.lootboxes_owned += amount
	to_chat(mob, span_notice("You have been given [amount] lootboxes! Open it using the escape menu."))
	prefs.save_preferences()
