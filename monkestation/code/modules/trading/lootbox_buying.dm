/client/proc/try_open_or_buy_lootbox()
	if(!prefs)
		return

	var/has_loot_boxes = (prefs.lootboxes_owned > 0)

	if(isnewplayer(mob))
		to_chat(src, span_warning("You can't [has_loot_boxes ? "open" : "buy"] a lootbox here! Observe or spawn in first, then try again."))
		return

	var/negative_loot = prefs.lootboxes_owned < 0
	if(negative_loot)
		message_admins("[key_name_admin(src)] has negative loot boxes, it's possible they have already bought multiple for free! They have a debt of [prefs.lootboxes_owned].")
		logger.Log(LOG_CATEGORY_META, "[src] had negative loot boxes!")
		to_chat(src, span_warning("You currently have negative lootboxes ([prefs.lootboxes_owned])! You will need to buy these back before you can open more."))

	if(!has_loot_boxes)
		buy_lootbox()
		return

	open_lootbox()

/client/proc/buy_lootbox()
	if(!prefs)
		return

	if(!prefs.has_coins(LOOTBOX_COST))
		to_chat(src, span_warning("You do not have enough Monkecoins to buy a lootbox!"))
		return

	var/choice = tgui_alert(src, "Would you like to purchase a lootbox? 5K", "Buy a lootbox!", list("Yes", "No"))
	if(choice != "Yes")
		return

	attempt_lootbox_buy()

/client/proc/attempt_lootbox_buy()
	if(!prefs.has_coins(LOOTBOX_COST))
		to_chat(src, span_warning("You do not have enough Monkecoins to buy a lootbox!"))
		return

	if(!prefs.adjust_metacoins(ckey, -LOOTBOX_COST, "Bought a lootbox"))
		return

	prefs.lootboxes_owned++
	prefs.save_preferences()

	to_chat(src, span_notice("Lootbox bought. You now own [prefs.lootboxes_owned] lootboxes."))

/client/proc/open_lootbox()
	if(!mob)
		return

	if(isnewplayer(mob))
		to_chat(mob, span_warning("You can't open a lootbox here! The lootbox has been added to your inventory. Observe or spawn in first, then click the button again."))
		return

	if(prefs.lootboxes_owned <= 0)
		return

	message_admins("[key_name_admin(src)] opened a lootbox!")
	logger.Log(LOG_CATEGORY_META, "[src] has opened a lootbox!", list("currency_left" = prefs.metacoins))
	log_game("[key_name(src)] opened a lootbox!")

	prefs.lootboxes_owned--
	prefs.save_preferences()
	mob.trigger_lootbox_on_self()

	to_chat(src, span_notice("Lootbox opened. You now own [prefs.lootboxes_owned] lootboxes."))

/client/proc/give_lootbox(amount)
	if(!prefs)
		return

	prefs.lootboxes_owned += amount
	prefs.save_preferences()

	to_chat(src, span_notice("You have been given [amount] lootboxes! Open them using the escape menu."))
	to_chat(src, span_notice("You now own [prefs.lootboxes_owned] lootboxes."))

/proc/give_lootboxes_to_randoms(amount)
	for(var/i = 1 to amount)
		var/mob/mob = pick(GLOB.player_list)
		if(!mob.client)
			continue
		mob.client.give_lootbox(1)
