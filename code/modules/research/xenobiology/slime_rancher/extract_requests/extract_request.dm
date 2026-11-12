/// Everything ever ordered through the extract request consoles, oldest first.
GLOBAL_LIST_EMPTY_TYPED(extract_requests, /datum/extract_request)

/// One crewmember's order of slime extracts or crossbreeds from xenobiology.
/datum/extract_request
	/// Position in GLOB.extract_requests, which is also how the consoles and windows refer to it.
	var/id
	/// What the windows call the item: a slime color id for an extract, "effect|color id" for a crossbreed.
	var/item_id
	/// Typepath of a single ordered item.
	var/obj/item/item_type
	/// Lowercase item name for logs and announcements.
	var/item_name
	var/count
	var/reason
	var/requester_name
	var/requester_job
	var/datum/bank_account/requester_account
	/// Credits held out of the requester's account until pickup, cancellation or a decline.
	var/offer
	var/status = EXTRACT_REQUEST_WAITING
	var/claimer_name
	var/datum/bank_account/claimer_account
	var/decline_reason
	/// What xenobiology has loaded so far, sitting inside whichever order console took it.
	var/list/obj/item/loaded = list()
	/// Whether a xenobiologist has opened it yet.
	var/seen = FALSE

/datum/extract_request/New(item_id, list/item, count, reason, obj/item/card/id/id_card, offer)
	src.item_id = item_id
	item_type = item["type"]
	item_name = item["name"]
	src.count = count
	src.reason = reason
	src.offer = offer
	requester_name = id_card.registered_name
	requester_job = id_card.assignment
	requester_account = id_card.registered_account
	id = length(GLOB.extract_requests) + 1
	GLOB.extract_requests += src

/// Still needs somebody to do something about it.
/datum/extract_request/proc/is_open()
	return status == EXTRACT_REQUEST_WAITING || status == EXTRACT_REQUEST_CLAIMED || status == EXTRACT_REQUEST_READY

/// Who ordered what, for log lines.
/datum/extract_request/proc/describe()
	return "extract request #[id] ([count]x [item_name] for [requester_name], offer [offer] cr)"

/// The request as the windows see it. The viewer's account decides what counts as theirs.
/datum/extract_request/proc/to_list(datum/bank_account/viewer) as /list
	return list(
		"id" = id,
		"item" = item_id,
		"count" = count,
		"reason" = reason,
		"offer" = offer,
		"status" = status,
		"requester" = requester_name,
		"job" = requester_job,
		"claimer" = copytext(claimer_name, 1, findtext(claimer_name, " ")),
		"mine" = !isnull(viewer) && claimer_account == viewer,
		"decline_reason" = decline_reason,
		"loaded" = length(loaded),
		"seen" = seen,
	)

/// Counts an item toward the order, and tells the requester once it's complete.
/datum/extract_request/proc/add_loaded(obj/item/item, mob/user)
	loaded += item
	user.log_message("loaded [item] into [describe()] ([length(loaded)]/[count])", LOG_GAME)
	if(length(loaded) < count)
		return
	status = EXTRACT_REQUEST_READY
	user.log_message("finished [describe()], ready for pickup", LOG_GAME)
	requester_account.bank_card_talk("Your order of [count]x [item_name] is ready. Pick it up at any extract request console.")

/// Gives the held offer back to the requester.
/datum/extract_request/proc/refund_offer()
	if(!offer)
		return
	requester_account.adjust_money(offer, "Extract Request: Offer returned")
	log_econ("[offer] credits were returned to [requester_account.account_holder] for extract request #[id]")
	requester_account.bank_card_talk("Your [offer] cr offer for [count]x [item_name] was returned.")

/// Pays the held offer to whoever filled the order.
/datum/extract_request/proc/pay_claimer()
	if(!offer)
		return
	claimer_account.adjust_money(offer, "Extract Request: Payment")
	log_econ("[offer] credits held for extract request #[id] were paid to [claimer_account.account_holder]")
	claimer_account.bank_card_talk("You were paid [offer] cr for [count]x [item_name].")

/// Tells science over the radio and has every order console say it out loud.
/datum/extract_request/proc/announce()
	var/message = "New extract request: [count]x [item_name] for [requester_name], [requester_job]."
	for(var/obj/machinery/announcement_system/system as anything in GLOB.announcement_systems)
		if(system.is_operational)
			system.broadcast(message, list(RADIO_CHANNEL_SCIENCE))
			break
	for(var/obj/machinery/computer/extract_orders/console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/extract_orders))
		console.chime(message)

