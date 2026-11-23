/// Adds to a player's antag debt (higher means they are owed an antag roll more). Being picked costs 1.
/datum/preferences/proc/adjust_antag_debt(amount)
	antag_debt += amount
	log_antag_rep("[parent_ckey]'s antag debt was adjusted by [amount] (now [antag_debt])")
	save_preferences()

/// Turns candidates (mobs, clients or mock clients) into a ckey -> weight list. The most owed player (highest debt) gets weight 1, everyone else shrinks exponentially with how much less they are owed.
/proc/get_antag_roll_weights(list/candidates)
	var/list/debts = list()
	var/highest_debt
	for(var/anything in candidates)
		var/client/client_source
		if(ismob(anything))
			var/mob/mob = anything
			client_source = mob.client
		else if(IS_CLIENT_OR_MOCK(anything))
			client_source = anything
		if(QDELETED(client_source) || !client_source.ckey)
			continue
		var/debt = client_source.prefs?.antag_debt || 0
		debts[client_source.ckey] = debt
		if(isnull(highest_debt) || debt > highest_debt)
			highest_debt = debt

	var/strength = CONFIG_GET(number/antag_debt_strength)
	. = list()
	for(var/ckey in debts)
		// floored so the smallest weight stays about 1/22000 of the biggest instead of rounding to 0 in pick_weight's 32-bit float total
		.[ckey] = NUM_E ** max(strength * (debts[ckey] - highest_debt), -10)

/// Every ckey in the pool gains total / pool size debt (owed more), where total is what the picks cost. A roll that picked nobody credits nothing.
/proc/credit_antag_roll(list/pool_ckeys, total)
	if(!total || !length(pool_ckeys))
		return
	var/share = total / length(pool_ckeys)
	for(var/ckey in pool_ckeys)
		var/datum/preferences/prefs = GLOB.preferences_datums[ckey]
		prefs?.adjust_antag_debt(share)

/// Weighted draw of up to amount candidates for an antag roll. Charges each pick cost debt, credits the whole pool the same total, returns the picked mobs.
/proc/roll_antag_candidates(list/candidates, amount = 1, cost = 1)
	var/list/weighted_candidates = get_antag_roll_weights(candidates)
	var/list/pool_ckeys = assoc_to_keys(weighted_candidates)
	var/list/picked = list()
	while(length(weighted_candidates) && length(picked) < amount)
		var/picked_ckey = pick_n_take_weighted(weighted_candidates)
		var/client/picked_client = GLOB.directory[picked_ckey]
		if(QDELETED(picked_client) || QDELETED(picked_client.mob))
			continue
		picked_client.prefs?.adjust_antag_debt(-cost)
		picked += picked_client.mob
	credit_antag_roll(pool_ckeys, length(picked) * cost)
	return picked
