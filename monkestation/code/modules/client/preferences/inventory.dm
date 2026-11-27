/datum/preferences/proc/load_metacoins_and_inventory(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		metacoins = 5000
		return
	var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery(
		"SELECT metacoins FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	var/datum/db_query/query_gear = SSdbcore.NewQuery(
		"SELECT item_id,amount FROM [format_table_name("metacoin_item_purchases")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	SSdbcore.QuerySelect(list(query_get_metacoins, query_gear), warn = TRUE)

	var/mc_count = 0
	if(query_get_metacoins.status == DB_QUERY_FINISHED && query_get_metacoins.NextRow())
		mc_count = query_get_metacoins.item[1]
	metacoins = text2num(mc_count)

	if(query_gear.status == DB_QUERY_FINISHED)
		while(query_gear.NextRow())
			inventory += text2path(query_gear.item[1])

	qdel(query_get_metacoins)
	qdel(query_gear)

/datum/preferences/proc/apply_donator_multiplier(amount)
	switch(parent.persistent_client.patreon.access_rank)
		if(ACCESS_COMMAND_RANK)
			return amount * 1.5
		if(ACCESS_TRAITOR_RANK)
			return amount * 2
		if(ACCESS_NUKIE_RANK)
			return amount * 3
	return amount

/datum/preferences/proc/log_metacoin_change(amount, previous_coins, reason, announces)
	logger.Log(LOG_CATEGORY_META, "[parent]'s monkecoins were changed by [amount] Reason: [reason]", list("currency_left" = metacoins, "reason" = reason, "previous_coins" = previous_coins ))
	if(!announces)
		return
	if(reason)
		to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]</span>")
	else
		to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account!</span>")

/datum/preferences/proc/adjust_metacoins(ckey, amount, reason = null, announces = TRUE, donator_multiplier = TRUE, respects_roundcap = FALSE)
	if(!ckey || !SSdbcore.IsConnected())
		return FALSE

	if(amount > 0 && (!max_round_coins && respects_roundcap))
		to_chat(parent, "You've hit the Monkecoin limit for this shift, please try again next shift.")
		return

	if(respects_roundcap)
		if(max_round_coins <= amount)
			amount = max_round_coins
		max_round_coins -= amount

	if(amount > 0 && donator_multiplier)
		amount = apply_donator_multiplier(amount)

	amount = round(amount, 1) //make sure whole number
	var/previous_coins = metacoins
	// before the query so a second spend during the wait can't use the same coins
	metacoins += amount

	//SQL query - updates the metacoins in the database (this is where the storage actually happens)
	var/datum/db_query/query_inc_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + :amount WHERE ckey = :ckey",
		list("amount" = amount, "ckey" = ckey)
	)
	if(!query_inc_metacoins.warn_execute())
		metacoins -= amount
		qdel(query_inc_metacoins)
		return FALSE
	qdel(query_inc_metacoins)

	log_metacoin_change(amount, previous_coins, reason, announces)
	return TRUE

/proc/mass_adjust_metacoins(list/amounts_by_ckey, reason = null, announces = TRUE, donator_multiplier = TRUE)
	if(!SSdbcore.IsConnected())
		return FALSE

	var/list/amounts = list()
	var/list/cases = list()
	var/list/placeholders = list()
	var/list/arguments = list()
	for(var/ckey, amount in amounts_by_ckey)
		var/client/target = GLOB.directory[ckey]
		var/datum/preferences/target_prefs = target?.prefs
		if(!target_prefs)
			continue
		var/final_amount = amount
		if(final_amount > 0 && donator_multiplier)
			final_amount = target_prefs.apply_donator_multiplier(final_amount)
		final_amount = round(final_amount, 1)
		if(!final_amount)
			continue
		var/index = length(amounts)
		amounts[ckey] = final_amount
		cases += "WHEN :ckey[index] THEN :amount[index]"
		placeholders += ":ckey[index]"
		arguments["ckey[index]"] = ckey
		arguments["amount[index]"] = final_amount
	if(!length(amounts))
		return TRUE

	var/datum/db_query/query_inc_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET metacoins = metacoins + CASE ckey [cases.Join(" ")] END WHERE ckey IN ([placeholders.Join(", ")])",
		arguments
	)
	if(!query_inc_metacoins.warn_execute())
		qdel(query_inc_metacoins)
		for(var/ckey, amount in amounts)
			var/client/target = GLOB.directory[ckey]
			var/datum/preferences/target_prefs = target?.prefs
			if(target_prefs)
				INVOKE_ASYNC(target_prefs, TYPE_PROC_REF(/datum/preferences, adjust_metacoins), ckey, amount, reason, announces, FALSE)
		return FALSE
	qdel(query_inc_metacoins)

	for(var/ckey, amount in amounts)
		var/client/target = GLOB.directory[ckey]
		var/datum/preferences/target_prefs = target?.prefs
		if(!target_prefs)
			continue
		var/previous_coins = target_prefs.metacoins
		target_prefs.metacoins += amount
		target_prefs.log_metacoin_change(amount, previous_coins, reason, announces)
	return TRUE

/datum/preferences/proc/has_coins(amount)
	if(amount > metacoins)
		return FALSE
	return TRUE
