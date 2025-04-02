/datum/controller/subsystem/ticker/proc/save_tokens()
	rustg_file_write(json_encode(GLOB.saved_token_values), "[GLOB.log_directory]/tokens.json")

/datum/controller/subsystem/ticker/proc/calculate_rewards()
	var/hour = round((world.time - SSticker.round_start_time) / 36000)
	var/minute = round(((world.time - SSticker.round_start_time) - (hour * 36000)) / 600)
	var/added_xp = round(25 + (minute ** 0.85))
	. = list()
	for(var/client/client as anything in GLOB.clients)
		handle_rewards_for_client(client, added_xp, .)
	rustg_file_write(json_encode(.), "[GLOB.log_directory]/roundend_rewards.json") // remove this before full merge, this is just to make sure if this doesn't work, we can use this to give everyone their missed rewards

/datum/controller/subsystem/ticker/proc/handle_rewards_for_client(client/client, added_xp, list/rewards_list)
	var/ckey = client?.ckey
	if(!ckey)
		return
	var/list/rewards = calculate_rewards_for_client(client, added_xp)
	if(!length(rewards))
		return
	var/total_monkecoins = 0
	var/list/reasons = list()
	for(var/list/reward as anything in rewards)
		if(length(reward) != 2)
			stack_trace("wtf, reward length wasn't 2")
			continue
		var/amount = reward[1]
		var/reason = reward[2]
		if(!amount || !reason)
			continue
		total_monkecoins += amount
		reasons += span_rose(span_bold("[amount] Monkecoins deposited to your account! Reason: [reason]"))
	if(!total_monkecoins)
		return
	client?.prefs?.metacoins += total_monkecoins
	to_chat(client, jointext(reasons, "\n"), type = MESSAGE_TYPE_INFO)
	rewards_list[ckey] = total_monkecoins

/datum/controller/subsystem/ticker/proc/calculate_rewards_for_client(client/client, added_xp)
	. = list()
	if(!istype(client) || QDELING(client))
		return
	var/datum/player_details/details = get_player_details(client)
	if(!QDELETED(client?.prefs))
		var/round_end_bonus = 75

		// Patreon Flat Roundend Bonus
		if((details?.patreon?.has_access(ACCESS_ASSISTANT_RANK)))
			round_end_bonus += DONATOR_ROUNDEND_BONUS

		// Twitch Flat Roundend Bonus
		if((details?.twitch?.has_access(ACCESS_TWITCH_SUB_TIER_1)))
			round_end_bonus += DONATOR_ROUNDEND_BONUS

		. += list(list(round_end_bonus, "Played a Round"))

		if(world.port == MRP2_PORT)
			. += list(list(500, "Monkey 2 Seeding Subsidies"))
		var/special_bonus = details?.roundend_monkecoin_bonus
		if(special_bonus)
			. += list(list(special_bonus, "Special Bonus"))
		// WHYYYYYY
		if(QDELETED(client))
			return
		if(client?.is_mentor())
			. += list(list(500, "Mentor Bonus"))
		// WHYYYYYYYYYYYYYYYY
		if(QDELETED(client))
			return
		if(client?.mob?.mind?.assigned_role)
			add_jobxp(client, added_xp, client?.mob?.mind?.assigned_role?.title)

	if(QDELETED(client))
		return
	var/list/applied_challenges = details?.applied_challenges
	if(LAZYLEN(applied_challenges))
		var/mob/living/client_mob = client?.mob
		if(!istype(client_mob) || QDELING(client_mob) || client_mob?.stat == DEAD)
			return
		var/total_payout = 0
		for(var/datum/challenge/listed_challenge as anything in applied_challenges)
			if(listed_challenge.failed)
				continue
			total_payout += listed_challenge.challenge_payout
		if(total_payout)
			. += list(list(total_payout, "Challenge Rewards"))

/datum/controller/subsystem/ticker/proc/refund_cassette()
	if(!length(GLOB.cassette_reviews))
		return

	for(var/id in GLOB.cassette_reviews)
		var/datum/cassette_review/review = GLOB.cassette_reviews[id]
		if(!review || review.action_taken) // Skip if review doesn't exist or already handled (denied / approved)
			continue

		var/ownerckey = review.submitted_ckey // ckey of who made the cassette.
		if(!ownerckey)
			continue

		var/client/client = GLOB.directory[ownerckey] // Use directory for direct lookup (Client might be a differnet mob than when review was made.)
		if(client && !QDELETED(client?.prefs))
			var/prev_bal = client?.prefs?.metacoins
			var/adjusted = client?.prefs?.adjust_metacoins(
				client?.ckey,
				amount = 5000,
				reason = "No action taken on cassette:\[[review.submitted_tape.name]\] before round end",
				announces = TRUE,
				donator_multiplier = FALSE,
			)
			if(!adjusted)
				message_admins("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins]. Issue logged.")
				log_admin("Balance not adjusted for Cassette:[review.submitted_tape.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins].")
			qdel(review)

/proc/batch_update_metacoins(list/batch)
	if(!length(batch))
		return TRUE

	var/join_query = ""
	var/list/params = list()

	var/i = 1
	for(var/ckey in batch)
		var/amount = batch[ckey]
		if(!ckey || !amount)
			continue
		if(i > 1)
			join_query += " UNION ALL "
		i += 1

		join_query += "SELECT :ckey[i] AS ckey, :amount[i] AS amount"
		params["ckey[i]"] = ckey
		params["amount[i]"] = amount

	var/datum/db_query/query_batch_metacoins = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] AS p JOIN ([join_query]) AS u ON p.ckey = u.ckey SET p.metacoins = p.metacoins + u.amount",
		params
	)
	if(!query_batch_metacoins.Execute())
		QDEL_NULL(query_batch_metacoins)
		stack_trace("Batch updating metacoins failed, we're doing it manually!")
		for(var/ckey in batch)
			var/client/client = GLOB.directory[ckey]
			if(!client)
				continue
			var/amount = batch[ckey]
			client?.prefs?.adjust_metacoins(ckey, amount, reason = "Normal roundend monkecoin update failed, doing it manually", announces = FALSE, donator_multiplier = FALSE)
		return FALSE
	qdel(query_batch_metacoins)
	return TRUE