/// The request with that id, if there is one.
/proc/find_extract_request(id) as /datum/extract_request
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		if(request.id == id)
			return request

/// Crossbreeds that fall apart or hide inside another item when made can't be handed over, so they can't be ordered.
/proc/extract_request_orderable(obj/item/slimecross/crossbreed)
	return !ispath(crossbreed, /obj/item/slimecross/recurring) && !ispath(crossbreed, /obj/item/slimecross/selfsustaining)

/// What an item id orders, as list("type" = path, "name" = text), or null if xenobiology can't make it. Extracts are just a color, crossbreeds are "effect|color".
/proc/get_extract_request_item(item_id)
	if(!istext(item_id))
		return null
	var/list/parts = splittext(item_id, "|")
	if(length(parts) > 2)
		return null
	var/datum/slime_type/slime_type
	for(var/datum/slime_type/candidate as anything in valid_subtypesof(/datum/slime_type))
		if(slime_icon_prefix(candidate) == parts[length(parts)])
			slime_type = candidate
			break
	if(!slime_type)
		return null
	if(length(parts) == 1)
		return list("type" = slime_type::core_type, "name" = "[slime_type::color] extract")
	var/obj/item/slimecross/crossbreed = GLOB.slime_crossbreeds["[parts[1]]|[slime_type]"]
	if(!crossbreed || !extract_request_orderable(crossbreed))
		return null
	return list("type" = crossbreed, "name" = "[crossbreed::effect] [slime_type::color] crossbreed")

/// Ids of the slime colors that have been bred this round.
/proc/extract_request_bred_colors() as /list
	. = list()
	for(var/datum/slime_type/slime_type as anything in GLOB.obtained_slime_types)
		. += slime_icon_prefix(slime_type)

/// The ID the user is holding or wearing, for those who can have one.
/proc/extract_request_get_id(mob/user) as /obj/item/card/id
	if(!isliving(user))
		return null
	var/mob/living/living_user = user
	return living_user.get_idcard(hand_first = TRUE)

/// What the requester's window shows, whether it's on a console or a PDA.
/proc/extract_request_public_data(obj/item/card/id/id_card) as /list
	var/datum/bank_account/account = id_card?.registered_account
	var/list/data = list(
		"bred" = extract_request_bred_colors(),
		"user" = null,
		"requests" = list(),
	)
	if(!account)
		return data
	data["user"] = list(
		"name" = id_card.registered_name,
		"job" = id_card.assignment,
		"balance" = account.account_balance,
	)
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		if(request.requester_account == account && request.status != EXTRACT_REQUEST_CANCELLED)
			data["requests"] += list(request.to_list())
	return data

/// The actions a requester can take, whether from a console or a PDA. Picking up isn't one of them, that only works at a console.
/proc/extract_request_public_act(action, list/params, mob/user, obj/item/card/id/id_card)
	var/datum/bank_account/account = id_card?.registered_account
	if(!account)
		return FALSE
	switch(action)
		if("request")
			var/list/item = get_extract_request_item(params["item"])
			var/count = params["count"]
			var/offer = params["offer"]
			if(!item || !isnum(count) || !isnum(offer))
				return FALSE
			count = round(count)
			offer = round(offer)
			if(!ISINRANGE(count, 1, 5) || !ISINRANGE(offer, 0, 99999))
				return FALSE
			var/open_requests = 0
			for(var/datum/extract_request/existing as anything in GLOB.extract_requests)
				if(existing.requester_account == account && existing.is_open())
					open_requests++
			if(open_requests >= 5)
				user.balloon_alert(user, "too many open requests")
				return FALSE
			var/reason = trim(STRIP_HTML_SIMPLE("[params["reason"]]", EXTRACT_REQUEST_REASON_LENGTH + 1))
			if(offer && !account.adjust_money(-offer, "Extract Request: Offer held"))
				user.balloon_alert(user, "not enough credits")
				return FALSE
			var/datum/extract_request/request = new(params["item"], item, count, reason, id_card, offer)
			if(offer)
				log_econ("[offer] credits were held from [account.account_holder]'s account for extract request #[request.id]")
			user.log_message("posted [request.describe()], reason: \"[reason]\"", LOG_GAME)
			request.announce()
			return TRUE
		if("cancel")
			var/datum/extract_request/request = find_extract_request(params["id"])
			if(!request || request.requester_account != account || request.status != EXTRACT_REQUEST_WAITING)
				return FALSE
			request.status = EXTRACT_REQUEST_CANCELLED
			request.refund_offer()
			user.log_message("cancelled [request.describe()]", LOG_GAME)
			return TRUE
	return FALSE
