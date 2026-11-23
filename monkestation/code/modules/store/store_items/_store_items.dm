/datum/store_item
	///the displayed name of this item in the shop
	var/name
	///the category of the item
	var/category
	///the path of the item
	var/atom/item_path
	///the cost of the item
	var/item_cost = 1000
	///hidden from general store
	var/hidden = FALSE
	///is this a one time purchase for a roundstart?
	var/one_time_buy = FALSE
	///the description shown in the store if we show descriptions
	var/store_desc = ""


/datum/store_item/proc/attempt_purchase(client/buyer)
	var/datum/preferences/buyers_preferences = buyer.prefs

	if(item_path in buyers_preferences.inventory)
		return FALSE

	if(!buyers_preferences.has_coins(item_cost))
		to_chat(buyer, span_warning("You don't have the funds to buy the [name]"))
		return FALSE


	if(!one_time_buy)
		finalize_purchase(buyer, item_cost)
		return
	else
		buyers_preferences.adjust_metacoins(buyer.ckey, -item_cost, "[buyer] bought a [name] for [item_cost]", donator_multiplier = FALSE)
	attempt_spawn(buyer)

/// Takes `cost` coins in the same transaction as saving the item.
/datum/store_item/proc/finalize_purchase(client/buyer, cost = 0)
	SHOULD_CALL_PARENT(TRUE)

	var/fail_message = span_warning("Failed to add purchase to database. You have not been charged.")
	if(!buyer?.prefs)
		return FALSE
	var/datum/sql_transaction/transaction = SSdbcore.BeginTransaction()
	if(!transaction)
		to_chat(buyer, fail_message)
		return FALSE
	var/datum/preferences/prefs = buyer.prefs
	var/ckey = buyer.ckey
	if(!prefs.inventory[item_path])
		SSdbcore.FireAndForget({"
			INSERT INTO [format_table_name("metacoin_item_purchases")] (`ckey`, `item_id`, `amount`) VALUES (:ckey, :item_id, :amount)"},
			list("ckey" = ckey, "item_id" = item_path, "amount" = 1), transaction = transaction)
	else
		SSdbcore.FireAndForget({"
			UPDATE [format_table_name("metacoin_item_purchases")] SET amount = :amount WHERE ckey = :ckey AND item_id = :item_id"},
			list("ckey" = ckey, "item_id" = item_path, "amount" = 1), transaction = transaction)
	if(cost)
		SSdbcore.FireAndForget(
			"UPDATE [format_table_name("player")] SET metacoins = metacoins - :cost WHERE ckey = :ckey",
			list("cost" = cost, "ckey" = ckey), transaction = transaction)
	var/reason = "[buyer] bought a [name] for [cost]"
	// added before the commit sleeps so a second click can't buy it twice
	prefs.inventory += item_path
	if(!SSdbcore.CommitTransaction(transaction))
		prefs.inventory -= item_path
		to_chat(buyer, fail_message)
		return FALSE
	if(!cost)
		return TRUE
	var/previous_coins = prefs.metacoins
	prefs.metacoins -= cost
	logger.Log(LOG_CATEGORY_META, "[ckey]'s monkecoins were changed by [-cost] Reason: [reason]", list("currency_left" = prefs.metacoins, "reason" = reason, "previous_coins" = previous_coins))
	to_chat(buyer, "<span class='rose bold'>[cost] Monkecoins have been withdrawn from your account! Reason: [reason]</span>")
	return TRUE

/datum/store_item/proc/attempt_spawn(client/buyer)
	var/mob/buyer_mob = get_mob_by_ckey(buyer.ckey)

	if(!isliving(buyer_mob))
		buyer.prefs.adjust_metacoins(buyer.ckey, item_cost, "Spawned as Non-Living, Unable to utilize items", donator_multiplier = FALSE)
		return

	var/obj/item/created_item = new item_path

	return created_item
